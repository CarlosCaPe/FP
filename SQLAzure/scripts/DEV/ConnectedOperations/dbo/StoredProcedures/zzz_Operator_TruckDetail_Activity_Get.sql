


/******************************************************************  
* PROCEDURE	: dbo.Operator_TruckDetail_Activity_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 09 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_TruckDetail_Activity_Get 'PREV', 'MOR', '61006910'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {09 May 2023}		{mbote}		{Initial Created}
* {15 May 2023}		{mbote}		{Add other sites}
* {31 May 2023}		{jrodulfa}	{Align code structure to Drill Detail SP}
* {22 Jan 2024}		{lwasini}		{Add TYR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_Operator_TruckDetail_Activity_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@OPERID VARCHAR(50)
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
			  ,[OPERATORID]
			  ,[ALERT_TYPE] AS AlertType
			  ,[ALERT_NAME] AS AlertName
			  ,[ALERT_DESCRIPTION] AS AlertDescription
			  ,NULL AS Region
			  ,[GeratedDate] AS [GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_ALERTS_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND [OPERATORID] = @OPERID;

		-- Delays
		SELECT [d].[SHIFTFLAG]
			  ,[d].[OperatorId]
			  ,'DELAY' AS AlertType
			  ,CONCAT('DELAY - ', [REASONIDX]) AS AlertName
			  ,[Reasons] AS AlertDescription
			  ,Region AS Region
			  ,[StartDateTime] AS [GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_DELAY_V] [d] WITH (NOLOCK) 
		LEFT JOIN [bag].[CONOPS_BAG_OPERATOR_TRUCK_V] [op] WITH (NOLOCK)
		ON [op].ShiftFlag = [d].ShiftFlag AND [op].TruckID = [d].TruckID
		WHERE [d].shiftflag = @SHIFT
			  AND [d].siteflag =  @SITE
			  AND [d].[OperatorId] = @OPERID;

		-- Late Start
		SELECT [ls].[shiftflag]
			  ,[ls].[OperatorId]
			  ,'LATE START' AS AlertType
			  ,'LATE START' AS AlertName
			  ,NULL AS AlertDescription
			  ,Region
			  ,[FirstLoginDateTime] AS [GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK) 
		LEFT JOIN [bag].[CONOPS_BAG_OPERATOR_TRUCK_V] [op] WITH (NOLOCK)
		ON [op].ShiftFlag = [ls].ShiftFlag AND [op].TruckID = [ls].[eqmtid]
		WHERE [ls].shiftflag = @SHIFT
			  AND [ls].siteflag =  @SITE
			  AND [ls].[OperatorId] = @OPERID;

		-- Ramp Events
		SELECT [re].[shiftflag]
			  ,[re].[OPERATORID]
			  ,'RAMP EVENT' AS AlertType
			  ,'RAMP EVENT' AS AlertName
			  ,[alarm_name] AS AlertDescription
			  ,Region
			  ,[alarm_start_time] AS [GeneratedDate]
		FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_RAMP_EVENT_V] [re] WITH (NOLOCK)
		LEFT JOIN [bag].[CONOPS_BAG_OPERATOR_TRUCK_V] [op] WITH (NOLOCK)
		ON [op].ShiftFlag = [re].ShiftFlag AND [op].TruckID = [re].TruckID
		WHERE [re].shiftflag = @SHIFT
			  AND [re].siteflag =  @SITE
			  AND [re].[OPERATORID] = @OPERID;
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		-- Alerts
		SELECT [SHIFTFLAG]
			  ,[OPERATORID]
			  ,[ALERT_TYPE] AS AlertType
			  ,[ALERT_NAME] AS AlertName
			  ,[ALERT_DESCRIPTION] AS AlertDescription
			  ,NULL AS Region
			  ,[GeratedDate] AS [GeneratedDate]
		FROM [cer].[CONOPS_CER_OPERATOR_TRUCK_ALERTS_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND [OPERATORID] = @OPERID;

		-- Delays
		SELECT [d].[SHIFTFLAG]
			  ,[d].[OperatorId]
			  ,'DELAY' AS AlertType
			  ,CONCAT('DELAY - ', [REASONIDX]) AS AlertName
			  ,[Reasons] AS AlertDescription
			  ,Region AS Region
			  ,[StartDateTime] AS [GeneratedDate]
		FROM [cer].[CONOPS_CER_OPERATOR_TRUCK_DELAY_V] [d] WITH (NOLOCK) 
		LEFT JOIN [cer].[CONOPS_CER_OPERATOR_TRUCK_V] [op] WITH (NOLOCK)
		ON [op].ShiftFlag = [d].ShiftFlag AND [op].TruckID = [d].TruckID
		WHERE [d].shiftflag = @SHIFT
			  AND [d].siteflag =  @SITE
			  AND [d].[OperatorI