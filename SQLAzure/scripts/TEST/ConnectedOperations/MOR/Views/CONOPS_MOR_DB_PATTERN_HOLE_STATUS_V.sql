CREATE VIEW [MOR].[CONOPS_MOR_DB_PATTERN_HOLE_STATUS_V] AS

--SELECT * FROM MOR.CONOPS_MOR_DB_PATTERN_HOLE_STATUS_V
CREATE VIEW MOR.CONOPS_MOR_DB_PATTERN_HOLE_STATUS_V
AS

WITH DHC AS(
SELECT
    pattern_name AS PATTERN_ID,
    hole_name,
    site_code,
    pushback,
	CAST(LEFT(plan_creation_ts_local, 23) AS DATETIME) AS plan_creation_ts_local,
    ROW_NUMBER() OVER (
        PARTITION BY pattern_name, hole_name, site_code
        ORDER BY CAST(LEFT(plan_creation_ts_local, 23) AS DATETIME) DESC) AS rn
FROM SNOWFLAKE_WG.dbo.DRILL_PLAN WITH(NOLOCK)
WHERE pattern_name IS NOT NULL
    AND hole_name IS NOT NULL
    AND site_code = 'MOR'
    AND CAST(LEFT(plan_creation_ts_local, 23) AS DATETIME) >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
),

hole_rows AS(
SELECT 
	--CASE 
	--	WHEN dplan.site_code = 'MOR'
	--		THEN CASE 
	--				WHEN TRY_CAST(LEFT(dplan.original_pattern_name, 3) AS INT) IS NULL
	--					THEN SUBSTRING(dplan.original_pattern_name, 4, 5)
	--				WHEN TRY_CAST(LEFT(dplan.original_pattern_name, 10) AS INT) IS NOT NULL
	--					THEN dplan.original_pattern_name
	--				ELSE LEFT(dplan.original_pattern_name, 5)
	--				END
	--	ELSE dplan.original_pattern_name
	--	END AS pattern_no
	dplan.original_pattern_name AS pattern_no
	,dplan.original_pattern_name
	,dc.drill_hole_name AS DRILLED_HOLE_ID
	,dp.hole_name AS PLANNED_HOLE_ID
	,deq.equip_name AS DRILL_ID
	,dc.drill_hole_status AS DRILL_HOLE_STATUS_CODE
    ,CASE
        WHEN dc.end_hole_ts_local IS NULL AND dc.start_hole_ts_local IS NULL THEN 'UNDRILLED'
        WHEN dc.drill_hole_status = 0 THEN 'UNSPECIFIED'
        WHEN dc.drill_hole_status = 1 THEN 'UNDRILLED'
        WHEN dc.drill_hole_status = 2 THEN 'SUCCESS, DRILLED'
        WHEN dc.drill_hole_status = 3 THEN 'FAIL'
        WHEN dc.drill_hole_status = 4 THEN 'OTHERS'
        WHEN dc.drill_hole_status = 5 THEN 'ABORTED'
        WHEN dc.drill_hole_status = 6 THEN 'REDRILLED'
        END AS DRILL_HOLE_STATUS
	,CAST(LEFT(dc.start_hole_ts_local, 23) AS DATETIME) START_HOLE_TS
	,CASE 
		WHEN CAST(LEFT(dc.start_hole_ts_local, 23) AS DATETIME) >= DATEADD(HOUR, - 6, GETDATE())
			THEN 1
		ELSE 0
		END AS active_hole_flag
	/* Use CONCAT to avoid NULL-swallowing with + */
	,CASE 
		WHEN CAST(LEFT(dc.start_hole_ts_local, 23) AS DATETIME) >= DATEADD(HOUR, - 6, GETDATE())
			THEN CONCAT (
					dp.site_code
					,'_'
					,deq.equip_name
					)
		ELSE NULL
		END AS SITE_DRILL_ACTIVE
	,CASE 
		WHEN CAST(LEFT(dc.end_hole_ts_local, 23) AS DATETIME) > CAST(LEFT(dc.start_hole_ts_local, 23) AS DATETIME)
			AND (dc.actual_drill_hole_start_meters_z - dc.actual_drill_hole_end_meters_z) * 3.28084 > 2
			THEN ((dc.actual_drill_hole_start_meters_z - dc.actual_drill_hole_end_meters_z) * 3.28084) / NULLIF(DATEDIFF(SECOND, CAST(LEFT(dc.start_hole_ts_local, 23) AS DATETIME), CAST(LEFT(dc.end_hole_ts_local, 23) AS DATETIME)) / 3600.0, 0)
		END AS AVG_PENETRATE_RATE
	,CASE 
		WHEN (dc.actual_drill_hole_start_meters_z - dc.actual_drill_hole_end_meters_z) * 3.28084 > 2
			THEN (dc.actual_drill_hole_start_meters_z - dc.actual_drill_hole_end_meters_z) * 3.28084
		END AS DRILLED_DEPTH
	,CASE 
		WHEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z) - dp.hole_end_meters_z) * 3.28084 > 2
			THEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z) - dp.hole_end_meters_z) * 3.28084
		END AS PLAN_DEPTH
	,CASE 
		WHEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z) - dp.hole_end_meters_z) * 3.28084 > 57
			THEN 57
		WHEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z) - dp.hole_end_meters_z) * 3.28084 <= 57
			AND (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z) - dp.hole_end_meters_z) * 3.28084 > 2
			THEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z) - dp.hole_end_meters_z) * 3.28084
		END AS PLAN_DEPTH_ADJUSTED
	,dc.actual_drill_hole_start_meters_x * 3.28084 AS START_POINT_X
	,dp.hole_start_meters_x *