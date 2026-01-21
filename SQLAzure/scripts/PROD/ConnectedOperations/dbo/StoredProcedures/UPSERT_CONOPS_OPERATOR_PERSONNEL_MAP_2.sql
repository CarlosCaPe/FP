
/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OPERATOR_PERSONNEL_MAP_2]
* PURPOSE	: Upsert [UPSERT_CONOPS_OPERATOR_PERSONNEL_MAP_2]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OPERATOR_PERSONNEL_MAP_2] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {08 FEB 2023}		{ggosal1}			{Initial Created}  
* {20 FEB 2023}		{ggosal1}			{Expand for all sites}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_OPERATOR_PERSONNEL_MAP_2]
AS
BEGIN

MERGE dbo.operator_personnel_map_2 AS T
USING (
    SELECT 
        SITE_CODE,
        SHIFTINDEX,
        OPERATOR_ID,
        PERSONNEL_ID,
        CREW,
        FULL_NAME,
        FIRST_NAME,
        LAST_NAME,
        FIRST_LAST_NAME,
        COALESCE(UTC_CREATED_DATE, GETUTCDATE()) AS UTC_CREATED_DATE,
        TRY_CONVERT(numeric, OPERATOR_ID) AS OperatorID_Num
    FROM dbo.operator_personnel_map_stg_2
) AS S
ON (
    T.SITE_CODE = S.SITE_CODE AND
    T.SHIFTINDEX = S.SHIFTINDEX AND
    T.OPERATOR_ID = S.OPERATOR_ID
)
WHEN MATCHED THEN
    UPDATE SET
        T.PERSONNEL_ID = S.PERSONNEL_ID,
        T.CREW = S.CREW,
        T.FULL_NAME = S.FULL_NAME,
        T.FIRST_NAME = S.FIRST_NAME,
        T.LAST_NAME = S.LAST_NAME,
        T.FIRST_LAST_NAME = S.FIRST_LAST_NAME,
        T.UTC_CREATED_DATE = S.UTC_CREATED_DATE,
        T.OperatorID_Num = S.OperatorID_Num
WHEN NOT MATCHED THEN
    INSERT (
        SITE_CODE,
        SHIFTINDEX,
        OPERATOR_ID,
        PERSONNEL_ID,
        CREW,
        FULL_NAME,
        FIRST_NAME,
        LAST_NAME,
        FIRST_LAST_NAME,
        UTC_CREATED_DATE,
        OperatorID_Num
    )
    VALUES (
        S.SITE_CODE,
        S.SHIFTINDEX,
        S.OPERATOR_ID,
        S.PERSONNEL_ID,
        S.CREW,
        S.FULL_NAME,
        S.FIRST_NAME,
        S.LAST_NAME,
        S.FIRST_LAST_NAME,
        S.UTC_CREATED_DATE,
        S.OperatorID_Num
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

--Update Job Control
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_operator_personnel_map_2';

END



