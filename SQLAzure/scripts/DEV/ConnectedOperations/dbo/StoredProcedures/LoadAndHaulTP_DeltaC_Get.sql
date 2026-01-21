
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_DeltaC_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_DeltaC_Get 'CURR', 'CVE', NULL, NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}
* {07 Dec 2022}		{sxavier}		{Rename field}
* {01 Sep 2023}		{lwasini}		{Add Parameter Equipment Type}
* {18 Sep 2023}		{lwasini}		{Add Hourly DeltaC} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {12 Jan 2024}		{lwasini}		{Add TYR} 
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {04 Apr 2024}     {lwasini}		{Remove /1000 in Material Delivered}
* {18 Feb 2025}     {ggosal1}		{Fix Overall DeltaC Value}
* {06 May 2025}		{ggosal1}		{Add Autonomous Filter}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_DeltaC_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX),
	@AUTONOMOUS INT
)
AS                        
BEGIN    

BEGIN TRY

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
				AND (TruckId IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
				AND (TruckType IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
				AND (TruckStatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
				AND (TruckId IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')
			GROUP BY shiftid, shiftflag
		) a
		LEFT JOIN BAG.CONOPS_BAG_OVERALL_DELTA_C_V t
			ON a.shiftflag = t.shiftflag;
 
		SELECT TOP 15 
			truck AS [Name],
			toper AS OperatorName,
			OperatorImageURL as ImageUrl,
			OperatorId,
			ROUND(TotalMaterialDelivered,1) AS TotalMaterialDelivered, 
			ROUND(TotalMaterialDeliveredTarget,1) AS TotalMaterialDeliveredTarget, 
			ROUND(AVG_Payload,0) AS Payload,
			AVG_PayloadTarget AS PayloadTarget,
			ROUND(DeltaC,1) AS DeltaC,
			Delta_c_target AS DeltaCTarget,
			idletime AS IdleTime,
			idletimetarget AS IdleTimeTarget,
			spottime AS Spotting,
			spottarget AS SpottingTarget,
			loadtime AS Loading,
			loadtarget AS LoadingTarget,
			DumpingTime AS Dumping,
			dumpingtarget AS DumpingTarget,
			EFH AS Efh,
			EFHtarget AS EfhTarget,
			DumpingAtStockpile AS [DumpsAtStockpile],
			dumpingatStockpileTarget AS DumpsAtStockpileTarget,
			DumpingAtCrusher As DumpsAtCrusher,
			dumpingAtCrusherTarget AS DumpsAtCrusherTarget,
			LoadedTravel,
			LoadedTravelTarget,
			EmptyTravel,
			EmptyTravelTarget,
			ROUND(useOfAvailability,0) AS AvgUseOfAvailibility,
			ROUND(useOfAvailabilityTarget,0) AS AvgUseOfAvailibilityTarget,
			[destination],
			Pit,
			reasonidx AS ReasonIdx,
			reasons AS Reason
		FROM BAG.[CONOPS_BAG_TP_DELTA_C_V]
		WHERE shiftflag = @SHIFT
			AND (truck IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND (truck IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')
		ORDER BY deltac DESC;


		SELECT
			ROUND(AVG(DeltaC),1) [DeltaC],
			deltac_ts AS TimeinHour
		FROM [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY