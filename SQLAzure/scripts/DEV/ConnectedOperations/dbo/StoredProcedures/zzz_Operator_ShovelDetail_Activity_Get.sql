




/******************************************************************  
* PROCEDURE	: dbo.Operator_ShovelDetail_Activity_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 12 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_ShovelDetail_Activity_Get 'PREV', 'MOR', '61006910'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {12 May 2023}		{ggosal1}		{Initial Created}
* {22 Jan 2024}		{lwasini}		{Add TYR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_Operator_ShovelDetail_Activity_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@OPERID VARCHAR(50)
)
AS                        
BEGIN  

	IF @SITE = 'BAG'
	BEGIN

		-- Alerts
		SELECT [SHIFTFLAG]
			  ,[OPERATOR_ID]
			  ,[ALERT_TYPE] AS AlertType
			  ,[ALERT_NAME] AS AlertName
			  ,[ALERT_DESCRIPTION] AS AlertDescription
			  ,NULL AS Region
			  ,[ALERT_DATE] AS [GeneratedDate]
		FROM [BAG].[CONOPS_BAG_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND [OPERATOR_ID] = @OPERID
			  AND [EQMT_TYPE] = 'Shovel';
 
		-- Delays
		SELECT [SHIFTFLAG]
			  ,[OperatorId]
			  ,'DELAY' AS AlertType
			  ,CONCAT('DELAY - ', [REASONIDX]) AS AlertName
			  ,[REASONS] AS AlertDescription
			  ,[Location] AS Region
			  ,[StartDateTime] AS [GeneratedDate]
		FROM [BAG].[CONOPS_BAG_OPERATOR_SHOVEL_DELAY_V]
		WHERE shiftflag = @SHIFT
			  AND [OperatorId] = @OPERID;
 
		-- Late Start
		SELECT [shiftflag]
			  ,[OperatorId]
			  ,'LATE START' AS AlertType
			  ,'LATE START' AS AlertName
			  ,NULL AS AlertDescription
			  ,NULL AS Region
			  ,[FirstLoginDateTime] AS [GeneratedDate]
		FROM [BAG].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V]
		WHERE shiftflag = @SHIFT
			  AND [OperatorId] = @OPERID;
 
		-- Ramp Events
		SELECT [shiftflag]
			  ,[OPERATORID]
			  ,'RAMP EVENT' AS AlertType
			  ,'RAMP EVENT' AS AlertName
			  ,[alarm_name] AS AlertDescription
			  ,NULL AS Region
			  ,[alarm_start_time] AS [GeneratedDate]
		FROM [BAG].[CONOPS_BAG_OPERATOR_SHOVEL_RAMP_EVENT_V]
		WHERE shiftflag = @SHIFT
			  AND [OPERATORID] = @OPERID;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		-- Alerts
		SELECT [SHIFTFLAG]
			  ,[OPERATOR_ID]
			  ,[ALERT_TYPE] AS AlertType
			  ,[ALERT_NAME] AS AlertName
			  ,[ALERT_DESCRIPTION] AS AlertDescription
			  ,NULL AS Region
			  ,[ALERT_DATE] AS [GeneratedDate]
		FROM [CER].[CONOPS_CER_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND [OPERATOR_ID] = @OPERID
			  AND [EQMT_TYPE] = 'Shovel';
 
		-- Delays
		SELECT [SHIFTFLAG]
			  ,[OperatorId]
			  ,'DELAY' AS AlertType
			  ,CONCAT('DELAY - ', [REASONIDX]) AS AlertName
			  ,[REASONS] AS AlertDescription
			  ,[Location] AS Region
			  ,[StartDateTime] AS [GeneratedDate]
		FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_DELAY_V]
		WHERE shiftflag = @SHIFT
			  AND [OperatorId] = @OPERID;
 
		-- Late Start
		SELECT [shiftflag]
			  ,[OperatorId]
			  ,'LATE START' AS AlertType
			  ,'LATE START' AS AlertName
			  ,NULL AS AlertDescription
			  ,NULL AS Region
			  ,[FirstLoginDateTime] AS [GeneratedDate]
		FROM [CER].[CONOPS_CER_OPERATOR_HAS_LATE_START_V]
		WHERE shiftflag = @SHIFT
			  AND [OperatorId] = @OPERID;
 
		-- Ramp Events
		SELECT [shiftflag]
			  ,[OPERATORID]
			  ,'RAMP EVENT' AS AlertType
			  ,'RAMP EVENT' AS AlertName
			  ,[alarm_name] AS AlertDescription
			  ,NULL AS Region
			  ,[alarm_start_time] AS [GeneratedDate]
		FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_RAMP_EVENT_V]
		WHERE shiftflag = @SHIFT
			  AND [OPERATORID] = @OPERID;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		-- Alerts
		SELECT [SHIFTFLAG]
			  ,[OPERATOR_ID]
			  ,[ALERT_TYPE] AS AlertType
			  ,[ALERT_NAME] AS AlertName
			  ,[ALERT_DESCRIPTION] AS AlertDescription
			  ,NULL AS Region
			  ,[ALERT_DATE] AS [GeneratedDate]
		FROM [CHI].[CONOPS_CHI_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SH