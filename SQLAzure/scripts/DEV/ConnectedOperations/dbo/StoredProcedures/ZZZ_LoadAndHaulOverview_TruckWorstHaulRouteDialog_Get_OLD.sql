



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
* {11 Jan 2023}		{jrodulfa}		{Implement bagdad data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {03 Feb 2023}		{jrodulfa}		{Implement Chino data}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckWorstHaulRouteDialog_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

	DECLARE @SCHEMA VARCHAR(4);

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SET @SCHEMA = CASE @SITE
					WHEN 'CMX' THEN 'CLI'
					ELSE @SITE
				END;
EXEC (
'SELECT [worstHaul].TRUCK AS [Name],'
+' [dialog].Operator [OperatorName],'
+' [dialog].OperatorImageURL AS ImageUrl,'
+' [dialog].ReasonId AS ReasonIdx,'
+' [dialog].ReasonDesc AS Reason,'
+' [worstHaul].SHOVEL AS Shovel,'
+' [worstHaul].DUMPNAME AS [Dump],'
+' ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]) / 1000.00,1) [OffTarget],'
+' ROUND([dialog].[Payload],0) AS [Payload],'
+' [dialog].[PayloadTarget],'
+' ROUND([dialog].[TotalMaterialDelivered],1) AS [TotalMaterialDelivered],'
+' ROUND([dialog].[TotalMaterialDeliveredTarget],1) AS [TotalMaterialDeliveredTarget],'
+' ROUND([dialog].DeltaC,1) AS DeltaC,'
+' [dialog].DeltaCTarget,'
+' [dialog].IdleTime,'
+' [dialog].IdleTimeTarget,'
+' [dialog].Spotting,'
+' [dialog].SpottingTarget,'
+' [dialog].Loading,'
+' [dialog].LoadingTarget,'
+' [dialog].Dumping,'
+' [dialog].DumpingTarget,'
+' [dialog].Efh,'
+' [dialog].EfhTarget,'
+' [dialog].[DumpsAtStockpile],'
+' [dialog].DumpsAtStockpileTarget,'
+' [dialog].DumpsAtCrusher,'
+' [dialog].DumpsAtCrusherTarget,'
+' ROUND([dialog].AvgUseOfAvailibility,0) AS AvgUseOfAvailibility,'
+' ROUND([dialog].AvgUseOfAvailibilityTarget,0) AS AvgUseOfAvailibilityTarget,'
+' [worstHaul].Location AS Destination'
+' FROM '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_WORST_HAUL_ROUTE_V] [worstHaul] WITH (NOLOCK)'
+' LEFT JOIN '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_TRUCK_POPUP_V] [dialog] WITH (NOLOCK)'
+' ON [worstHaul].shiftflag = [dialog].shiftflag AND [worstHaul].siteflag = [dialog].siteflag'
+' AND [worstHaul].TRUCK = [dialog].TruckID'
+' WHERE [worstHaul].shiftflag = '''+@SHIFT+''''
+' AND [worstHaul].siteflag = '''+@SITE+''''
+' ORDER BY TOTAL_MIN_OVER_EXPECTED desc'

);

END

