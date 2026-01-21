

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OPERATOR_CONSECUTIVE_WORKDAYS_2]
* PURPOSE	: Upsert [UPSERT_CONOPS_OPERATOR_CONSECUTIVE_WORKDAYS_2]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OPERATOR_CONSECUTIVE_WORKDAYS_2] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {08 JUN 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_OPERATOR_CONSECUTIVE_WORKDAYS_2]
AS
BEGIN

MERGE dbo.OPERATOR_CONSECUTIVE_WORKDAYS_2 AS T
USING (
    SELECT 
        SITE_CODE,
        UNIT_CODE,
        OPERID,
        FIRSTSHIFTINDEX,
        LASTSHIFTINDEX,
        NROFDAYS,
        COALESCE(UTC_CREATED_DATE, GETUTCDATE()) AS UTC_CREATED_DATE
    FROM dbo.OPERATOR_CONSECUTIVE_WORKDAYS_STG_2
) AS S
ON (
    T.SITE_CODE = S.SITE_CODE AND
    T.OPERID = S.OPERID AND
    T.FIRSTSHIFTINDEX = S.FIRSTSHIFTINDEX
)
WHEN MATCHED THEN
    UPDATE SET
        T.UNIT_CODE = S.UNIT_CODE,
        T.LASTSHIFTINDEX = S.LASTSHIFTINDEX,
        T.NROFDAYS = S.NROFDAYS,
        T.UTC_CREATED_DATE = S.UTC_CREATED_DATE
WHEN NOT MATCHED THEN
    INSERT (
        SITE_CODE,
        UNIT_CODE,
        OPERID,
        FIRSTSHIFTINDEX,
        LASTSHIFTINDEX,
        NROFDAYS,
        UTC_CREATED_DATE
    )
    VALUES (
        S.SITE_CODE,
        S.UNIT_CODE,
        S.OPERID,
        S.FIRSTSHIFTINDEX,
        S.LASTSHIFTINDEX,
        S.NROFDAYS,
        S.UTC_CREATED_DATE
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

--Update Job Control
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_operator_consecutive_workdays_2';

END



