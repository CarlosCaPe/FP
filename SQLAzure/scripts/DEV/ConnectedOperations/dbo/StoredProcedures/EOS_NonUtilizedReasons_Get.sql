








/******************************************************************  
* PROCEDURE	: dbo.EOS_NonUtilizedReasons_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 17 May 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_NonUtilizedReasons_Get 'CURR', 'MOR',1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 May 2023}		{jrodulfa}		{Initial Created} 
* {22 Jun 2023}		{jrodulfa}		{Added Drill NonUtilized Reason} 
* {14 Jul 2023}     {lwasini}		{Added Total TimeinHours}
* {06 Dec 2023}     {lwasini}		{Added Daily Summary}
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_NonUtilizedReasons_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@DAILY INT
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		INTO #BAGTruckTempTable
		FROM [bag].[CONOPS_BAG_EOS_TRUCK_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(TimeInHours),2) AS TruckTotalTimeInHours
		FROM #BAGTruckTempTable;

		SELECT
			UnitType,
			ReasonName,
			ROUND(TimeInHours,2) AS TimeInHours
		FROM #BAGTruckTempTable;

		DROP TABLE #BAGTruckTempTable;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		INTO #BAGShovelTempTable
		FROM [bag].[CONOPS_BAG_EOS_SHOVEL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(TimeInHours),2) AS ShovelTotalTimeInHours
		FROM #BAGShovelTempTable;

		SELECT
			UnitType,
			ReasonName,
			ROUND(TimeInHours,2) AS TimeInHours
		FROM #BAGShovelTempTable;

		DROP TABLE #BAGShovelTempTable;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		INTO #BAGDrillTempTable
		FROM [bag].[CONOPS_BAG_EOS_DRILL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(TimeInHours),2) AS DrillTotalTimeInHours
		FROM #BAGDrillTempTable;

		SELECT
			UnitType,
			ReasonName,
			ROUND(TimeInHours,2) AS TimeInHours
		FROM #BAGDrillTempTable;

		DROP TABLE #BAGDrillTempTable;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		INTO #BAGCrusherTempTable
		FROM [bag].[CONOPS_BAG_EOS_CRUSHER_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(TimeInHours),2) AS CrusherTotalTimeInHours
		FROM #BAGCrusherTempTable;

		SELECT
			UnitType,
			ReasonName,
			ROUND(TimeInHours,2) AS TimeInHours
		FROM #BAGCrusherTempTable;

		DROP TABLE #BAGCrusherTempTable;

		END


		ELSE IF @DAILY = 1
		BEGIN
		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		INTO #DailyBAGTruckTempTable
		FROM [bag].[CONOPS_BAG_DAILY_EOS_TRUCK_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(TimeInHours),2) AS TruckTotalTimeInHours
		FROM #DailyBAGTruckTempTable;

		SELECT
			UnitType,
			ReasonName,
			ROUND(TimeInHours,2) AS TimeInHours
		FROM #DailyBAGTruckTempTable;

		DROP TABLE #DailyBAGTruckTempTable;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		INTO #DailyBAGShovelTempTable
		FROM [bag].[CONOPS_BAG_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(TimeInHours),2) AS ShovelTotalTimeInHours
		FROM #DailyBAGShovelTempTable;

		SELECT
			UnitType,
			ReasonName,
			ROUND(TimeInHours,2) AS TimeI