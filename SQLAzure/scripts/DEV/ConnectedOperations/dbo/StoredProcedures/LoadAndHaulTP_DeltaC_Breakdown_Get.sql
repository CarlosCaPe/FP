
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_DeltaC_Breakdown_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 19 Sep 2024
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_DeltaC_Breakdown_Get 'PREV', 'MOR', NULL, NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Sep 2024}		{ggosal1}		{Initial Created}
* {20 Feb 2025}		{ggosal1}		{Add EmptyTravel & MinsOverExpected}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
* {12 Aug 2025}		{ggosal1}		{Add Pushback}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_DeltaC_Breakdown_Get] 
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
			Route,
			'All' AS Pushback,
			ROUND(AVG(DeltaC), 1) AS DeltaC,
			ROUND(AVG(EmptyTravel), 1) AS EmptyTravel,
			ROUND(AVG(TruckIdle), 1) AS Idle,
			ROUND(AVG(Spotting), 1) AS Spotting,
			ROUND(AVG(Loading), 1) AS Loading,
			ROUND(AVG(LoadedTravel), 1) AS LoadedTravel,
			ROUND(AVG(Dumping), 1) AS Dumping,
			ROUND(AVG(DumpingAtStockpile), 1) AS DumpingAtStockpile,
			ROUND(AVG(DumpingAtCrusher), 1) AS DumpingAtCrusher,
			ROUND(SUM(DeltaC), 1) AS MinsOverExpected,
			COUNT(*) AS CycleCount
		FROM BAG.CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V
		WHERE shiftflag = @SHIFT
			AND (TruckID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (TruckType IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (TruckStatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND (TruckID IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')
		GROUP BY Route

		UNION ALL

		SELECT
			Route,
			Pushback,
			ROUND(AVG(DeltaC), 1) AS DeltaC,
			ROUND(AVG(EmptyTravel), 1) AS EmptyTravel,
			ROUND(AVG(TruckIdle), 1) AS Idle,
			ROUND(AVG(Spotting), 1) AS Spotting,
			ROUND(AVG(Loading), 1) AS Loading,
			ROUND(AVG(LoadedTravel), 1) AS LoadedTravel,
			ROUND(AVG(Dumping), 1) AS Dumping,
			ROUND(AVG(DumpingAtStockpile), 1) AS DumpingAtStockpile,
			ROUND(AVG(DumpingAtCrusher), 1) AS DumpingAtCrusher,
			ROUND(SUM(DeltaC), 1) AS MinsOverExpected,
			COUNT(*) AS CycleCount
		FROM BAG.CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V
		WHERE shiftflag = @SHIFT
			AND (TruckID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (TruckType IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (TruckStatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND (TruckID IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')
		GROUP BY Route, Pushback

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			Route,
			'All' AS Pushback,
			ROUND(AVG(DeltaC), 1) AS DeltaC,
			ROUND(AVG(EmptyTravel), 1) AS EmptyTravel,
			ROUND(AVG(TruckIdle), 1) AS Idle,
			ROUND(AVG(Spotting), 1) AS Spotting,
			ROUND(AVG(Loading), 1) AS Loading,
			ROUND(AVG(LoadedTravel), 1) AS LoadedTravel,
			ROUND(AVG(Dumping), 1) AS Dumping,
			ROUND(AVG(DumpingAtStockpile), 1) AS DumpingAtStockpile,
			ROUND(AVG(DumpingAtCrusher), 1) AS DumpingAtCrusher,
			ROUND(SUM(DeltaC), 1) AS MinsOverExpected,
			COUNT(*) AS CycleCount
		FROM CER.CONOPS_CER_DELTA_C_ROUTE_BREAKDOWN_V
		WHERE shiftflag = @SHIFT
			AND (TruckID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (TruckType IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')