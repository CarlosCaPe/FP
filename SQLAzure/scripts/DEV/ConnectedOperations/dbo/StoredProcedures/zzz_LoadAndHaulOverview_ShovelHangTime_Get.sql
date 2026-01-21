




/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_ShovelHangTime_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 15 Sep 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_ShovelHangTime_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Sep 2023}		{ggosal1}		{Replicated from Shovel Productivity}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_LoadAndHaulOverview_ShovelHangTime_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			AVG(Hangtime) AS AvgHangTime
		FROM [bag].[CONOPS_BAG_EQMT_SHOVEL_V] [a]
		LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] [b]
			ON [a].shiftflag = [b].shiftflag 
			AND [a].shovelid = [b].ShovelID
		WHERE [a].shiftflag = @SHIFT

		SELECT
			[a].ShovelID AS [Name],
			[a].Hangtime AS DataActual,
			[a].HangtimeTarget AS DataTarget,
			[b].Operator AS OperatorName,
			[b].OperatorImageURL as ImageUrl,
			ROUND([b].TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND([b].TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND([b].DeltaC,1) As DeltaC,
			[b].DeltaCTarget,
			[b].IdleTime,
			[b].IdleTimeTarget,
			[b].Spotting,
			[b].SpottingTarget,
			[b].Loading,
			[b].LoadingTarget,
			[b].Dumping,
			[b].DumpingTarget,
			ROUND([b].Payload,0) AS Payload,
			[b].PayloadTarget,
			ROUND([b].NumberOfLoads,0) AS NumberOfLoads,
			ROUND([b].NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND([b].AssetEfficiency,0) AS AssetEfficiency,
			ROUND([b].AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			[b].TonsPerReadyHour/1000 AS TonsPerReadyHour,
			[b].TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
			[c].ReasonID AS ReasonIdx,
			[c].ReasonDesc AS Reason
		FROM [bag].[CONOPS_BAG_EQMT_SHOVEL_V] [a]
		LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_POPUP_V] [b]
		ON [a].shiftflag = [b].shiftflag AND [a].shovelid = [b].ShovelID
		LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] [c]
		ON [a].shiftflag = [c].shiftflag AND [a].shovelid = [c].ShovelID
		WHERE [a].shiftflag = @SHIFT
		ORDER BY [a].Hangtime DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			AVG(Hangtime) AS AvgHangTime
		FROM [CER].[CONOPS_CER_EQMT_SHOVEL_V] [a]
		LEFT JOIN [CER].[CONOPS_CER_SHOVEL_INFO_V] [b]
			ON [a].shiftflag = [b].shiftflag 
			AND [a].shovelid = [b].ShovelID
		WHERE [a].shiftflag = @SHIFT

		SELECT
			[a].ShovelID AS [Name],
			[a].Hangtime AS DataActual,
			[a].HangtimeTarget AS DataTarget,
			[b].Operator AS OperatorName,
			[b].OperatorImageURL as ImageUrl,
			ROUND([b].TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND([b].TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND([b].DeltaC,1) As DeltaC,
			[b].DeltaCTarget,
			[b].IdleTime,
			[b].IdleTimeTarget,
			[b].Spotting,
			[b].SpottingTarget,
			[b].Loading,
			[b].LoadingTarget,
			[b].Dumping,
			[b].DumpingTarget,
			ROUND([b].Payload,0) AS Payload,
			[b].PayloadTarget,
			ROUND([b].NumberOfLoads,0) AS NumberOfLoads,
			ROUND([b].NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND([b].AssetEfficiency,0) AS AssetEfficiency,
			ROUND([b].AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			[b].TonsPerReadyHour/1000 AS TonsPerReadyHour,
			[b].TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
			[c].ReasonID AS ReasonIdx,
			[c].ReasonDesc AS Reason
		FROM [cer].[CONOPS_CER_EQMT_SHOVEL_V] [a]
		LEFT JOIN [cer].[CONOPS_CER_SHOVEL_POPUP_V] [b]
		ON [a].shiftflag = [b].shiftflag AND [a].shovelid = [b].ShovelID
		LEFT JOIN [cer].[CONOPS_CER_SHOVEL_INFO_V] [c]
		ON [a].shiftflag = [c].shiftflag AND [a].shovelid = [c].ShovelID
		WHERE [a].shiftflag = @SHIFT
		ORDER BY [a].Hangtime DESC;

	END

	ELSE IF @SITE = '