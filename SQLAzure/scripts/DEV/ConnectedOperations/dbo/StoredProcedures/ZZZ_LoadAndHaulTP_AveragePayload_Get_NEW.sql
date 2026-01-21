






/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_AveragePayload_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 01 DEC 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_AveragePayload_Get 'CURR', 'MOR', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {01 Dec 2022}		{jrodulfa}		{Initial Created} 
* {02 Dec 2022}		{sxavier}		{Rename field and select only needed data} 
* {08 Dec 2022}		{jrodulfa}		{Implement Eqmt filter in SP}  
* {12 Dec 2022}		{jrodulfa}		{Added Operator Image URL.} 
* {21 Dec 2022}		{jrodulfa}		{Added data for Truck Detail Dialogbox.} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {20 Jan 2023}		{jrodulfa}		{Implement Safford Data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {31 Jan 2023}		{mbote}		    {Implement Cerro Verde Data.}
* {02 Deb 2023}		{jrodulfa}		{Implement Chino Data.} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_AveragePayload_Get_NEW] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN          
	
EXEC (

'SELECT ROUND(AVG_Payload,0) [Actual],'
+' Target [ShiftTarget]'
+' FROM '+@SITE+'.[CONOPS_'+@SITE+'_OVERALL_AVG_PAYLOAD_V]'
+' WHERE shiftflag = '''+@SHIFT+''' AND siteflag = '''+@SITE+''';'

+' SELECT [pl].TRUCK AS [Name],'
+' [dialog].Operator AS [OperatorName],'
+' [dialog].OperatorImageURL AS [ImageURL],'
+' ROUND([pl].AVG_Payload,0) AS Actual,'
+' CAST([pl].Target AS DECIMAL(10)) AS [Target],'
+' [dialog].ReasonId AS ReasonIdx,'
+' [dialog].ReasonDesc AS Reason,'
+' ROUND([dialog].[Payload],0) AS Payload,'
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
+' [pl].Location AS Destination'
+' FROM '+@SITE+'.[CONOPS_'+@SITE+'_TP_AVG_PAYLOAD_V] [pl]'
+' LEFT JOIN '+@SITE+'.[CONOPS_'+@SITE+'_TRUCK_POPUP_V] [dialog]'
+' ON [pl].shiftflag = [dialog].shiftflag AND [pl].siteflag = [dialog].siteflag'
+' AND [pl].Truck = [dialog].TruckID'
+' WHERE [pl].shiftflag = '''+@SHIFT+''' AND [pl].siteflag = '''+@SITE+''''
+' AND ([pl].TRUCK IN (SELECT TRIM(value) FROM STRING_SPLIT('''+@EQMT+''', '','')) OR ISNULL('''+@EQMT+''', '''') = '''')'
+' AND ([Status] IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER('''+@STATUS+'''), '','')) OR ISNULL('''+@STATUS+''', '''') = '''')'
+' ORDER BY [pl].TRUCK'

);

END

