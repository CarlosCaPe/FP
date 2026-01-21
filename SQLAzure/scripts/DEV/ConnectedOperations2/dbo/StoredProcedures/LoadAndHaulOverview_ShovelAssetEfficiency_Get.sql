
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_ShovelAssetEfficiency_Get
* PURPOSE	: Get data for Truck Asset Efficiency Card
* NOTES		: 
* CREATED	: jrodulfa, 06 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_ShovelAssetEfficiency_Get 'PREV', 'TYR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {06 Dec 2022}		{jrodulfa}		{Initial Created} 
* {08 Dec 2022}		{jrodulfa}		{Set operator name to Upper Case} 
* {08 Dec 2022}		{sxavier}		{Rename field} 
* {12 Dec 2022}		{jrodulfa}		{Added Operator Image URL.} 
* {03 Jan 2023}		{jrodulfa}		{Added Detail for dialog.} 
* {10 Jan 2023}		{jrodulfa}		{Added new item in Shovel Dialog} 
* {25 May 2023}		{jrodulfa}		{Updated the logic for First Load Data}
* {06 Sep 2023}		{ggosal1}   	{Add Asset Efficiency Target}
* {28 Nov 2023}		{lwasini}   	{Add OperatorId}
* {10 jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR} 
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail} 
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_ShovelAssetEfficiency_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
BEGIN TRY	IF @SITE = 'BAG'
	BEGIN

		--Asset Efficiency
		SELECT 
			ROUND(ISNULL([ae].overall_efficiency,0),0) AS OverallEfficiency, 
			ROUND(ISNULL([ae].efficiency,0),0) AS Efficiency,
			ROUND(ISNULL([aet].TruckEfficiencyTarget,0),0) AS EfficiencyTarget,
			ROUND(ISNULL([ae].[availability],0),0) AS [Availability], 
			ROUND(ISNULL([aet].TruckAvailabilityTarget,0),0) AS [AvailabilityTarget], 
			ROUND(ISNULL([ae].use_of_availability,0),0) AS Utilization,
			ROUND(ISNULL([aet].TruckUtilizationTarget,0),0) AS UtilizationTarget
		FROM BAG.[CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_V] [ae] WITH (NOLOCK)
		LEFT JOIN [BAG].[CONOPS_BAG_EQMT_ASSET_EFFICIENCY_TARGET_V] [aet]
			ON [ae].siteflag = [aet].SITEFLAG
		WHERE [ae].shiftflag = @SHIFT 
	
		 -- Shovel Down
		SELECT
			[sd].ShovelID [Name],
			[dialog].Operator [OperatorName],
			[dialog].OperatorImageURL [ImageUrl],
			RIGHT('0000000000' + [dialog].[OperatorId], 10) OperatorId,
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
			[dialog].TonsPerReadyHour AS TonsPerReadyHour,
			[dialog].TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND([dialog].TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND([dialog].TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND([dialog].HangTime,2) AS HangTime,
			ROUND([dialog].HangTimeTarget,2) AS HangTimeTarget,
			ROUND([dialog].Payload,0) AS Payload,
			[dialog].PayloadTarget
		FROM BAG.[CONOPS_BAG_SHOVEL_DOWN_V] [sd] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_SHOVEL_POPUP] [dialog] WITH (NOLOCK)
			ON [sd].shiftflag = [dialog].shiftflag
			AND [sd].ShovelID = [dialog].[ShovelID]
		WHERE [sd].shiftflag = @SHIFT
	
		-- Operator Has Late Start
		SELECT
			eqmtid AS [Name],
			UPPER(OperatorName) [