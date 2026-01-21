

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_DeltaC_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_DeltaC_Get 'CURR', 'MOR', NULL, NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {7 Dec 2022}		{sxavier}		{Rename field}
* {19 Sep 2023}		{lwasini}		{Add Hourly DeltaC}
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail}
* {18 Feb 2025}     {ggosal1}		{Fix Overall DeltaC Value}
* {10 Nov 2025}     {dbonardo}		{Split String Using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_DeltaC_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN    

BEGIN TRY

	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');
	INSERT INTO @splitEStat ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');
	INSERT INTO @splitEType ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

	IF @SITE = 'BAG'
	BEGIN
		
		SELECT 
			ROUND(a.Actual, 1) AS Actual,
			t.DeltaCTarget AS ShiftTarget
		FROM (
			SELECT
				shiftid,
				shiftflag,
				AVG(deltac) AS Actual
				FROM BAG.CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V
			WHERE shiftflag = @SHIFT
				AND (ShovelId IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
				AND (ShovelType IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
				AND (ShovelStatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			GROUP BY shiftid, shiftflag
		) a
		LEFT JOIN BAG.CONOPS_BAG_OVERALL_DELTA_C_V t
			ON a.shiftflag = t.shiftflag;
		
		SELECT TOP 15 
			ShovelID AS [Name],
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
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
			reasonidx AS ReasonIdx,
			reasons AS Reason
		FROM BAG.[CONOPS_BAG_SP_DELTA_C_V]
		WHERE shiftflag = @SHIFT
			AND (ShovelID IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
		ORDER BY deltac DESC;


		SELECT
		ROUND(AVG(deltac), 1) AS deltac,
		deltac_ts AS TimeinHour
		FROM [BAG].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_DELTAC_V] a
		LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] b
		ON a.shiftflag = b.shiftflag AND a.Equipment = b.ShovelID
		WHERE 
		Equipment IS NOT NULL
		AND a.shiftflag = @SHIFT
		AND (Equipment IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
		AND (eqmttype IN 