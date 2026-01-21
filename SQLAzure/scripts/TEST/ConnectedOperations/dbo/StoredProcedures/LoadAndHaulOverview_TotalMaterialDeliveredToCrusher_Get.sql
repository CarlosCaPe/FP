









/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TotalMaterialDeliveredToCrusher_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TotalMaterialDeliveredToCrusher_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {05 Dec 2022}		{jrodulfa}		{Added Crush Leach and MillOre Actual, Crushers Target, and Top 3 Off Target Trucks}  
* {06 Dec 2022}		{jrodulfa}		{Added Truck to Watch Dialog.} 
* {08 Dec 2022}		{jrodulfa}		{Added Truck Detail Dialog.} 
* {12 Dec 2022}		{jrodulfa}		{Added Reason ID, Reason Desc and Operator Image URL.} 
* {14 Dec 2022}		{jrodulfa}		{Convert CrushLeach and MillOre value from Tons to KT.} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {01 Feb 2023}		{jrodulfa}		{Change UoM for Off Target from KT to Tons.}
* {29 Mar 2023}		{sxavier}		{Comment unused select.}
* {30 Mar 2023}		{jrodulfa}		{Update SP based on the new design.}
* {23 May 2023}		{lwasini}		{Exclude Ready Equipment from Truck to Watch}
* {23 May 2023}		{ggosal1}		{Add Crusher Status}
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 jan 2024}		{lwasini}		{Add TYR}
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}		{lwasini}		{Add ABR} 
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 

CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TotalMaterialDeliveredToCrusher_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN    
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT
			Name,
			(sum(MillOreActual) + sum(LeachActual)) * 1000.0 AS TotalDelivered,
			ISNULL(Status, 'Unknown') AS Status,
			ISNULL(reasons, 'Unknown') AS Reason
		FROM BAG.[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V] [ca] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_CRUSHER_STATUS_V] [cs] WITH (NOLOCK)
			ON [ca].shiftflag = [cs].shiftflag
			AND [ca].name = [cs].Crusher
		WHERE [ca].shiftflag = @SHIFT
		GROUP BY Name, Status, reasons
	
	
		SELECT Name,
			LeachActual,
			LeachTarget,
			LeachShiftTarget,
			MillOreActual,
			MillOreTarget,
			MillOreShiftTarget
		FROM BAG.[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V] [ca] WITH (NOLOCK)
		WHERE [ca].shiftflag = @SHIFT
	
	
		SELECT TOP 25 PERCENT [tw].TruckID AS [Name],
			[dialog].Operator AS OperatorName,
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			COALESCE([tw].[TPRH], 0) AS Tprh,
			ROUND([dialog].[Payload],0) AS AvgPayload,
			ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]),1) [OffTarget],
			ROUND([dialog].[Payload],0) As Payload,
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
			ROUND([dialog].AvgUseOfAvailibility,0) As AvgUseOfAvailibility,
			ROUND([dialog].AvgUseOfAvailibilityTarget,0) As AvgUseOfAvailibilityTarget,
			[tw].Location AS Destination
		FROM BAG.[CONOPS_BAG_TR