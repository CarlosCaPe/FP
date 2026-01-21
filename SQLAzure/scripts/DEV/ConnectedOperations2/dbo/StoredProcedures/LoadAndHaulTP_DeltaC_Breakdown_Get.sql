
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
* {10 Nov 2025}		{dbonardo}		{Split String using udt}
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
		FROM BAG.CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V a
		LEFT JOIN BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
			ON a.TruckID = d.TruckID
		WHERE shiftflag = @SHIFT
			AND (a.TruckID IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (TruckType IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (UPPER(TruckStatus) IN (SELECT UPPER([Value]) FROM @splitEStat) OR @STATUS IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
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
		FROM BAG.CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V a
		LEFT JOIN BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
			ON a.TruckID = d.TruckID
		WHERE shiftflag = @SHIFT
			AND (a.TruckID IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (TruckType IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (UPPER(TruckStatus) IN (SELECT UPPER([Value]) FROM @splitEStat) OR @STATUS IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
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
			ROUND(SUM(DeltaC), 1) AS Mi