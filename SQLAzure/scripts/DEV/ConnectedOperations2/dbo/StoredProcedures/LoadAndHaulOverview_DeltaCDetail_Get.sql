



/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_DeltaCDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 26 April 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_DeltaCDetail_Get 'PREV', 'BAG', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Apr 2023}		{lwasini}		{Initial Created} 
* {31 Aug 2023}		{ggosal1}		{Add Pit Name} 
* {02 Jan 2024}		{lwasini}		{Implement Data Tyrone} 
* {23 Jan 2024}		{lwasini}		{Add ABR} 
* {26 Jan 2024}		{ggosal1}		{Add @STATUS, @EQMT, @EQMTTYPE} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_DeltaCDetail_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN          
BEGIN TRY	IF @SITE = 'BAG'
	BEGIN

		SELECT
			PushBack AS Pit,
			AVG(DeltaC) AS DeltaC,
			AVG(DeltaCTarget) AS DeltaCTarget,
			AVG(IdleTime) AS IdleTime,
			AVG(IdleTimeTarget) AS IdleTimeTarget,
			AVG(Spotting) AS Spotting,
			AVG(SpottingTarget) AS SpottingTarget,
			AVG(Loading) AS Loading,
			AVG(LoadingTarget) AS LoadingTarget,
			AVG(Dumping) AS Dumping,
			AVG(DumpingTarget) AS DumpingTarget,
			AVG(EmptyTravel) AS EmptyTravel,
			AVG(EmptyTravelTarget) AS EmptyTravelTarget,
			AVG(LoadedTravel) AS LoadedTravel,
			AVG(LoadedTravelTarget) AS LoadedTravelTarget,
			AVG(DumpingAtStockpile) AS DumpingAtStockpile,
			AVG(DumpingAtStockpileTarget) AS DumpingAtStockpileTarget,
			AVG(DumpingAtCrusher) AS DumpingAtCrusher,
			AVG(DumpingAtCrusherTarget) AS DumpingAtCrusherTarget
		FROM [BAG].[CONOPS_BAG_DELTA_C_DETAIL_V] a
		LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_DETAIL_V] b
			ON a.shiftflag = b.shiftflag AND a.TruckId = b.truckID
		WHERE a.shiftflag =  @SHIFT
			AND (a.TruckId IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY Pushback

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			PushBack AS Pit,
			AVG(DeltaC) AS DeltaC,
			AVG(DeltaCTarget) AS DeltaCTarget,
			AVG(IdleTime) AS IdleTime,
			AVG(IdleTimeTarget) AS IdleTimeTarget,
			AVG(Spotting) AS Spotting,
			AVG(SpottingTarget) AS SpottingTarget,
			AVG(Loading) AS Loading,
			AVG(LoadingTarget) AS LoadingTarget,
			AVG(Dumping) AS Dumping,
			AVG(DumpingTarget) AS DumpingTarget,
			AVG(EmptyTravel) AS EmptyTravel,
			AVG(EmptyTravelTarget) AS EmptyTravelTarget,
			AVG(LoadedTravel) AS LoadedTravel,
			AVG(LoadedTravelTarget) AS LoadedTravelTarget,
			AVG(DumpingAtStockpile) AS DumpingAtStockpile,
			AVG(DumpingAtStockpileTarget) AS DumpingAtStockpileTarget,
			AVG(DumpingAtCrusher) AS DumpingAtCrusher,
			AVG(DumpingAtCrusherTarget) AS DumpingAtCrusherTarget
		FROM [CER].[CONOPS_CER_DELTA_C_DETAIL_V] a
		LEFT JOIN [CER].[CONOPS_CER_TRUCK_DETAIL_V] b
			ON a.shiftflag = b.shiftflag AND a.TruckId = b.truckID
		WHERE a.shiftflag =  @SHIFT
			AND (a.TruckId IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY Pushback

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			PushBack AS Pit,
			AVG(DeltaC) AS DeltaC,
			AVG(DeltaCTarget) AS DeltaCTarget,
			AVG(IdleTime) AS IdleTime,
			AVG(IdleTimeTarget) AS IdleTimeTarget,
			AVG(Spotting) AS Spotting,
			AVG(SpottingTarget) AS SpottingTarget,
			AVG(Loading) AS Loading,
			AVG(LoadingTarget) AS