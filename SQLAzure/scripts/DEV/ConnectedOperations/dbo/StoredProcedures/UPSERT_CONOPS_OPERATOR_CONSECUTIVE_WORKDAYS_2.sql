

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

DELETE FROM dbo.OPERATOR_CONSECUTIVE_WORKDAYS_2

INSERT INTO dbo.OPERATOR_CONSECUTIVE_WORKDAYS_2
SELECT 
	SITE_CODE,
	UNIT_CODE,
	OPERID,
	FIRSTSHIFTINDEX,
	LASTSHIFTINDEX,
	NROFDAYS,
	UTC_CREATED_DATE
FROM dbo.OPERATOR_CONSECUTIVE_WORKDAYS_STG_2
 
END



