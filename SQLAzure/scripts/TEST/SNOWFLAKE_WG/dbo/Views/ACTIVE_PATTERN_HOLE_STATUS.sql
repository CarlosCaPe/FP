CREATE VIEW [dbo].[ACTIVE_PATTERN_HOLE_STATUS] AS





CREATE view [dbo].[ACTIVE_PATTERN_HOLE_STATUS] as 

WITH DHC AS (
    SELECT
        pattern_name AS PATTERN_ID,
        hole_name,
        site_code,
        pushback,
        plan_creation_ts_local,
        ROW_NUMBER() OVER (
            PARTITION BY pattern_name, hole_name, site_code
            ORDER BY plan_creation_ts_local DESC
        ) AS rn
    FROM DBO.drill_plan
    WHERE pattern_name IS NOT NULL
      AND hole_name IS NOT NULL
),

hole_rows AS (
    SELECT
        CASE 
            WHEN dplan.site_code = 'MOR' THEN
                CASE 
                    WHEN TRY_CAST(LEFT(dplan.original_pattern_name, 3) AS INT) IS NULL
                        THEN SUBSTRING(dplan.original_pattern_name, 4, 5)
                    WHEN TRY_CAST(LEFT(dplan.original_pattern_name, 10) AS INT) IS NOT NULL
                        THEN dplan.original_pattern_name
                    ELSE LEFT(dplan.original_pattern_name, 5)
                END
            ELSE dplan.original_pattern_name
        END AS pattern_no,

        dplan.original_pattern_name,

        dc.drill_hole_name AS DRILLED_HOLE_ID,
        dp.hole_name       AS PLANNED_HOLE_ID,

        dc.drill_id        AS DRILL_ID,
        dc.drill_hole_status AS DRILL_HOLE_STATUS,
        CAST(LEFT(dc.start_hole_ts_local,23) AS DATETIME)  START_HOLE_TS,

        CASE
            WHEN CAST(LEFT(dc.start_hole_ts_local,23) AS DATETIME) >= DATEADD(HOUR, -6, GETDATE()) THEN 1
            ELSE 0
        END AS active_hole_flag,

        CASE
            WHEN CAST(LEFT(dc.start_hole_ts_local,23) AS DATETIME) >= DATEADD(HOUR, -6, GETDATE())
                THEN CONCAT(dp.site_code, '_', dc.drill_id)
            ELSE NULL
        END AS SITE_DRILL_ACTIVE,

        CASE 
            WHEN CAST(LEFT(dc.end_hole_ts_local,23) AS DATETIME) > CAST(LEFT(dc.start_hole_ts_local,23) AS DATETIME)
             AND (dc.actual_drill_hole_start_meters_z - dc.actual_drill_hole_end_meters_z) * 3.28084 > 2
                THEN ((dc.actual_drill_hole_start_meters_z - dc.actual_drill_hole_end_meters_z) * 3.28084) /
                     NULLIF(DATEDIFF(SECOND, CAST(LEFT(dc.start_hole_ts_local,23) AS DATETIME), CAST(LEFT(dc.start_hole_ts_local,23) AS DATETIME)) / 3600.0, 0)
        END AS AVG_PENETRATE_RATE,

        CASE 
            WHEN (dc.actual_drill_hole_start_meters_z - dc.actual_drill_hole_end_meters_z) * 3.28084 > 2
                THEN (dc.actual_drill_hole_start_meters_z - dc.actual_drill_hole_end_meters_z) * 3.28084
        END AS DRILLED_DEPTH,

        CASE 
            WHEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z)
                  - dp.hole_end_meters_z) * 3.28084 > 2
                THEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z)
                      - dp.hole_end_meters_z) * 3.28084
        END AS PLAN_DEPTH,

        CASE 
            WHEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z)
                  - dp.hole_end_meters_z) * 3.28084 > 57
                THEN 57 
            WHEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z)
                  - dp.hole_end_meters_z) * 3.28084 <= 57
             AND (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z)
                  - dp.hole_end_meters_z) * 3.28084 > 2
                THEN (COALESCE(dc.actual_drill_hole_start_meters_z, dp.hole_start_meters_z)
                      - dp.hole_end_meters_z) * 3.28084
        END AS PLAN_DEPTH_ADJUSTED,

        dc.actual_drill_hole_start_meters_y * 3.28084 AS START_POINT_X,
        dp.hole_start_meters_y * 3.28084 AS DESIGN_X_START,
        dp.hole_start_meters_x * 3.28084 AS DESIGN_Y_START,

        dp.hole_name AS DESIGNED_AS_HOLENAME,

        DHC.PUSHBACK,
        DHC.plan_creation_ts_local,

        ROW_NUMBER() OVER (
            PARTITION BY dp.hole_start_meters_y, dp.hole_st