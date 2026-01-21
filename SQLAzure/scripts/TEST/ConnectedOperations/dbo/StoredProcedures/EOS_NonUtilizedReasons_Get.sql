
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
* {26 Nov 2025}		{ggosal1}		{Remove Temp Table Usage}
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

		SELECT
			ROUND(SUM(DurationHours),2) AS TruckTotalTimeInHours
		FROM [BAG].[CONOPS_BAG_EOS_TRUCK_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			UnitType,
			Reason AS ReasonName,
			ROUND(DurationHours,2) AS TimeInHours
		FROM [BAG].[CONOPS_BAG_EOS_TRUCK_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(DurationHours),2) AS ShovelTotalTimeInHours
		FROM [BAG].[CONOPS_BAG_EOS_SHOVEL_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			UnitType,
			Reason AS ReasonName,
			ROUND(DurationHours,2) AS TimeInHours
		FROM [BAG].[CONOPS_BAG_EOS_SHOVEL_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(DurationHours),2) AS DrillTotalTimeInHours
		FROM [BAG].[CONOPS_BAG_EOS_DRILL_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			UnitType,
			Reason AS ReasonName,
			ROUND(DurationHours,2) AS TimeInHours
		FROM [BAG].[CONOPS_BAG_EOS_DRILL_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(DurationHours),2) AS CrusherTotalTimeInHours
		FROM [BAG].[CONOPS_BAG_EOS_CRUSHER_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			UnitType,
			Reason AS ReasonName,
			ROUND(DurationHours,2) AS TimeInHours
		FROM [BAG].[CONOPS_BAG_EOS_CRUSHER_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		END

		ELSE IF @DAILY = 1
		BEGIN

		SELECT
			ROUND(SUM(DurationHours),2) AS TruckTotalTimeInHours
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_TRUCK_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			UnitType,
			Reason AS ReasonName,
			ROUND(DurationHours,2) AS TimeInHours
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_TRUCK_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(DurationHours),2) AS ShovelTotalTimeInHours
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			UnitType,
			Reason AS ReasonName,
			ROUND(DurationHours,2) AS TimeInHours
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(DurationHours),2) AS DrillTotalTimeInHours
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			UnitType,
			Reason AS ReasonName,
			ROUND(DurationHours,2) AS TimeInHours
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT
			ROUND(SUM(DurationHours),2) AS CrusherTotalTimeInHours
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_CRUSHER_NON_UTILIZED_REASON_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			UnitType,
			Reason AS ReasonName,
			ROUND(DurationHours,2) AS TimeInHours
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_CRUSHER_NON_UTILIZED_REASON_V