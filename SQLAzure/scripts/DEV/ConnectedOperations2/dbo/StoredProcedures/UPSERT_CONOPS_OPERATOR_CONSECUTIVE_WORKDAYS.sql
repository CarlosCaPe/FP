


/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OPERATOR_CONSECUTIVE_WORKDAYS]
* PURPOSE	: Upsert [UPSERT_CONOPS_OPERATOR_CONSECUTIVE_WORKDAYS]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OPERATOR_CONSECUTIVE_WORKDAYS] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {08 JUN 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_OPERATOR_CONSECUTIVE_WORKDAYS]
AS
BEGIN

DELETE FROM dbo.OPERATOR_CONSECUTIVE_WORKDAYS

INSERT INTO dbo.OPERATOR_CONSECUTIVE_WORKDAYS
SELECT 
	SITE_CODE,
	UNIT_CODE,
	OPERID,
	FIRSTSHIFTINDEX,
	LASTSHIFTINDEX,
	NROFDAYS,
	UTC_CREATED_DATE
FROM dbo.OPERATOR_CONSECUTIVE_WORKDAYS_STG
 
END



