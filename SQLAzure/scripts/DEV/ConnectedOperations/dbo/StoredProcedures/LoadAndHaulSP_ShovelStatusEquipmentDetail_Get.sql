

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_ShovelStatusEquipmentDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_ShovelStatusEquipmentDetail_Get 'PREV', 'CVE', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_ShovelStatusEquipmentDetail_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN    

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

	SELECT 
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
		Efh,
		EfhTarget,
		ROUND(Payload,0) AS Payload,
		PayloadTarget,
		ROUND(NumberOfLoads,0) As NumberOfLoads,
		ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
		ROUND(AssetEfficiency,0) AS AssetEfficiency,
		ROUND(AssetEfficiencyTarget,0) As AssetEfficiencyTarget,
		TonsPerReadyHour AS TonsPerReadyHour,
		TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
		ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
		ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
		ROUND(HangTime,2) AS HangTime,
		ROUND(HangTimeTarget,2) AS HangTimeTarget,
		reasonidx AS ReasonIdx,
		reasons AS Reason,
		eqmtcurrstatus
	FROM BAG.[CONOPS_BAG_SP_DELTA_C_V]
	WHERE shiftflag = @SHIFT
		AND (ShovelID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

	SELECT 
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
		Efh,
		EfhTarget,
		ROUND(Payload,0) AS Payload,
		PayloadTarget,
		ROUND(NumberOfLoads,0) As NumberOfLoads,
		ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
		ROUND(AssetEfficiency,0) AS AssetEfficiency,
		ROUND(AssetEfficiencyTarget,0) As AssetEfficiencyTarget,
		TonsPerReadyHour AS TonsPerReadyHour,
		TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
		ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
		ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
		ROUND(HangTime,2) AS HangTime,
		ROUND(HangTimeTarget,2) AS HangTimeTarget,
		reasonidx AS ReasonIdx,
		reasons AS Reason,
		eqmtcurrstatus
	FROM CER.[CONOPS_CER_SP_DELTA_C_V]
	WHERE shiftflag = @SHIFT
		AND (ShovelID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

	SELECT 
		ShovelID AS [Name],
		Operator AS OperatorName,
		OperatorImageURL as ImageUrl,
		RIGHT('0000000000' + [OperatorId], 10) OperatorId,
