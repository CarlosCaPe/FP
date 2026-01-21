






/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_EQUIPMENT_ALARM]
* PURPOSE	: Upsert [UPSERT_CONOPS_EQUIPMENT_ALARM]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_EQUIPMENT_ALARM] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {27 APR 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_EQUIPMENT_ALARM]
AS
BEGIN

DELETE FROM dbo.EQUIPMENT_ALARM

INSERT INTO dbo.EQUIPMENT_ALARM
SELECT 
	SITE_CODE,
	SHIFTINDEX,
	SHIFTDATE,
	SHIFT_CODE,
	EQUIPMENT_ID,
	ALARM_NAME,
	ALARM_START_TIME,
	ALARM_END_TIME,
	UTC_CREATED_DATE
FROM dbo.EQUIPMENT_ALARM_STG
 
END


