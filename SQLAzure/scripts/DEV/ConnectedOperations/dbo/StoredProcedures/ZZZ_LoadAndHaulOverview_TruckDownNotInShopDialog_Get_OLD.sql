



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
* {10 Jan 2023}		{jrodulfa}		{Implement Bagdad data.} 
* {20 Jan 2023}		{jrodulfa}		{Implement Safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {31 Jan 2023}		{mbote}		    {Change CER sitecode to CVE.}
* {31 Jan 2023}		{mbote}		    {Implement Cerrro Verde data.}
* {03 Feb 2023}		{jrodulfa}		{Implement Chino data}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckDownNotInShopDialog_Get_OLD] 
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

	SELECT [truckDown].TruckID AS [Name],
		   ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]) / 1000.00,1) [OffTarget],
		   [dialog].Operator AS [OperatorName],
		   [dialog].OperatorImageURL AS ImageUrl,
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
		   ROUND([dialog].AvgUseOfAvailibility,0) AS AvgUseOfAvailibility,
		   ROUND([dialog].AvgUseOfAvailibilityTarget,0) AS AvgUseOfAvailibilityTarget,
		   [truckDown].Location AS Destination
	FROM [dbo].[CONOPS_LH_TRUCK_DOWN_NOT_IN_SHOP_V] [truckDown] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_TRUCK_POPUP_V] [dialog] WITH (NOLOCK)
	ON [truckDown].shiftflag = [dialog].shiftflag AND [truckDown].siteflag = [dialog].siteflag
	   AND [truckDown].TruckID = [dialog].TruckID
	WHERE [truckDown].shiftflag = @SHIFT AND [truckDown].siteflag = @SITE
		  AND [truckDown].TruckID IS NOT NULL;

SET NOCOUNT OFF
END

