






/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_AverageLoadTime_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 15 Sep 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_AverageLoadTime_Get 'PREV', 'ABR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*  
* {15 Sep 2023}		{ggosal1}		{Replicated from Shovel Productivity}
* {04 Dec 2023}		{lwasini}		{Add OperatorId}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_AverageLoadTime_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN    
BEGIN TRY	IF @SITE = 'BAG'
	BEGIN

		SELECT
			AVG(LoadTime) AS AvgLoadTime
			FROM BAG.[CONOPS_BAG_SP_AVG_LOAD_TIME_V]
		WHERE shiftflag = @SHIFT
	 
		SELECT
			Excav AS [Name],
			Operator AS OperatorName,
			ROUND(LoadTime,1) AS DataActual,
			LoadTimeTarget AS [DataTarget],
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND(deltac,1) AS DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
			Dumping,
			DumpingTarget,
			Efh,
			EfhTarget,
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ReasonIdx,
			reasons AS Reason
		FROM BAG.[CONOPS_BAG_SP_AVG_LOAD_TIME_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			AVG(LoadTime) AS AvgLoadTime
			FROM CER.[CONOPS_CER_SP_AVG_LOAD_TIME_V]
		WHERE shiftflag = @SHIFT
	 
		SELECT
			Excav AS [Name],
			Operator AS OperatorName,
			ROUND(LoadTime,1) AS DataActual,
			LoadTimeTarget AS [DataTarget],
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND(deltac,1) AS DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
			Dumping,
			DumpingTarget,
			Efh,
			EfhTarget,
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ReasonIdx,
			reasons AS Reason
		FROM CER.[CONOPS_CER_SP_AVG_LOAD_TIME_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			AVG(LoadTime) AS AvgLoadTime
			FROM CHI.[CONOPS_CHI_SP_AVG_LOAD_TIME_V]
		WHERE shiftflag = @SHIFT
	 
		SELECT
			Excav AS [Name],
			Operator AS OperatorName,
			ROUND(LoadTime,1) AS DataActual,
			LoadTimeTarget AS [DataTarget],
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined/100