

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TotalMaterialDeliveredToCrusher_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TotalMaterialDeliveredToCrusher_Get 'PREV', 'CHN'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {05 Dec 2022}		{jrodulfa}		{Added Crush Leach and MillOre Actual, Crushers Target, and Top 3 Off Target Trucks}  
* {06 Dec 2022}		{jrodulfa}		{Added Truck to Watch Dialog.} 
* {08 Dec 2022}		{jrodulfa}		{Added Truck Detail Dialog.} 
* {12 Dec 2022}		{jrodulfa}		{Added Reason ID, Reason Desc and Operator Image URL.} 
* {14 Dec 2022}		{jrodulfa}		{Convert CrushLeach and MillOre value from Tons to KT.} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {26 Jan 2023}		{jrodulfa}		{Implement Safford data.}
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {01 Feb 2023}		{jrodulfa}		{Change UoM for Off Target from KT to Tons.}
* {06 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{jrodulfa}		{Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TotalMaterialDeliveredToCrusher_Get_OLD] 
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
	
	SELECT
	CrusherLoc as [Name],
	ROUND([CrusherLeach] / 1000.00,1) as CrushLeach,
	ROUND([MillOre] / 1000.00,1) as MillOre,
	ROUND([ct].[Target] / 1000.00,1) Target
	FROM [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_V] [ca] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
	ON [ct].shiftflag = [ca].shiftflag AND [ct].siteflag = [ca].siteflag AND
	   CrusherLoc = [ct].[Location]
	WHERE [ca].shiftflag = @SHIFT
	AND [ca].siteflag = @SITE;

	SELECT TOP 25 PERCENT [tw].TruckID AS [Name],
		   [dialog].Operator AS OperatorName,
		   [dialog].OperatorImageURL AS ImageUrl,
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
		   ROUND([dialog].AvgUseOfAvailibility,0) As AvgUseOfAvailibility,
		   ROUND([dialog].AvgUseOfAvailibilityTarget,0) As AvgUseOfAvailibilityTarget,
		   [tw].Location AS Destination
	FROM [dbo].[CONOPS_LH_TRUCK_TO_WATCH_V] [tw] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_TRUCK_POPUP_V] [dialog] WITH (NOLOCK)
	ON [tw].shiftflag = [dialog].shiftflag AND [tw].siteflag = [dialog].siteflag
	   AND [tw].TruckID = [dialog].TruckID
	WHERE [tw].shiftflag = @SHIFT AND [tw].siteflag = @SITE
		  AND [dialog].Operator <> 'None'
	ORDER BY [tw].[TPRH], [dialog].[Payload], [dialog].AvgUseOfAvailibility
SET NOCOUNT OFF
END

