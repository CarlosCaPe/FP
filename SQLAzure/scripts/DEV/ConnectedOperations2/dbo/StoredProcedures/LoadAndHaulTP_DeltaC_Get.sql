
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
* {07 Nov 2025}		{dbonardo}		{split string usinf udt}
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
	
	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');

	INSERT INTO @splitEStat ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');

	INSERT INTO @splitEType ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

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
				FROM BAG.CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V a
				LEFT JOIN  BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
				ON a.TruckId = d.TruckId 
			WHERE shiftflag = @SHIFT
				AND (a.TruckId IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
				AND (TruckStatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
				AND (TruckType IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
				AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
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
		LEFT JOIN  BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
		ON truck = d.TruckId 
		WHERE shiftflag = @SHIFT
			AND (truck IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @