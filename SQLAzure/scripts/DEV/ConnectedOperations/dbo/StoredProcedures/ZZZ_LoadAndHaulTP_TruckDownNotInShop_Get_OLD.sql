

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckDownNotInShop_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 01 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckDownNotInShop_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {01 Dec 2022}		{jrodulfa}		{Initial Created} 
* {08 Dec 2022}		{sxavier}		{Combine to one table} 
* {08 Dec 2022}		{jrodulfa}		{Implement Eqmt filter in SP and Added Truck Detail Dialog.}
* {12 Dec 2022}		{jrodulfa}		{Added Reason ID, Reason Desc and Operator Image URL.}
* {20 Dec 2022}		{jrodulfa}		{Remove Eqmt filter in SP as requested by Brian.}
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {10 Jan 2023}		{jrodulfa}		{Implement Bagdad data.} 
* {20 Jan 2023}		{jrodulfa}		{Implement Safford data.} 
* {31 Jan 2023}		{mbote}		    {Implement Cerro Verde data.} 
* {02 Deb 2023}		{jrodulfa}		{Implement Chino Data.} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TruckDownNotInShop_Get_OLD] 
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
		   ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]),1) [OffTarget],
		   [dialog].Operator AS [OperatorName],
		   [dialog].OperatorImageURL AS ImageUrl,
		   CONVERT(VARCHAR(5), StatusStart, 108) AS [Time],
		   [dialog].ReasonId AS ReasonIdx,
		   [dialog].ReasonDesc AS Reason,
		   Region,
		   ROUND([dialog].[Payload],0) AS Payload,
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
		  AND [truckDown].TruckID IS NOT NULL

SET NOCOUNT OFF
END

