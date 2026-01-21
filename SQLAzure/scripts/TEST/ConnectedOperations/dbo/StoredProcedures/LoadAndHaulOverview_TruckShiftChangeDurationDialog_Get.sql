

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckShiftChangeDurationDialog_Get
* PURPOSE	: Get data for Truck Shift Change Duration Dialog
* NOTES		: 
* CREATED	: sxavier, 13 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckShiftChangeDurationDialog_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Dec 2022}		{sxavier}		{Initial Created} 
* {04 Jan 2023}		{jrodulfa}		{Implement Truck Detail dialog.} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {28 Nov 2022}		{lwasini}		{Add OperatorId}
* {10 jan 2024}		{lwasini}		{Add TYR}
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change Truck Popup View to Table} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckShiftChangeDurationDialog_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			[sc].TruckID AS [Name],
			[dialog].Operator AS OperatorName,
			[dialog].OperatorImageURL AS ImageURL,
			[dialog].OperatorId,
			[ChangeDuration] AS [Time],
			Region AS Region,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			[dialog].[Payload],
			[dialog].[PayloadTarget],
			ROUND([dialog].[TotalMaterialDelivered],1) As [TotalMaterialDelivered],
			ROUND([dialog].[TotalMaterialDeliveredTarget],1) AS [TotalMaterialDeliveredTarget],
			[dialog].DeltaC,
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
			[dialog].AvgUseOfAvailibility,
			[dialog].AvgUseOfAvailibilityTarget,
			[dialog].Location AS Destination
		FROM BAG.[CONOPS_BAG_TRUCK_SHIFT_CHANGE_DIALOG_V] [sc] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
			ON [sc].shiftflag = [dialog].shiftflag
			AND [sc].TruckID = [dialog].TruckID
		WHERE [sc].shiftflag = @SHIFT
		ORDER BY [ChangeDuration] desc

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			[sc].TruckID AS [Name],
			[dialog].Operator AS OperatorName,
			[dialog].OperatorImageURL AS ImageURL,
			[dialog].OperatorId,
			[ChangeDuration] AS [Time],
			Region AS Region,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			[dialog].[Payload],
			[dialog].[PayloadTarget],
			ROUND([dialog].[TotalMaterialDelivered],1) As [TotalMaterialDelivered],
			ROUND([dialog].[TotalMaterialDeliveredTarget],1) AS [TotalMaterialDeliveredTarget],
			[dialog].DeltaC,
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
			[dialog].AvgUseOfAvailibility,
			[dialog].AvgUseOfAvailibilityTarget,
			[dialog].Location AS Destination
		FROM CER.[CONOPS_CER_TRUCK_SHIFT_CHANGE_DIALOG_V] [sc] WITH (NOLOCK)
		LEFT JOIN CER.[CONOPS_CER_TRUCK_POPUP]