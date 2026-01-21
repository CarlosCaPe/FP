
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_ShovelOverload_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 03 Nov 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_ShovelOverload_Get 'PREV', 'BAG'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*  
* {03 Nov 2023}		{ggosal1}		{Initial Created}
* {07 Nov 2023}		{sxavier}		{Rename ReasonId to ReasonIdx}
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail} 
* {23 Jan 2024}		{ggosal1}		{Add Truck and Tonnage} 
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_ShovelOverload_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN    
BEGIN TRY	IF @SITE = 'BAG'
	BEGIN

		SELECT
			SUM(Overload) AS OverloadCount
			FROM BAG.[CONOPS_BAG_SHOVEL_OVERLOAD_V]
		WHERE shiftflag = @SHIFT

 
		SELECT
			o.ShovelID AS [Name],
			TruckId,
			Tonnage,
			ROUND(Overload,0) AS Overload,
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND(TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND(DeltaC,1) As DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
			Dumping,
			DumpingTarget,
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ReasonId AS ReasonIdx,
			reasonDESC AS Reason
		FROM [BAG].[CONOPS_BAG_SHOVEL_OVERLOAD_V] o
		LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_POPUP] p WITH (NOLOCK)
			ON o.shiftflag = p.shiftflag AND o.ShovelId = p.ShovelId
		WHERE o.shiftflag = @SHIFT
			AND Overload > 0
		ORDER BY Overload DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			SUM(Overload) AS OverloadCount
			FROM CER.[CONOPS_CER_SHOVEL_OVERLOAD_V]
		WHERE shiftflag = @SHIFT
 
		SELECT
			o.ShovelID AS [Name],
			TruckId,
			Tonnage,
			ROUND(Overload,0) AS Overload,
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND(TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND(DeltaC,1) As DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
			Dumping,
			DumpingTarget,
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ReasonId AS ReasonIdx,
			reasonDESC AS Reason
		FROM [CER].[CONOPS_CER_SHOVEL_OVERLOAD_V] o
		LEFT JOIN [CER].[CONOPS_CER_SHOVEL_POPUP] p WITH (NOLOCK)
			ON o.shiftflag = p.shi