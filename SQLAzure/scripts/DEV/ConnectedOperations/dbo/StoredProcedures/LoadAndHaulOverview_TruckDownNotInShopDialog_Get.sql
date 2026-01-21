

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckDownNotInShopDialog_Get
* PURPOSE	: Get data for Truck Down Not In SHop Dialog
* NOTES		: 
* CREATED	: sxavier, 13 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckDownNotInShopDialog_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Dec 2022}		{sxavier}		{Initial Created} 
* {03 Jan 2023}		{jrodulfa}		{Implement Truck Detail dialog.} 
* {07 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 jan 2024}		{lwasini}		{Add TYR}
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckDownNotInShopDialog_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT [truckDown].TruckID AS [Name],
			ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]) / 1000.00,1) [OffTarget],
			[dialog].Operator AS [OperatorName],
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			CONVERT(VARCHAR(5), StatusStart, 108) AS [Time],
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			Region,
			ROUND([dialog].[Payload],0) AS [Payload],
			[dialog].[PayloadTarget],
			ROUND([dialog].[TotalMaterialDelivered],1) AS [TotalMaterialDelivered],
			ROUND([dialog].[TotalMaterialDeliveredTarget],1) AS [TotalMaterialDeliveredTarget],
			ROUND([dialog].DeltaC,1) AS DeltaC,
			[dialog].DeltaCTarget,
			[dialog].IdleTime,
			[dialog].IdleTimeTarget,
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
			ROUND([dialog].AvgUseOfAvailibility,0) AS AvgUseOfAvailibility,
			ROUND([dialog].AvgUseOfAvailibilityTarget,0) AS AvgUseOfAvailibilityTarget,
			[truckDown].Location AS Destination
		FROM BAG.[CONOPS_BAG_TRUCK_DOWN_NOT_IN_SHOP_V] [truckDown] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
			ON [truckDown].shiftflag = [dialog].shiftflag 
			AND [truckDown].TruckID = [dialog].TruckID
		WHERE [truckDown].shiftflag = @SHIFT 
			AND [truckDown].TruckID IS NOT NULL

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT [truckDown].TruckID AS [Name],
			ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]) / 1000.00,1) [OffTarget],
			[dialog].Operator AS [OperatorName],
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			CONVERT(VARCHAR(5), StatusStart, 108) AS [Time],
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			Region,
			ROUND([dialog].[Payload],0) AS [Payload],
			[dialog].[PayloadTarget],
			ROUND([dialog].[TotalMaterialDelivered],1) AS [TotalMaterialDelivered],
			ROUND([dialog].[TotalMaterialDeliveredTarget],1) AS [TotalMaterialDeliveredTarget],
			ROUND([dialog].DeltaC,1) AS DeltaC,
			[dialog].DeltaCTarget,
			[dialog].IdleTime,
			[dialog].IdleTimeTarget,
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
			[di