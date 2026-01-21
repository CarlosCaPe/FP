

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_ShovelAssetEfficiency_Get
* PURPOSE	: Get data for Truck Asset Efficiency Card
* NOTES		: 
* CREATED	: jrodulfa, 06 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_ShovelAssetEfficiency_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {06 Dec 2022}		{jrodulfa}		{Initial Created} 
* {08 Dec 2022}		{jrodulfa}		{Set operator name to Upper Case} 
* {08 Dec 2022}		{sxavier}		{Rename field} 
* {12 Dec 2022}		{jrodulfa}		{Added Operator Image URL.} 
* {03 Jan 2023}		{jrodulfa}		{Added Detail for dialog.} 
* {10 Jan 2023}		{jrodulfa}		{Added new item in Shovel Dialog} 
* {11 Jan 2023}		{jrodulfa}		{Implement Bagdad data and simplify query} 
* {25 Jan 2023}		{jrodulfa}		{Implement Safford} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {03 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_ShovelAssetEfficiency_Get_OLD] 
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
	
	SELECT ROUND([ae].overall_efficiency,0) AS OverallEfficiency, 
		   ROUND([ae].efficiency,0) AS Efficiency, 
		   ROUND([ae].[availability],0) AS [Availability], 
		   ROUND([ae].use_of_availability,0) AS Utilization
	FROM [dbo].[CONOPS_LH_SHOVEL_ASSET_EFFICIENCY_V] [ae] WITH (NOLOCK)
	WHERE [ae].shiftflag = @SHIFT AND
		  [ae].siteflag = @SITE;

	-- Shovel Down
	SELECT [sd].ShovelID [Name],
		   [dialog].Operator [OperatorName],
		   [dialog].OperatorImageURL [ImageUrl],
		   ROUND([Actualvalue]/1000.0,1) AS DataActual,
		   ROUND(ShiftTarget/1000.0,1) AS DataTarget,
		   [dialog].ReasonId AS ReasonIdx,
		   [dialog].ReasonDesc AS Reason,
		   ROUND([Actualvalue] / 1000.0,1) AS TotalMaterialMined,
		   ROUND(ShiftTarget / 1000.0,1) AS TotalMaterialMinedTarget,
		   ROUND([OffTarget] / 1000.0,1) OffTarget,
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
		   ROUND([dialog].NumberOfLoads,0) As NumberOfLoads,
		   ROUND([dialog].NumberOfLoadsTarget,0) As NumberOfLoadsTarget,
		   ROUND([dialog].AssetEfficiency,0) AS AssetEfficiency,
		   ROUND([dialog].AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
		   [dialog].TonsPerReadyHour/1000 AS TonsPerReadyHour,
		   [dialog].TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
		   ROUND([dialog].Payload,0) AS Payload,
		   [dialog].PayloadTarget
	FROM [dbo].[CONOPS_LH_SHOVEL_DOWN_V] [sd] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_SHOVEL_POPUP_V] [dialog] WITH (NOLOCK)
	ON [sd].shiftflag = [dialog].shiftflag AND [sd].siteflag = [dialog].siteflag
	   AND [sd].ShovelID = [dialog].[ShovelID]
	WHERE [sd].shiftflag = @SHIFT AND
		  [sd].siteflag = @SITE; 

	-- Operator Has Late Start
	SELECT
		eqmtid AS [Name],
		UPPER(OperatorName) [OperatorName],
		FirstLoginTime AS [Time],
		s.Region,
		[ls].OperatorImageURL AS ImageURL,
		DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
		[FirstLoad] AS FirstLoadLateTime,
		DATEADD(MINUTE, [FirstLoad], ShiftStartDateTime) [FirstLoadLateDate]
	FROM [dbo].[CONOPS_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	ON [ls].shiftflag = [s].shiftflag AND [ls].siteflag = [s].siteflag
	   AND eqmtid = [s].ShovelID
	WHERE [ls].shiftflag = @SHIFT AND [