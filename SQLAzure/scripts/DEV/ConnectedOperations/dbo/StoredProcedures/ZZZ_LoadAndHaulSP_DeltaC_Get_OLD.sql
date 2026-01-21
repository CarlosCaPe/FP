






/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_DeltaC_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_DeltaC_Get 'CURR', 'CVE', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {7 Dec 2022}		{sxavier}		{Rename field}
* {24 Jan 2023}		{jrodulfa}		{Implement Safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {01 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {03 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_DeltaC_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN    

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			ROUND(Actual,1) AS Actual,
			ShiftTarget
			FROM (
				SELECT 
				AVG(DeltaC) AS Actual,
				DeltaCTarget AS ShiftTarget
				FROM BAG.[CONOPS_BAG_SP_DELTA_C_V]
				WHERE shiftflag = @SHIFT
				AND (ShovelID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
				AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
				GROUP BY DeltaCTarget
				) a
		WHERE Actual IS NOT NULL;
		
		SELECT TOP 15 
			ShovelID AS [Name],
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
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
			TonsPerReadyHour/1000 AS TonsPerReadyHour,
			TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
			reasonidx AS ReasonIdx,
			reasons AS Reason
		FROM BAG.[CONOPS_BAG_SP_DELTA_C_V]
		WHERE shiftflag = @SHIFT
			AND (ShovelID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		ORDER BY deltac DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			ROUND(Actual,1) AS Actual,
			ShiftTarget
			FROM (
				SELECT 
				AVG(DeltaC) AS Actual,
				DeltaCTarget AS ShiftTarget
				FROM CER.[CONOPS_CER_SP_DELTA_C_V]
				WHERE shiftflag = @SHIFT
				AND (ShovelID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
				AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
				GROUP BY DeltaCTarget
				) a
		WHERE Actual IS NOT NULL;
		
		SELECT TOP 15 
			ShovelID AS [Name],
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
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
			TonsPerReadyHour/1000 AS TonsPerReadyHour,
			TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
			reasonidx AS R