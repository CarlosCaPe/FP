

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_WorstHaulRoute_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 30 Nov 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_WorstHaulRoute_Get 'CURR', 'CVE', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {30 Nov 2022}		{jrodulfa}		{Initial Created} 
* {08 Dec 2022}		{jrodulfa}		{Combine to one table and Implement Eqmt and status filter in SP}  
* {12 Dec 2022}		{jrodulfa}		{Added Operator Image URL.} 
* {16 Dec 2022}		{sxavier}		{Rename field} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {11 Jan 2023}		{jrodulfa}		{Implement bagdad data.} 
* {20 Jan 2023}		{jrodulfa}		{Implement safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {02 Deb 2023}		{jrodulfa}		{Implement Chino Data.} 
* {02 Deb 2023}		{mbote}		    {Implement Cerro Verde Data.} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_WorstHaulRoute_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN    
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;
	
	SELECT [worstHaul].TRUCK AS [Name],
		   [dialog].Operator [OperatorName],
		   [dialog].OperatorImageURL AS ImageUrl,
		   [dialog].ReasonId AS ReasonIdx,
		   [dialog].ReasonDesc AS Reason,
		   [worstHaul].SHOVEL AS Shovel,
		   [worstHaul].DUMPNAME AS [Dump],
		   ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]),1) [OffTarget],
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
		   [worstHaul].Location AS Destination
	FROM [dbo].[CONOPS_LH_WORST_HAUL_ROUTE_V] [worstHaul] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_TRUCK_POPUP_V] [dialog] WITH (NOLOCK)
	ON [worstHaul].shiftflag = [dialog].shiftflag AND [worstHaul].siteflag = [dialog].siteflag
	   AND [worstHaul].Truck = [dialog].TruckID
	WHERE [worstHaul].shiftflag = @SHIFT AND [worstHaul].siteflag = @SITE
		  AND ([worstHaul].TRUCK IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		  AND ([worstHaul].[Status] IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
	ORDER BY TOTAL_MIN_OVER_EXPECTED desc

SET NOCOUNT OFF
END

