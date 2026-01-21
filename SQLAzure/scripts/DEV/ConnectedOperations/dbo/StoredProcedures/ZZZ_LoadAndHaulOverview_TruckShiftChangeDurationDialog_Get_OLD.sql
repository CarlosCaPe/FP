


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckShiftChangeDurationDialog_Get
* PURPOSE	: Get data for Truck Shift Change Duration Dialog
* NOTES		: 
* CREATED	: sxavier, 13 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckShiftChangeDurationDialog_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Dec 2022}		{sxavier}		{Initial Created} 
* {04 Jan 2023}		{jrodulfa}		{Implement Truck Detail dialog.} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {11 Jan 2023}		{jrodulfa}		{Implement Bagdad data.} 
* {25 Jan 2023}		{jrodulfa}		{Implement Safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {06 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckShiftChangeDurationDialog_Get_OLD] 
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
	
	SELECT [sc].TruckID AS [Name],
		   [dialog].Operator AS OperatorName,
		   [dialog].OperatorImageURL AS ImageURL,
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
		   [dialog].AvgUseOfAvailibility,
		   [dialog].AvgUseOfAvailibilityTarget,
		   [dialog].Location AS Destination
	FROM [dbo].[CONOPS_LH_TRUCK_SHIFT_CHANGE_DIALOG_V] [sc] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_TRUCK_POPUP_V] [dialog] WITH (NOLOCK)
	ON [sc].shiftflag = [dialog].shiftflag AND [sc].siteflag = [dialog].siteflag
	   AND [sc].TruckID = [dialog].TruckID
	WHERE [sc].shiftflag = @SHIFT
		AND [sc].siteflag = @SITE
	ORDER BY [ChangeDuration] desc;

		  
SET NOCOUNT OFF
END

