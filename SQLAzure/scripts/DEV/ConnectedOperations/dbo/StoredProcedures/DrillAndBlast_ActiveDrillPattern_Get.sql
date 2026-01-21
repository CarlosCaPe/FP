


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
		'7045300626' AS PATTERN_NAME,
		1 AS PATTERN_DRILL_COUNT,
		CAST('2025-12-16 00:00:00' AS DATETIME) AS PLANNED_BLAST_DATE,
		CAST('2025-12-19 09:10:39' AS DATETIME) AS ESTIMATED_FINISH_DATE,
		132 AS COMPLETED_HOLE,
		236 AS PLANNED_HOLE,
		104 AS UNDRILLED_HOLE,
		0 AS REDRILLED_HOLE,
		54 AS ABORTED_HOLE,
		55.9322 AS COMPLETED_PCT,
		'>3' AS ADDITIONAL_DRILL_REQUIRED,
		1 AS SHORT_HOLE_COUNT,
		'Behind' AS PATTERN_STATUS;

		SELECT
		'7045300626' AS PATTERN_NAME,
		'25R' AS DRILL_ID,
		'0060025285' AS OPERATOR_ID,
		'Ready' AS STATUS_NAME,
		1 AS AUTO_DRILL_ENABLED

		SELECT
		'7045300626' AS PATTERN_NAME,
		'093' AS HOLE_NAME,
		'SUCCESS, DRILLED' AS HOLE_STATUS,
		'25R' AS DRILL_ID,
		133.998083450680 AS AVG_PENETRATE_RATE,
		56.3908154528 AS DRILLED_DEPTH,
		12971.0404085116 AS DESIGN_X_START,
		-16636.7705126916 AS DESIGN_Y_START,
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


