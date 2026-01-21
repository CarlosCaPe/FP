

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
	
		SELECT DISTINCT
			ORIGINAL_PLAN_ID AS PLAN_ID,
			pattern_completed_hole_count AS COMPLETED_HOLE,
			pattern_planned_hole_count AS PLANNED_HOLE,
			SUM(CASE WHEN DRILL_HOLE_STATUS = 'UNDRILLED' THEN 1 ELSE 0 END) AS UNDRILLED_HOLE,
			SUM(CASE WHEN DRILL_HOLE_STATUS = 'REDRILLED' THEN 1 ELSE 0 END) AS REDRILLED_HOLE,
			SUM(CASE WHEN DRILL_HOLE_STATUS = 'ABORTED' THEN 1 ELSE 0 END) AS ABORTED_HOLE,
			CAST(pattern_completed_hole_count AS DECIMAL(10,2)) / CAST(pattern_planned_hole_count AS DECIMAL(10,2)) * 100 AS COMPLETED_PCT,
			COUNT(DISTINCT DRILL_ID) AS DRILL_COUNT,
			GETDATE() AS PLANNED_BLAST_DATE,
			DATEADD(HOUR, 14, GETDATE()) AS ESTIMATED_FINISH_DATE,
			'On Time' AS PLAN_STATUS,
			99.9 AS PLANNED_KTONS
		FROM SNOWFLAKE_WG.dbo.ACTIVE_PATTERN_HOLE_STATUS
		GROUP BY
			ORIGINAL_PLAN_ID,
			pattern_completed_hole_count,
			pattern_planned_hole_count
		ORDER BY ORIGINAL_PLAN_ID;

		SELECT 
			ORIGINAL_PLAN_ID AS PLAN_ID,
			DESIGNED_AS_HOLENAME AS HOLE_NAME,
			DRILL_HOLE_STATUS,
			AVG_PENETRATE_RATE,
			DRILLED_DEPTH,
			DRILL_ID,
			DESIGN_X_START,
			DESIGN_Y_START,
			START_POINT_X
		FROM SNOWFLAKE_WG.dbo.ACTIVE_PATTERN_HOLE_STATUS
		ORDER BY ORIGINAL_PLAN_ID, DESIGNED_AS_HOLENAME;

	
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



