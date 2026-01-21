
/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OPERATOR_TITLE_2]
* PURPOSE	: Upsert [UPSERT_CONOPS_OPERATOR_TITLE_2]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OPERATOR_TITLE_2] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {12 JUN 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_OPERATOR_TITLE_2]
AS
BEGIN

MERGE dbo.OPERATOR_TITLE_2 AS T
USING (
    SELECT 
        SITE_CODE,
        EMPLOYEE_ID AS OPERATOR_ID,
        DISPLAY_NAME AS OPERATOR_NAME,
        JOB_TITLE,
        UTC_CREATED_DATE
    FROM dbo.OPERATOR_TITLE_STG_2
) AS S
ON (
    T.SITE_CODE = S.SITE_CODE AND
    T.OPERATOR_ID = S.OPERATOR_ID
)
WHEN MATCHED THEN
    UPDATE SET
        T.OPERATOR_NAME = S.OPERATOR_NAME,
        T.JOB_TITLE = S.JOB_TITLE,
        T.UTC_CREATED_DATE = S.UTC_CREATED_DATE
WHEN NOT MATCHED THEN
    INSERT (
        SITE_CODE,
        OPERATOR_ID,
        OPERATOR_NAME,
        JOB_TITLE,
        UTC_CREATED_DATE
    )
    VALUES (
        S.SITE_CODE,
        S.OPERATOR_ID,
        S.OPERATOR_NAME,
        S.JOB_TITLE,
        S.UTC_CREATED_DATE
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

--Update Job Control
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_operator_title_2';

END



