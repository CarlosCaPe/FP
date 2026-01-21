
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
		'7035550325' AS PATTERN_NAME,
		CAST('2025-12-16' AS DATE) AS PLANNED_BLAST_DATE,
		179908.18227778831 AS VOLUME_TONS,
		179.90818227778831 AS VOLUME_KTONS,
		66 AS COMPLETED_HOLE,
		109 AS PLANNED_HOLE,
		43 AS UNDRILLED_HOLE,
		0 AS REDRILLED_HOLE,
		1 AS ABORTED_HOLE,
		60.55045900 AS COMPLETED_PCT,
		'>3' AS ADDITIONAL_DRILL_REQUIRED,
		1 AS SHORT_HOLE_COUNT,
		'Behind' AS PATTERN_STATUS;

		SELECT
		'7035550325' AS PATTERN_NAME,
		'025' AS HOLE_NAME,
		'ABORTED' AS HOLE_STATUS,
		'35R' AS DRILL_ID,
		44.654876536137 AS AVG_PENETRATE_RATE,
		4.5522967336 AS DRILLED_DEPTH,
		16578.2305173800 AS DESIGN_X_START,
		-19634.4706086180 AS DESIGN_Y_START,
		12962.7245289804 AS START_POINT_X

	
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




