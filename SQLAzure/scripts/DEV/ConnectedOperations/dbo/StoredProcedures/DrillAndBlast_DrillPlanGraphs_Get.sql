






/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillPlanGraphs_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 03 Aug 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillPlanGraphs_Get 'PREV', 'CHN', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {03 Aug 2023}		{ggosal1}		{Initial Created} 
* {05 Sep 2023}		{ggosal1}		{Add Parameter Equipment Type} 
* {03 Jan 2024}		{lwasini}		{Added TYR} 
* {09 Jan 2024}		{lwasini}		{Added ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillPlanGraphs_Get]
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			DateTime,
			SUM(DRILL_HOLE) AS DRILL_HOLE,
			SUM(FEET_DRILLED) AS FEET_DRILLED
		FROM [BAG].[CONOPS_BAG_DB_DRILL_PLAN_LINE_GRAPH_V]
		WHERE shiftflag = @SHIFT
			AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		GROUP BY siteflag, shiftflag, DateTime
 
		SELECT
			DRILL_ID,
			HolesDrilled AS DRILL_HOLE,
			FeetDrilled AS FEET_DRILLED
		FROM [BAG].[CONOPS_BAG_DB_DRILL_PLAN_V]
		WHERE shiftflag = @SHIFT
			AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			DateTime,
			SUM(DRILL_HOLE) AS DRILL_HOLE,
			SUM(FEET_DRILLED) AS FEET_DRILLED
		FROM [CER].[CONOPS_CER_DB_DRILL_PLAN_LINE_GRAPH_V]
		WHERE shiftflag = @SHIFT
			AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		GROUP BY siteflag, shiftflag, DateTime
 
		SELECT
			DRILL_ID,
			HolesDrilled AS DRILL_HOLE,
			FeetDrilled AS FEET_DRILLED
		FROM [CER].[CONOPS_CER_DB_DRILL_PLAN_V]
		WHERE shiftflag = @SHIFT
			AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			DateTime,
			SUM(DRILL_HOLE) AS DRILL_HOLE,
			SUM(FEET_DRILLED) AS FEET_DRILLED
		FROM [CHI].[CONOPS_CHI_DB_DRILL_PLAN_LINE_GRAPH_V]
		WHERE shiftflag = @SHIFT
			AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		GROUP BY siteflag, shiftflag, DateTime
 
		SELECT
			DRILL_ID,
			HolesDrilled AS DRILL_HOLE,
			FeetDrilled AS FEET_DRILLED
		FROM [CHI].[CONOPS_CHI_DB_DRILL_PLAN_V]
		WHERE shiftflag = @SHIFT
			AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STAT