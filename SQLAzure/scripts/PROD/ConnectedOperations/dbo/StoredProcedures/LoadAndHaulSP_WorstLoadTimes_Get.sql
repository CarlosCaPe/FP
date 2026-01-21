

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_WorstLoadTimes_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_WorstLoadTimes_Get 'CURR', 'MOR', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {29 Dec 2022}		{sxavier}		{Rename field and remove unused quey} 
* {31 Aug 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail}
* {11 Nov 2025}		{dbonardo}		{Split string using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_WorstLoadTimes_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN    

	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');
	INSERT INTO @splitEStat ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');
	INSERT INTO @splitEType ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			ShovelID AS [Name],
			Loading AS DataActual,
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget,1) AS TotalMaterialMinedTarget,
			ROUND(DeltaC,1) AS DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
			Dumping,
			DumpingTarget,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) As NumberOfLoadsTarget,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) AS AssetEfficiencyTarget, 
			ROUND(Payload,0) As Payload,
			PayloadTarget,
			ReasonIdx,
			reasons AS Reason
		FROM BAG.[CONOPS_BAG_SP_WORST_LOAD_TIME_V]
		WHERE shiftflag = @SHIFT
			AND (ShovelID IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
		ORDER BY Loading DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			ShovelID AS [Name],
			Loading AS DataActual,
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget,1) AS TotalMaterialMinedTarget,
			ROUND(DeltaC,1) AS DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
			Dumping,
			DumpingTarget,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) As NumberOfLoadsTarget,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,