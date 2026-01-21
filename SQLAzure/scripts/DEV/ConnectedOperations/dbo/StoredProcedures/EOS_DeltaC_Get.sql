



/******************************************************************  
* PROCEDURE	: dbo.EOS_DeltaC_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 19 May 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_DeltaC_Get 'CURR', 'CVE', NULL, NULL, NULL, 0, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 May 2023}		{ggosal1}		{Initial Created}
* {31 Aug 2023}		{ggosal1}		{Add Pit Name} 
* {04 Dec 2023}		{lwasini}		{Add Daily Summary} 
* {26 Jan 2023}		{ggosal1}		{Adjusting the view} 
* {29 Jan 2023}		{ggosal1}		{Combine with LH DeltaC Detail}
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR} 
* {20 Feb 2024}		{lwasini}		{Add Empty & Loaded Travel Duration} 
* {13 Mar 2024}		{lwasini}		{Add Empty & Loaded Travel Plan} 
* {13 Feb 2025}		{ggosal1}		{Update BAG Actual Duration}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_DeltaC_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX),
	@DAILY INT,
	@AUTONOMOUS INT
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		IF @DAILY = 0 
		BEGIN
			SELECT
				PushBack AS Pit,
				ROUND(AVG(DeltaC), 1) AS DeltaC,
				ROUND(AVG(DeltaCTarget), 1) AS DeltaCTarget,
				ROUND(AVG(DeltaC) + AVG(DeltaCTarget), 1) AS DeltaCDuration,
				ROUND(AVG(IdleTime), 1) AS IdleTime,
				ROUND(AVG(IdleTimeTarget), 1) AS IdleTimeTarget,
				ROUND(AVG(IdleTimeDuration), 1) AS IdleTimeDuration,
				ROUND(AVG(Spotting), 1) AS Spotting,
				ROUND(AVG(SpottingTarget), 1) AS SpottingTarget,
				ROUND(AVG(SpottingDuration), 1) AS SpottingDuration,
				ROUND(AVG(Loading), 1) AS Loading,
				ROUND(AVG(LoadingTarget), 1) AS LoadingTarget,
				ROUND(AVG(LoadingDuration), 1) AS LoadingDuration,
				ROUND(AVG(Dumping), 1) AS Dumping,
				ROUND(AVG(DumpingTarget), 1) AS DumpingTarget,
				ROUND(AVG(DumpingDuration), 1) AS DumpingDuration,
				ROUND(AVG(EmptyTravel), 1) AS EmptyTravel,
				ROUND(AVG(EmptyTravelDuration), 1) AS EmptyTravelDuration,
				ROUND(AVG(EmptyTravelTarget), 1) AS EmptyTravelTarget,
				ROUND(AVG(EmptyTravelPlan), 1) AS EmptyTravelPlan,
				ROUND(AVG(LoadedTravel), 1) AS LoadedTravel,
				ROUND(AVG(LoadedTravelDuration), 1) AS LoadedTravelDuration,
				ROUND(AVG(LoadedTravelTarget), 1) AS LoadedTravelTarget,
				ROUND(AVG(LoadedTravelPlan), 1) AS LoadedTravelPlan,
				ROUND(AVG(DumpingAtStockpile), 1) AS DumpingAtStockpile,
				ROUND(AVG(DumpingAtStockpileTarget), 1) AS DumpingAtStockpileTarget,
				ROUND(AVG(DumpingAtStockpileDuration), 1) AS DumpingAtStockpileDuration,
				ROUND(AVG(DumpingAtCrusher), 1) AS DumpingAtCrusher,
				ROUND(AVG(DumpingAtCrusherTarget), 1) AS DumpingAtCrusherTarget,
				ROUND(AVG(DumpingAtCrusherDuration), 1) AS DumpingAtCrusherDuration
			FROM [BAG].[CONOPS_BAG_DELTA_C_DETAIL_V] a
			LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_DETAIL_V] b
				ON a.shiftflag = b.shiftflag AND a.TruckId = b.truckID
			WHERE a.shiftflag =  @SHIFT
				AND (a.TruckId IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
				AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
				AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
				AND (a.TruckId IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')
			GROUP BY Pushback
		END
 
		ELSE IF @DAILY = 1 
		BEGIN
			SELECT
				PushBack AS Pit,
				ROUND(AVG(DeltaC), 1) AS DeltaC,
				ROUND(AVG(DeltaCTarget), 1) AS DeltaCTarget,
				ROUND(AVG(DeltaC) + AVG(DeltaCTarget), 1) AS DeltaCDuration,
				ROUND(AVG(IdleTime), 1) AS IdleTime,
				ROUND(AVG(IdleTimeTarget), 1) AS IdleTimeTarget,
				ROUND(AVG(IdleTimeDuration),