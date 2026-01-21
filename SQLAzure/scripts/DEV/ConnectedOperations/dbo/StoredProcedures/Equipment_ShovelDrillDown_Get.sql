









/******************************************************************  
* PROCEDURE	: dbo.Equipment_ShovelDrillDown_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 21 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_ShovelDrillDown_Get 'CURR', 'SIE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Mar 2023}		{lwasini}		{Initial Created}  
* {07 Aug 2023}		{lwasini}		{Update Hourly Tons Mined}  
* {30 Aug 2023}		{lwasini}		{Add Hangtime & TonsMoved}  
* {10 Oct 2023}		{lwasini}		{Add LastTruck}  
* {12 Jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {19 Sep 2024}     {ggosal1}		{Add DeltaC Details}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_ShovelDrillDown_Get] 
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
		operator,
		operatorimageURL,
		reasonid,
		comment,
		[location],
		ROUND(TimeInState,1) TimeInState,
		Crew,
		ROUND(payload,0) Payload,
		PayloadTarget,
		TonsPerReadyHour,
		TonsPerReadyHourTarget,
		TotalMaterialMined/1000.00 AS TonsMined,
		TotalMaterialMinedTarget/1000.00 AS TonsMinedTarget,
		TotalMaterialMoved/1000.00 AS TonsMoved,
		TotalMaterialMovedTarget/1000.00 AS TonsMovedTarget,
		NumberOfLoads,
		NumberOfLoadsTarget,
		ROUND(Spotting,2) Spotting,
		SpottingTarget,
		ROUND(Loading,2) Loading,
		LoadingTarget,
		ROUND(IdleTime,2) IdleTime,
		IdleTimeTarget,
		ROUND(HangTime,2) HangTime,
		HangTimeTarget,
		ROUND(UseOfAvailability,0) UseOfAvailability,
		ROUND(UseOfAvailabilityTarget,0) UseOfAvailabilityTarget,
		ToothMetrics,
		NULL AS LastTruck
		FROM [BAG].[CONOPS_BAG_EQMT_SHOVEL_V]
		WHERE 
		shiftflag = @SHIFT;


		SELECT
		Equipment,
		ROUND(Payload,0) Payload,
		TimeinHour
		FROM [BAG].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_PAYLOAD_V]
		WHERE 
		Equipment IS NOT NULL
		AND shiftflag = @SHIFT
		ORDER BY Equipment,TimeinHour ASC;


		SELECT
		Equipment,
		TotalMaterialMined AS TonsMined,
		TotalMaterialMoved AS TonsMoved,
		TimeinHour
		FROM [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]
		WHERE shiftflag = @SHIFT
		ORDER BY Equipment,TimeinHour ASC;

		SELECT
		EQMT AS Equipment,
		ROUND(TPRH,0) TPRH,
		Hr AS TimeinHour
		FROM [BAG].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TPRH_V]
		WHERE 
		EQMT IS NOT NULL
		AND shiftflag = @SHIFT
		ORDER BY EQMT,Hr ASC;

		SELECT
		Equipment,
		NofLoad AS NumberofLoads,
		TimeinHour
		FROM [BAG].[CONOPS_BAG_EQMT_HOURLY_NOFLOAD_V]
		WHERE 
		Equipment IS NOT NULL
		AND shiftflag = @SHIFT
		ORDER BY Equipment,TimeinHour ASC;

		SELECT
		Equipment,
		idletime,
		spottime,
		loadtime,
		hangtime,
		deltac_ts AS TimeinHour
		FROM [BAG].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_DELTAC_V]
		WHERE 
		Equipment IS NOT NULL
		AND shiftflag = @SHIFT
		ORDER BY Equipment,deltac_ts ASC;

		SELECT
		Equipment,
		ROUND(AE,0) AssetEfficiency,
		ROUND(Avail,0) Availability,
		ROUND(UofA,0) UseofAvailability,
		Hr AS TimeinHour
		FROM [BAG].[CONOPS_BAG_SP_SHOVEL_ASSET_EFFICIENCY_V]
		WHERE 
		Equipment IS NOT NULL
		AND shiftflag = @SHIFT
		ORDER BY Equipment,Hr ASC;
		
		SELECT
			dc.eqmt AS Equipment,
			dc.dumpname,
			dc.LoadCount,
			dc.MOE_TotalCycle,
			dc.MOE_Loaded,
			dc.MOE_Empty,
			dc.MOE_Dumping,
			dc.DC_TotalCycle,
			dc.DC_Loaded,
			dc.DC_Empty,
			dc.DC_Dumping,
			dc.EFH,
			dc.AvgCycleTime
		FROM BAG.CONOPS_BAG_SHIFT_INFO_V s
		LEFT JOIN BAG.CONOPS_BAG_EQMT_DELTA_C_DETAIL_V dc
			ON s.shiftindex = dc.shiftindex
			AND dc.eqmttype = 2
		WHERE shiftflag =  @SHIFT;

	END


	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
		shovelid,
		operator,
		operatorimageURL,
		reasonid,
		comment,
		[location],
		ROUND(TimeInState,1) TimeInState,
		Crew,
		ROUND(payload,0) Pay