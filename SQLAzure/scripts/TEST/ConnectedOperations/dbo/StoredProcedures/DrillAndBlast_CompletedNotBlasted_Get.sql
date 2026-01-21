
/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_CompletedNotBlasted_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 08 Dec 2025
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_CompletedNotBlasted_Get 'MOR'	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {08 Dec 2025}		{ggosal1}		{Initial Created}
* {02 Jan 2026}		{ggosal1}		{Tons -> kTons}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_CompletedNotBlasted_Get] 
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
			VOLUME_TONS,
			VOLUME_TONS / 1000.00 AS VOLUME_KTONS,
			COMPLETED_HOLE,
			PLANNED_HOLE,
			UNDRILLED_HOLE,
			REDRILLED_HOLE,
			ABORTED_HOLE,
			COMPLETED_PCT,
			PATTERN_STATUS
		FROM MOR.CONOPS_MOR_DB_COMPLETE_PATTERN_HOLE_SUMMARY_V
		ORDER BY PATTERN_NAME;

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
		WHERE PATTERN_STATUS = 'Complete'
		AND IS_READY_TO_BLAST = 1
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





