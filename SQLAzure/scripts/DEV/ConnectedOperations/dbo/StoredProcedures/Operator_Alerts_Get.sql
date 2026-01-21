

/******************************************************************  
* PROCEDURE	: dbo.Operator_Alerts_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 12 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_Alerts_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 May 2023}		{jrodulfa}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_Alerts_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
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
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,NULL AS Region
			  ,[ALERT_DATE] AS [GeneratedDate]
		FROM [bag].[CONOPS_BAG_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

		-- Delays
		SELECT [SHIFTFLAG]
			  ,[OperatorId]
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_ALARM_DELAY_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

		-- Late Start
		SELECT [shiftflag]
			  ,[OperatorId]
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_ALARM_HAS_LATE_START_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

		-- Ramp Events
		SELECT [shiftflag]
			  ,[OPERATORID]
			  ,[EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_ALARM_RAMP_EVENT_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

	END

	ELSE IF @SITE = 'CER'
	BEGIN
				
		-- Alerts
		SELECT [SHIFTFLAG]
			  ,[OPERATOR_ID]
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,NULL AS Region
			  ,[ALERT_DATE] AS [GeneratedDate]
		FROM [cer].[CONOPS_CER_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

		-- Delays
		SELECT [SHIFTFLAG]
			  ,[OperatorId]
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[GeneratedDate]
		FROM [cer].[CONOPS_CER_OPERATOR_ALARM_DELAY_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

		-- Late Start
		SELECT [shiftflag]
			  ,[OperatorId]
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[GeneratedDate]
		FROM [cer].[CONOPS_CER_OPERATOR_ALARM_HAS_LATE_START_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

		-- Ramp Events
		SELECT [shiftflag]
			  ,[OPERATORID]
			  ,[EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[GeneratedDate]
		FROM [cer].[CONOPS_CER_OPERATOR_ALARM_RAMP_EVENT_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

	END

	ELSE IF @SITE = 'CHI'
	BEGIN
				
		-- Alerts
		SELECT [SHIFTFLAG]
			  ,[OPERATOR_ID]
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,NULL AS Region
			  ,[ALERT_DATE] AS [GeneratedDate]
		FROM [CHI].[CONOPS_CHI_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

		-- Delays
		SELECT [SHIFTFLAG]
			  ,[OperatorId]
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[GeneratedDate]
		FROM [CHI].[CONOPS_CHI_OPERATOR_ALARM_DELAY_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;

		-- Late Start
		SELECT [shiftflag]
			  ,[OperatorId]
			  ,[EQMTID] AS [EQMT_ID]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[Generat