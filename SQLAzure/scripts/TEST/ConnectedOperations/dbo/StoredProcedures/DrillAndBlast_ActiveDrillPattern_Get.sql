
/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_ActiveDrillPattern_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 16 Dec 2025
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_ActiveDrillPattern_Get 'MOR'	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {04 Dec 2025}		{ggosal1}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_ActiveDrillPattern_Get] 
(	
	@SITE VARCHAR(4)
)
AS                        
BEGIN   

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'CVE'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'CHN'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'CMX'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'MOR'
	BEGIN
	
		SELECT
			PATTERN_NAME,
			PATTERN_DRILL_COUNT,
			PLANNED_BLAST_DATE,
			ESTIMATED_FINISH_DATE,
			COMPLETED_HOLE,
			PLANNED_HOLE,
			UNDRILLED_HOLE,
			REDRILLED_HOLE,
			ABORTED_HOLE,
			COMPLETED_PCT,
			ADDITIONAL_DRILL_REQUIRED,
			SHORT_HOLE_COUNT,
			PATTERN_STATUS
		FROM MOR.CONOPS_MOR_DB_ACTIVE_PATTERN_HOLE_SUMMARY_V
		ORDER BY PATTERN_NAME;

		SELECT DISTINCT
			ap.ORIGINAL_PATTERN_NAME AS PATTERN_NAME,
			ap.DRILL_ID,
			ds.OPERATOR_ID,
			ds.statusname AS STATUS_NAME,
			ds.autodrillenabled AS AUTO_DRILL_ENABLED
		FROM MOR.CONOPS_MOR_DB_PATTERN_HOLE_STATUS_V ap
		LEFT JOIN MOR.CONOPS_MOR_DB_DRILL_CURRENT_STATUS_V ds
			ON ap.DRILL_ID = ds.eqmt
		WHERE ap.pattern_status = 'Active'
			AND ap.IS_READY_TO_BLAST = 0
			AND ap.drill_id IS NOT NULL
			AND ap.site_drill_active IS NOT NULL
		ORDER BY ORIGINAL_PATTERN_NAME, DRILL_ID;

		SELECT
			ORIGINAL_PATTERN_NAME AS PATTERN_NAME,
			DESIGNED_AS_HOLENAME AS HOLE_NAME,
			DRILL_HOLE_STATUS AS HOLE_STATUS,
			DRILL_ID,
			AVG_PENETRATE_RATE,
			DRILLED_DEPTH,
			DESIGN_X_START,
			DESIGN_Y_START,
			START_POINT_X
		FROM MOR.CONOPS_MOR_DB_PATTERN_HOLE_STATUS_V
		WHERE PATTERN_STATUS = 'Active'
			AND IS_READY_TO_BLAST = 0
		ORDER BY ORIGINAL_PATTERN_NAME, DESIGNED_AS_HOLENAME;
	
	END
	
	ELSE IF @SITE = 'SAM'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'SIE'
	BEGIN
	
		SELECT NULL
	
	END

	ELSE IF @SITE = 'TYR'
	BEGIN
	
		SELECT NULL
	
	END

	ELSE IF @SITE = 'ABR'
	BEGIN
	
		SELECT NULL
	
	END

SET NOCOUNT OFF

END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

END



