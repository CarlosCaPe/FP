



/******************************************************************  
* PROCEDURE	: dbo.Operator_DrillDetail_Activity_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 12 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_DrillDetail_Activity_Get 'PREV', 'MOR', '0000055434'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {12 May 2023}		{jrodulfa}		{Initial Created}
* {30 May 2023}		{sxavier}		{Rename Alert Name, Type, and Description field}
* {22 Jan 2024}		{lwasini}		{Add TYR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_Operator_DrillDetail_Activity_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@OPERID VARCHAR(10)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

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
		FROM [bag].[CONOPS_BAG_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND [OPERATOR_ID] = @OPERID
			  AND [EQMT_TYPE] = 'Drill';

		-- Delays
		SELECT [SHIFTFLAG]
			  ,[OperatorId]
			  ,'DELAY' AS AlertType
			  ,CONCAT('DELAY - ', [REASONIDX]) AS AlertName
			  ,[REASON] AS AlertDescription
			  ,[PATTERN_NO] AS Region
			  ,[AlertDateTime] AS [GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_DRILL_DELAY_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND [OperatorId] = @OPERID;

		-- Late Start
		SELECT [shiftflag]
			  ,[OperatorId]
			  ,'LATE START' AS AlertType
			  ,'LATE START' AS AlertName
			  ,NULL AS AlertDescription
			  ,NULL AS Region
			  ,[FirstLoginDateTime] AS [GeneratedDate]
		FROM [bag].[CONOPS_BAG_DRILL_OPERATOR_HAS_LATE_START_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND [OperatorId] = @OPERID;

		-- Ramp Events
		SELECT [shiftflag]
			  ,[OPERATORID]
			  ,'RAMP EVENT' AS AlertType
			  ,'RAMP EVENT' AS AlertName
			  ,[alarm_name] AS AlertDescription
			  ,NULL AS Region
			  ,[alarm_start_time] AS [GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_DRILL_RAMP_EVENT_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND [OPERATORID] = @OPERID;

	END

	ELSE IF @SITE = 'CER'
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
			  AND siteflag =  @SITE
			  AND [OPERATOR_ID] = @OPERID
			  AND [EQMT_TYPE] = 'Drill';

		-- Delays
		SELECT [SHIFTFLAG]
			  ,[OperatorId]
			  ,'DELAY' AS AlertType
			  ,CONCAT('DELAY - ', [REASONIDX]) AS AlertName
			  ,[REASON] AS AlertDescription
			  ,[PATTERN_NO] AS Region
			  ,[AlertDateTime] AS [GeneratedDate]
		FROM [CER].[CONOPS_CER_OPERATOR_DRILL_DELAY_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND [OperatorId] = @OPERID;

		-- Late Start
		SELECT [shiftflag]
			  ,[OperatorId]
			  ,'LATE START' AS AlertType
			  ,'LATE START' AS AlertName
			  ,NULL AS AlertDescription
			  ,NULL AS Region
			  ,[FirstLoginDateTime] AS [GeneratedDate]
		FROM [CER].[CONOPS_CER_DRILL_OPERATOR_HAS_LATE_START_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND [OperatorId] = @OPERID;

		-- Ramp Events
		SELECT [shiftflag]
			  ,[OPERATORID]
			  ,'RAMP EVENT' AS AlertType
			  ,'RAMP EVENT' AS AlertName
			  ,[alarm_name] AS AlertDescription
			  ,NULL AS Region
			  ,[alarm_start_time] AS [GeneratedDate]
		FROM [CER].[CONOPS_CER_OPE