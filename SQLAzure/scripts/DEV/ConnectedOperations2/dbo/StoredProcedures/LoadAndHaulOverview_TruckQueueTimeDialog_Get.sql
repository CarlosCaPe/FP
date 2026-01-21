
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckQueueTimeDialog_Get
* PURPOSE	: Get data for Truck Queue Time Dialog
* NOTES		: 
* CREATED	: ggosal1, 19 Sep 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckQueueTimeDialog_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Sep 2023}		{ggosal1}		{Initial Created} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 jan 2024}		{lwasini}		{Add TYR}
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckQueueTimeDialog_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			AVG([dialog].IdleTime) AS AvgQueueTime
		FROM BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
		WHERE [dialog].shiftflag = @SHIFT
			AND IdleTime <> 0

		SELECT 
			[dialog].TruckID AS [Name],
			[dialog].Operator AS OperatorName,
			[dialog].OperatorImageURL AS ImageURL,
			[dialog].OperatorId,
			[dialog].IdleTime AS [QueueTime],
			[dialog].IdleTimeTarget AS [QueueTimeTarget],
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			[dialog].[Payload],
			[dialog].[PayloadTarget],
			ROUND([dialog].[TotalMaterialDelivered],1) As [TotalMaterialDelivered],
			ROUND([dialog].[TotalMaterialDeliveredTarget],1) AS [TotalMaterialDeliveredTarget],
			[dialog].DeltaC,
			[dialog].DeltaCTarget,
			[dialog].Spotting,
			[dialog].SpottingTarget,
			[dialog].Loading,
			[dialog].LoadingTarget,
			[dialog].Dumping,
			[dialog].DumpingTarget,
			[dialog].Efh,
			[dialog].EfhTarget,
			[dialog].[DumpsAtStockpile],
			[dialog].DumpsAtStockpileTarget,
			[dialog].DumpsAtCrusher,
			[dialog].DumpsAtCrusherTarget,
			[dialog].LoadedTravel,
			[dialog].LoadedTravelTarget,
			[dialog].EmptyTravel,
			[dialog].EmptyTravelTarget,
			[dialog].AvgUseOfAvailibility,
			[dialog].AvgUseOfAvailibilityTarget,
			[dialog].Location AS Destination
		FROM BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
		WHERE [dialog].shiftflag = @SHIFT
			AND IdleTime <> 0
		ORDER BY [IdleTime] desc

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			AVG([dialog].IdleTime) AS AvgQueueTime
		FROM CER.[CONOPS_CER_TRUCK_POPUP] [dialog] WITH (NOLOCK)
		WHERE [dialog].shiftflag = @SHIFT
			AND IdleTime <> 0

		SELECT 
			[dialog].TruckID AS [Name],
			[dialog].Operator AS OperatorName,
			[dialog].OperatorImageURL AS ImageURL,
			[dialog].OperatorId,
			[dialog].IdleTime AS [QueueTime],
			[dialog].IdleTimeTarget AS [QueueTimeTarget],
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			[dialog].[Payload],
			[dialog].[PayloadTarget],
			ROUND([dialog].[TotalMaterialDelivered],1) As [TotalMaterialDelivered],
			ROUND([dialog].[TotalMaterialDeliveredTarget],1) AS [TotalMaterialDeliveredTarget],
			[dialog].DeltaC,
			[dialog].DeltaCTarget,
			[dialog].Spotting,
			[dialog].SpottingTarget,
			[dialog].Loading,
			[dialog].LoadingTarget,
			[dialog].Dumping,
			[dialog].DumpingTarget,
			[dialog].Efh,
			[dialog].EfhTarget,
			[dialog].[DumpsAtStockpile],
			[dialog].DumpsAtStockpileTarget,
			[dialog].DumpsAtCrusher,
			[dialog].DumpsAtCrusherTarget,
			[dialog].LoadedTravel,
			[dialog].LoadedTravelTarget,
			[dialog].EmptyTravel,
			[dialog].EmptyTravelTarget,
			[dialog].AvgUseOfAvailibility,
			[dialog].AvgUseOfAvailibilityTarget,
			[dialog].Location AS Destination
		FROM CER.[CONOPS_CER_TRUCK_POPUP] [dialog] WITH (NOLOCK)
		WHERE [dialog].shiftflag = @SHIFT
			AND IdleTime <> 0
		ORDER BY [IdleTime] desc