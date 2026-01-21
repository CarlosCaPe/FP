
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

DELETE FROM dbo.OPERATOR_TITLE_2

INSERT INTO dbo.OPERATOR_TITLE_2
SELECT 
	SITE_CODE,
	EMPLOYEE_ID AS OPERATOR_ID,
	DISPLAY_NAME AS OPERATOR_NAME,
	JOB_TITLE,
	UTC_CREATED_DATE
FROM dbo.OPERATOR_TITLE_STG_2
 
END



