



/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_ShovelDown_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 19 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_ShovelDown_Get 'CURR', 'SAM'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Dec 2022}		{jrodulfa}		{Initial Created} 
* {21 Dec 2022}		{sxavier}		{Rename field} 
* {10 Jan 2023}		{jrodulfa}		{Added new item in Shovel Dialog} 
* {10 Jan 2023}		{jrodulfa}		{Implemented Bagdad data and simplify query} 
* {24 Jan 2023}		{jrodulfa}		{Implemented Safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {31 Jan 2023}		{jrodulfa}		{Implemented Chino data.} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_ShovelDown_Get_OLD] 
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
	
	SELECT [sd].ShovelID [Name],
		   [dialog].Operator [OperatorName],
		   [dialog].OperatorImageURL [ImageUrl],
		   [dialog].ReasonId AS ReasonIdx,
		   [dialog].ReasonDesc AS Reason,
		   ROUND([Actualvalue] / 1000,1) AS TotalMaterialMined,
		   ROUND(ShiftTarget / 1000,1) AS TotalMaterialMinedTarget,
		   ROUND([OffTarget] / 1000,1) OffTarget,
		   ROUND([dialog].DeltaC,1) As DeltaC,
		   [dialog].DeltaCTarget,
		   [dialog].IdleTime,
		   [dialog].IdleTimeTarget,
		   [dialog].Spotting,
		   [dialog].SpottingTarget,
		   [dialog].Loading,
		   [dialog].LoadingTarget,
		   [dialog].Dumping,
		   [dialog].DumpingTarget,
		   ROUND([dialog].NumberOfLoads,0) AS NumberOfLoads,
		   ROUND([dialog].NumberOfLoadsTarget,0) As NumberOfLoadsTarget,
		   ROUND([dialog].AssetEfficiency,0) AS AssetEfficiency,
		   ROUND([dialog].AssetEfficiencyTarget,0) As AssetEfficiencyTarget,
		   [dialog].TonsPerReadyHour/1000 AS TonsPerReadyHour,
		   [dialog].TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
		   ROUND([dialog].Payload,0) AS Payload,
		   [dialog].PayloadTarget
	FROM [dbo].[CONOPS_LH_SHOVEL_DOWN_V] [sd] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_SHOVEL_POPUP_V] [dialog] WITH (NOLOCK)
	ON [sd].shiftflag = [dialog].shiftflag AND [sd].siteflag = [dialog].siteflag
	   AND [sd].ShovelID = [dialog].[ShovelID]
	WHERE [sd].shiftflag = @SHIFT AND
		  [sd].siteflag = @SITE

SET NOCOUNT OFF
END

