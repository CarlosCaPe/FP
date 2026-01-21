








/******************************************************************  
* PROCEDURE	: dbo.Equipment_Shovel_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 21 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Shovel_Get 'CURR', 'TYR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Mar 2023}		{lwasini}		{Initial Created}  
* {30 Aug 2023}		{lwasini}		{Add Hangtime & TonsMoved}
* {26 Oct 2023}		{ggosal1}		{Add AE & Availability}
* {12 Jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Shovel_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN  

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
		shovelid,
		[location],
		operator,
		operatorimageURL,
		ROUND(TonsPerReadyHour,0) TonsPerReadyHour,
		ROUND(TonsPerReadyHourTarget,0) TonsPerReadyHourTarget,
		ROUND(TotalMaterialMined,1) AS TonsMined,
		ROUND(TotalMaterialMinedTarget,1) AS TonsMinedTarget,
		ROUND(TotalMaterialMoved,1) AS TonsMoved,
		ROUND(TotalMaterialMovedTarget,1) AS TonsMovedTarget,
		ROUND(payload,0) payload,
		PayloadTarget,
		ROUND(NumberOfLoads,0) NumberOfLoads,
		ROUND(NumberOfLoadsTarget,0) NumberOfLoadsTarget,
		ROUND(Loading,2) Loading,
		LoadingTarget,
		ROUND(Spotting,2) Spotting,
		SpottingTarget,
		ROUND(IdleTime,2) IdleTime,
		IdleTimeTarget,
		Hangtime,
		HangtimeTarget,
		ToothMetrics,
		ROUND(AssetEfficiency,0) AssetEfficiency,
		ROUND(AssetEfficiencyTarget,0) AssetEfficiencyTarget,
		ROUND(Availability,0) Availability,
		ROUND(AvailabilityTarget,0) AvailabilityTarget,
		ROUND(UseOfAvailability,0) UseOfAvailability,
		ROUND(UseOfAvailabilityTarget,0) UseOfAvailabilityTarget,
		statusname,
		reasonid,
		reasondesc,
		TimeInState
		FROM [BAG].[CONOPS_BAG_EQMT_SHOVEL_V]
		WHERE 
		shiftflag = @SHIFT
	END


	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
		shovelid,
		[location],
		operator,
		operatorimageURL,
		ROUND(TonsPerReadyHour,0) TonsPerReadyHour,
		ROUND(TonsPerReadyHourTarget,0) TonsPerReadyHourTarget,
		ROUND(TotalMaterialMined,1) AS TonsMined,
		ROUND(TotalMaterialMinedTarget,1) AS TonsMinedTarget,
		ROUND(TotalMaterialMoved,1) AS TonsMoved,
		ROUND(TotalMaterialMovedTarget,1) AS TonsMovedTarget,
		ROUND(payload,0) payload,
		PayloadTarget,
		ROUND(NumberOfLoads,0) NumberOfLoads,
		ROUND(NumberOfLoadsTarget,0) NumberOfLoadsTarget,
		ROUND(Loading,2) Loading,
		LoadingTarget,
		ROUND(Spotting,2) Spotting,
		SpottingTarget,
		ROUND(IdleTime,2) IdleTime,
		IdleTimeTarget,
		Hangtime,
		HangtimeTarget,
		ToothMetrics,
		ROUND(AssetEfficiency,0) AssetEfficiency,
		ROUND(AssetEfficiencyTarget,0) AssetEfficiencyTarget,
		ROUND(Availability,0) Availability,
		ROUND(AvailabilityTarget,0) AvailabilityTarget,
		ROUND(UseOfAvailability,0) UseOfAvailability,
		ROUND(UseOfAvailabilityTarget,0) UseOfAvailabilityTarget,
		statusname,
		reasonid,
		reasondesc,
		TimeInState
		FROM [CHI].[CONOPS_CHI_EQMT_SHOVEL_V]
		WHERE 
		shiftflag = @SHIFT
	END


	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
		shovelid,
		[location],
		operator,
		operatorimageURL,
		ROUND(TonsPerReadyHour,0) TonsPerReadyHour,
		ROUND(TonsPerReadyHourTarget,0) TonsPerReadyHourTarget,
		ROUND(TotalMaterialMined,1) AS TonsMined,
		ROUND(TotalMaterialMinedTarget,1) AS TonsMinedTarget,
		ROUND(TotalMaterialMoved,1) AS TonsMoved,
		ROUND(TotalMaterialMovedTarget,1) AS TonsMovedTarget,
		ROUND(payload,0) payload,
		PayloadTarget,
		ROUND(NumberOfLoads,0) NumberOfLoads,
		ROUND(NumberOfLoadsTarget,0) NumberOfLoadsTarget,
		ROUND(Loading,2) Loading,
		LoadingTarget,
		ROUND(Spotting,2) Spotting,
		SpottingTarget,
		ROUND(IdleTime,2) IdleTime,
		IdleTimeTarget,
		Hangtime,
		HangtimeTarget,
		ToothMetrics,
		ROUND(AssetEfficiency,0) Ass