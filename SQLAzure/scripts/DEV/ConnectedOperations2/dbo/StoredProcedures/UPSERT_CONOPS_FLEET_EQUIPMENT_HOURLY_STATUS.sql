



/******************************************************************    
* PROCEDURE : DBO.[UPSERT_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS]  
* PURPOSE : UPSERT [UPSERT_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS]  
* NOTES     :   
* CREATED : GGOSAL1  
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS] 'BAG'
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {25 MAR 2024}  {GGOSAL1}  {INITIAL CREATED}   
* {17 FEB 2025}  {GGOSAL1}  {Add PRIMARYOPERATOR_ID & SECONDARYOPERATOR_ID}  
*******************************************************************/    
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS]
(
@G_SITE VARCHAR(5)
)
AS  

IF @G_SITE = 'BAG'
BEGIN

	DELETE FROM [BAG].[FLEET_EQUIPMENT_HOURLY_STATUS_STG];

	INSERT INTO [BAG].[FLEET_EQUIPMENT_HOURLY_STATUS_STG]
			   ([SHIFTINDEX]
			   ,[SHIFTID]
			   ,[SHIFTDATE]
			   ,[SITE_CODE]
			   ,[EQMT]
			   ,[UNIT]
			   ,[HOS]
			   ,[START_TIME_TS]
			   ,[END_TIME_TS]
			   ,[DURATION]
			   ,[REASON]
			   ,[STATUS]
			   ,[CATEGORY]
			   ,[COMMENTS]
			   ,[LOC]
			   ,[PRIMARYOPERATOR_ID]
			   ,[SECONDARYOPERATOR_ID]
			   ,[UTC_CREATED_DATE]
	)

	SELECT [SHIFTINDEX]
		  ,[SHIFTID]
		  ,[SHIFTDATE]
		  ,[SITE_CODE]
		  ,[EQMT]
		  ,[UNIT]
		  ,[HOS]
		  ,[START_TIME_TS]
		  ,[END_TIME_TS]
		  ,[DURATION]
		  ,[REASON]
		  ,[STATUS]
		  ,[CATEGORY]
		  ,[COMMENTS]
		  ,[LOC]
		  ,[PRIMARYOPERATOR_ID]
		  ,[SECONDARYOPERATOR_ID]
		  ,GETUTCDATE() AS [UTC_CREATED_DATE]
	FROM [BAG].[FLEET_EQUIPMENT_HOURLY_STATUS_V];

	DELETE FROM [BAG].[FLEET_EQUIPMENT_HOURLY_STATUS];

	INSERT INTO [BAG].[FLEET_EQUIPMENT_HOURLY_STATUS]
			   ([SHIFTINDEX]
			   ,[SHIFTID]
			   ,[SHIFTDATE]
			   ,[SITE_CODE]
			   ,[EQMT]
			   ,[UNIT]
			   ,[HOS]
			   ,[START_TIME_TS]
			   ,[END_TIME_TS]
			   ,[DURATION]
			   ,[REASON]
			   ,[STATUS]
			   ,[CATEGORY]
			   ,[COMMENTS]
			   ,[LOC]
			   ,[PRIMARYOPERATOR_ID]
			   ,[SECONDARYOPERATOR_ID]
			   ,[UTC_CREATED_DATE]
	)
	SELECT [SHIFTINDEX]
		  ,[SHIFTID]
		  ,[SHIFTDATE]
		  ,[SITE_CODE]
		  ,[EQMT]
		  ,[UNIT]
		  ,[HOS]
		  ,[START_TIME_TS]
		  ,[END_TIME_TS]
		  ,[DURATION]
		  ,[REASON]
		  ,[STATUS]
		  ,[CATEGORY]
		  ,[COMMENTS]
		  ,[LOC]
		  ,[PRIMARYOPERATOR_ID]
		  ,[SECONDARYOPERATOR_ID]
		  ,[UTC_CREATED_DATE]
	FROM [BAG].[FLEET_EQUIPMENT_HOURLY_STATUS_STG]

END


