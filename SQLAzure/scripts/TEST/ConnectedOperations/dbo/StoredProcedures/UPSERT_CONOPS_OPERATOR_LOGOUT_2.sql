
/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OPERATOR_LOGOUT_2]
* PURPOSE	: Upsert [UPSERT_CONOPS_OPERATOR_LOGOUT_2]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OPERATOR_LOGOUT_2] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {06 JUN 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_OPERATOR_LOGOUT_2]
AS
BEGIN

MERGE dbo.OPERATOR_LOGOUT_2 AS T
USING (
    SELECT 
        site_code,
        shift_oper_id,
        shiftindex,
        shiftdate,
        operid,
        oper_name,
        crew,
        eqmt,
        fieldlogin,
        fieldlogin_ts,
        "status",
        utc_created_date
    FROM dbo.OPERATOR_LOGOUT_STG_2
) AS S
ON (
    T.SITE_CODE = S.SITE_CODE AND
    T.SHIFTINDEX = S.SHIFTINDEX AND
    T.OPERID = S.OPERID AND
    T.EQMT = S.EQMT AND
    T.FIELDLOGIN = S.FIELDLOGIN
)
WHEN MATCHED THEN
    UPDATE SET
        T.SHIFT_OPER_ID = S.SHIFT_OPER_ID,
        T.SHIFTDATE = S.SHIFTDATE,
        T.OPER_NAME = S.OPER_NAME,
        T.CREW = S.CREW,
        T.FIELDLOGIN_TS = S.FIELDLOGIN_TS,
        T.STATUS = S.STATUS,
        T.UTC_CREATED_DATE = S.UTC_CREATED_DATE
WHEN NOT MATCHED THEN
    INSERT (
        SITE_CODE,
        SHIFT_OPER_ID,
        SHIFTINDEX,
        SHIFTDATE,
        OPERID,
        OPER_NAME,
        CREW,
        EQMT,
        FIELDLOGIN,
        FIELDLOGIN_TS,
        STATUS,
        UTC_CREATED_DATE
    )
    VALUES (
        S.SITE_CODE,
        S.SHIFT_OPER_ID,
        S.SHIFTINDEX,
        S.SHIFTDATE,
        S.OPERID,
        S.OPER_NAME,
        S.CREW,
        S.EQMT,
        S.FIELDLOGIN,
        S.FIELDLOGIN_TS,
        S.STATUS,
        S.UTC_CREATED_DATE
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

--Update Job Control
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_operator_logout_2';

END



