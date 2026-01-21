CREATE VIEW [MOR].[CONOPS_MOR_DB_COMPLETE_PATTERN_HOLE_SUMMARY_V] AS

--SELECT * FROM MOR.CONOPS_MOR_DB_COMPLETE_PATTERN_HOLE_SUMMARY_V
CREATE VIEW MOR.CONOPS_MOR_DB_COMPLETE_PATTERN_HOLE_SUMMARY_V
AS

WITH PatternSummary AS(
SELECT DISTINCT
    ap.ORIGINAL_PATTERN_NAME AS PATTERN_NAME,
	ap.pattern_completed_hole_count AS COMPLETED_HOLE,
	ap.pattern_planned_hole_count AS PLANNED_HOLE,
	SUM(CASE WHEN ap.DRILL_HOLE_STATUS = 'UNDRILLED' THEN 1 ELSE 0 END) AS UNDRILLED_HOLE,
	SUM(CASE WHEN ap.DRILL_HOLE_STATUS = 'REDRILLED' THEN 1 ELSE 0 END) AS REDRILLED_HOLE,
	SUM(CASE WHEN ap.DRILL_HOLE_STATUS = 'ABORTED' THEN 1 ELSE 0 END) AS ABORTED_HOLE,
    SUM(CASE WHEN ap.DRILL_HOLE_STATUS IN ('SUCCESS, DRILLED', 'ABORTED')
                AND ap.PLAN_DEPTH_ADJUSTED - ap.DRILLED_DEPTH > 7
            THEN 1
            ELSE 0 END) AS SHORT_HOLE_COUNT,
	CAST(ap.pattern_completed_hole_count AS DECIMAL(10,2)) / CAST(ap.pattern_planned_hole_count AS DECIMAL(10,2)) * 100 AS COMPLETED_PCT,
    ap.PATTERN_DRILL_COUNT,
    (hpd.avg_holes_per_drill_per_day / 24.0) AS avg_holes_per_hour,
    ap.is_ready_to_blast,
    ap.pattern_planned_hole_count - ap.pattern_completed_hole_count AS pattern_holes_left,
    CAST(pbd.PLANDATE AS DATETIME) AS PLANNED_BLAST_DATE,
    DATEADD(HOUR, 6, CAST(pbd.PLANDATE AS DATETIME)) AS PLANNED_BLAST_DATE_TARGET,
    CASE WHEN ap.pattern_drill_count > 0
            AND PATTERN_STATUS = 'Active'
            AND is_ready_to_blast = 0
        THEN 1
        ELSE 0 END AS display_flag,
	(ap.BLAST_VOLUME * 35.3146667 * 165) / 2000 AS BLAST_VOLUME
FROM MOR.CONOPS_MOR_DB_PATTERN_HOLE_STATUS_V ap
LEFT JOIN MOR.CONOPS_MOR_DB_AVG_HOLES_PER_DAY_V hpd
    ON ap.pushback = hpd.pushback
LEFT JOIN MOR.CONOPS_MOR_DB_PLANNED_BLAST_DATE_V pbd
    ON ap.ORIGINAL_PATTERN_NAME = pbd.SHOTNO
WHERE ap.pattern_status = 'Complete'
    AND ap.is_ready_to_blast = 1
GROUP BY
	ap.ORIGINAL_PATTERN_NAME,
	ap.pattern_completed_hole_count,
	ap.pattern_planned_hole_count,
	ap.PATTERN_DRILL_COUNT,
	hpd.avg_holes_per_drill_per_day,
	ap.is_ready_to_blast,
	ap.PATTERN_STATUS,
	CAST(pbd.PLANDATE AS DATETIME),
	ap.BLAST_VOLUME
),

PatternHours AS(
SELECT
	*,
	CASE WHEN DISPLAY_FLAG = 0
		THEN NULL
		ELSE pattern_holes_left / (avg_holes_per_hour * PATTERN_DRILL_COUNT) END AS pattern_hours_left,
	pattern_holes_left / (avg_holes_per_hour * (PATTERN_DRILL_COUNT + 1)) AS hrsLeft1Extra,
	pattern_holes_left / (avg_holes_per_hour * (PATTERN_DRILL_COUNT + 2)) AS hrsLeft2Extra,
	pattern_holes_left / (avg_holes_per_hour * (PATTERN_DRILL_COUNT + 3)) AS hrsLeft3Extra
FROM PatternSummary ps
),

ExtraDrill AS(
SELECT
	*,
	DATEADD(HOUR, pattern_hours_left, GETDATE()) AS ESTIMATED_FINISH_DATE,
	DATEADD(HOUR, (hrsLeft1Extra), GETDATE()) AS EST_FINISH_1Extra,
	DATEADD(HOUR, (hrsLeft2Extra), GETDATE()) AS EST_FINISH_2Extra,
	DATEADD(HOUR, (hrsLeft3Extra), GETDATE()) AS EST_FINISH_3Extra
FROM PatternHours
),

FinalCTE AS(
SELECT
	*,
	CASE WHEN PLANNED_BLAST_DATE IS NULL THEN ''
		WHEN PLANNED_BLAST_DATE_TARGET < GETDATE() THEN '' --Already Late
		WHEN ESTIMATED_FINISH_DATE <= PLANNED_BLAST_DATE_TARGET AND ESTIMATED_FINISH_DATE IS NOT NULL THEN '' --OnTime
		WHEN EST_FINISH_1Extra <= PLANNED_BLAST_DATE_TARGET THEN '1'
		WHEN EST_FINISH_2Extra <= PLANNED_BLAST_DATE_TARGET THEN '2'
		WHEN EST_FINISH_3Extra <= PLANNED_BLAST_DATE_TARGET THEN '3'
		ELSE '>3' END AS ADDITIONAL_DRILL_REQUIRED,
	CASE WHEN PLANNED_BLAST_DATE IS NULL THEN 'No Date'
		WHEN PLANNED_BLAST_DATE <= GETDATE() THEN 'Behind'
		WHEN ESTIMATED_FINISH_DATE IS NULL THEN 'Delayed'
		WHEN ESTIMATED_FINISH_DATE <= PLANNED_BLAST_DATE_TARGET THEN 'On Time'
		ELSE 'Behind' END AS PATTERN_STATUS --,
	--CASE WHEN PLANNED_BLAST_DATE IS NULL THEN ''
	--	WHEN PLANNED_BLAST_DATE_TARGET < GETDATE() THEN '' --Already Late
	--	WHEN ESTIMATED_FINISH_DATE <= PLANNED_BLAST_DATE_TARGET AND ESTIMATED_FINISH_DATE IS NOT NULL THEN '' --OnTime
	--	WHEN EST_FINISH_1Extra <= PLANNED_BLAST_DATE_TARGET THEN CONCAT('Add 1 drills