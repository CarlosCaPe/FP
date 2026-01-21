
/******************************************************************  
* PROCEDURE	: dbo.EOS_ShovelSummary_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 17 May 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShovelSummary_Get 'PREV', 'MOR', 1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 May 2023}		{jrodulfa}		{Initial Created} 
* {29 Aug 2023}		{ggosal1}		{Add Summary by Pit} 
* {17 Oct 2023}		{ggosal1}		{Add Delay Duration Minutes}
* {02 Nov 2023}		{ggosal1}		{Add other value on Summary by Pit} 
* {07 Dec 2023}		{lwasini}		{Add Daily Summary} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR} 
* {05 May 2024}		{ggosal1}		{Add HangTime} 
* {28 Jun 2024}		{ggosal1}		{Change Time to Average} 
* {11 Mar 2024}		{ggosal1}		{Add Operator, EQ Status Detail} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShovelSummary_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@DAILY INT
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN


		IF @DAILY = 0
		BEGIN
		SELECT [PushBack] AS [Pit]
			  ,[ShovelId]
			  ,[OperatorId]
			  ,[Operator] AS [OperatorName]
			  ,[OperatorImageURL]
			  ,[Tons]
			  ,ROUND([TPRH],0) AS [TPRH]
			  ,[SpotTime_min] AS [SpotTime]
			  ,[LoadingTime_min] AS [LoadingTime]
			  ,[QueueTime_min] AS [QueueTime]
			  ,[DelayDuration_min] AS [DelayDuration]
			  ,[HangTime_min] AS [HangTime]
			  ,[Payload]
			  ,[Availability]
			  ,[UseOfAvailability]
			  ,[AssetEfficiency]
		FROM [BAG].[CONOPS_BAG_EOS_SHOVEL_SUMMARY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [PushBack], [ShovelId];
 
		SELECT 
			[PushBack] AS [Pit]
			,SUM([Tons]) AS Tons
			,ROUND(SUM([TPRH]),0) AS [TPRH]
			,AVG([SpotTime_min]) AS [SpotTime]
			,AVG([LoadingTime_min]) AS [LoadingTime]
			,AVG([QueueTime_min]) AS [QueueTime]
			,SUM([DelayDuration_min]) AS [DelayDuration]
			,AVG([HangTime_min]) AS [HangTime]
			,AVG([Payload]) AS [Payload]
			,AVG([Availability]) AS [Availability]
			,AVG([UseOfAvailability]) AS [UseOfAvailability]
			,AVG([AssetEfficiency]) AS [AssetEfficiency]
		FROM [BAG].[CONOPS_BAG_EOS_SHOVEL_SUMMARY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY PushBack
		ORDER BY PushBack
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [PushBack] AS [Pit]
			  ,[ShovelId]
			  ,[OperatorId]
			  ,[Operator] AS [OperatorName]
			  ,[OperatorImageURL]
			  ,SUM([Tons]) AS Tons
			  ,ROUND(SUM([TPRH]),0) AS [TPRH]
			  ,AVG([SpotTime_min]) AS [SpotTime]
			  ,AVG([LoadingTime_min]) AS [LoadingTime]
			  ,AVG([QueueTime_min]) AS [QueueTime]
			  ,SUM([DelayDuration_min]) AS [DelayDuration]
			  ,AVG([HangTime_min]) AS [HangTime]
			  ,AVG([Payload]) AS [Payload]
			  ,AVG([Availability]) AS [Availability]
			  ,AVG([UseOfAvailability]) AS [UseOfAvailability]
			  ,AVG([AssetEfficiency]) AS [AssetEfficiency]
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_SHOVEL_SUMMARY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY [PushBack], [ShovelId], [OperatorId], [Operator], [OperatorImageURL]
		ORDER BY [PushBack], [ShovelId];
 
		SELECT 
			[PushBack] AS [Pit]
			,SUM([Tons]) AS Tons
			,ROUND(SUM([TPRH]),0) AS [TPRH]
			,AVG([SpotTime_min]) AS [SpotTime]
			,AVG([LoadingTime_min]) AS [LoadingTime]
			,AVG([QueueTime_min]) AS [QueueTime]
			,SUM([DelayDuration_min]) AS [DelayDuration]
			,AVG([HangTime_min]) AS [HangTime]
			,AVG([Payload]) AS [Payload]
			,AVG([Availability]) AS [Availability]
			,AVG([UseOfAvailability]) AS [UseOfAvailability]
			,AVG([AssetEfficiency]) AS [AssetEfficiency]
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_SHOVEL_SUMMARY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY PushBack
		ORDER BY PushBack
		END

	END

	ELSE IF @SITE = 'CVE'
	BEGIN


		IF @DAILY = 0
		BEGIN
		SELECT [PushBack] AS [Pit]
			  ,[ShovelId]
			  ,[OperatorId]
			  ,[Operator] AS [OperatorName