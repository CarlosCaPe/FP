

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_NrOfLoad_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 15 Sep 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_NrOfLoad_Get 'PREV', 'BAG'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Sep 2023}		{ggosal1}		{Replicated from Shovel Productivity}
* {03 Nov 2023}		{ggosal1}		{Change to Number of Overloards}
* {12 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR} 
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_NrOfLoad_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN    
BEGIN TRY	IF @SITE = 'BAG'
	BEGIN

		SELECT
			ROUND(SUM(Overload),2) AS NumberOfLoads
			FROM BAG.[CONOPS_BAG_SHOVEL_OVERLOAD_V]
		WHERE shiftflag = @SHIFT

 
		SELECT
			o.ShovelID AS [Name],
			ROUND(Overload,0) AS DataActual,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
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
			TonsPerReadyHour/1000 AS TonsPerReadyHour,
			TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
			ReasonId,
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
			ROUND(SUM(Overload),2) AS NumberOfLoads
			FROM CER.[CONOPS_CER_SHOVEL_OVERLOAD_V]
		WHERE shiftflag = @SHIFT
 
		SELECT
			o.ShovelID AS [Name],
			ROUND(Overload,0) AS DataActual,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
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
			TonsPerReadyHour/1000 AS TonsPerReadyHour,
			TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
			ReasonId,
			reasonDESC AS Reason
		FROM [CER].[CONOPS_CER_SHOVEL_OVERLOAD_V] o
		LEFT JOIN [CER].[CONOPS_CER_SHOVEL_POPUP] p WITH (NOLOCK)
			ON o.shiftflag = p.shiftflag AND o.ShovelId = p.ShovelId
		WHERE o.shiftflag = @SHIFT
			AND Overload > 0
		ORDER BY Overload DESC;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			ROUND(SUM(Overload),2) AS NumberOfLoads
			FROM CHI.[CONOPS_CHI_SHOVEL_OVERLOAD_V]
		WHERE shiftflag = @SHIFT
 
		SELECT
			o.ShovelID AS [Name],
			ROUND(Overload,0) AS DataActual,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			ROUND(TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND(DeltaC,1) As De