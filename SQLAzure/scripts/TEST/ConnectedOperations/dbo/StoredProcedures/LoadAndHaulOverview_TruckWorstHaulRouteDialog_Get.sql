







/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckWorstHaulRouteDialog_Get
* PURPOSE	: Get data for Truck Worst Haul Route Dialog
* NOTES		: 
* CREATED	: sxavier, 13 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckWorstHaulRouteDialog_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Dec 2022}		{sxavier}		{Initial Created} 
* {03 Jan 2023}		{jrodulfa}		{Implement Truck Detail dialog.} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 jan 2024}		{lwasini}		{Add TYR}
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckWorstHaulRouteDialog_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			[worstHaul].TRUCK AS [Name],
			[dialog].Operator [OperatorName],
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			[worstHaul].SHOVEL AS Shovel,
			[worstHaul].DUMPNAME AS [Dump],
			ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]) / 1000.00,1) [OffTarget],
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
			[worstHaul].Location AS Destination
		FROM BAG.[CONOPS_BAG_WORST_HAUL_ROUTE_V] [worstHaul] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
			ON [worstHaul].shiftflag = [dialog].shiftflag
			AND [worstHaul].TRUCK = [dialog].TruckID
		WHERE [worstHaul].shiftflag = @SHIFT
		ORDER BY TOTAL_MIN_OVER_EXPECTED desc

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			[worstHaul].TRUCK AS [Name],
			[dialog].Operator [OperatorName],
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			[worstHaul].SHOVEL AS Shovel,
			[worstHaul].DUMPNAME AS [Dump],
			ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]) / 1000.00,1) [OffTarget],
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
			[d