CREATE VIEW [dbo].[AVG_HOLES_PER_DAY] AS



CREATE   view [dbo].[AVG_HOLES_PER_DAY] as 
/*
WITH DHC AS (
    SELECT
    pattern_name PATTERN_ID,
    hole_name,
    site_code,
    pushback,
    plan_creation_ts_local,
    ROW_NUMBER() OVER (
      PARTITION BY pattern_name,
      hole_name,
      site_code
      ORDER BY
        plan_creation_ts_local DESC
    ) AS rn
  FROM
    DBO.drill_plan
  WHERE
    NOT pattern_name IS NULL
    AND NOT hole_name IS NULL
),
RECENT_HOLES AS (
    SELECT
        CASE 
            WHEN dplan.site_code = 'MOR' THEN
                CASE 
                    WHEN TRY_CAST(LEFT(dplan.original_plan_id, 3) AS INT) IS NULL THEN SUBSTRING(dplan.original_plan_id, 4, 5)
                    WHEN TRY_CAST(LEFT(dplan.original_plan_id, 10) AS INT) IS NOT NULL THEN dplan.original_plan_id
                    ELSE LEFT(dplan.original_plan_id, 5)
                END
            ELSE dplan.original_plan_id
        END AS pattern_no,
        CASE
            WHEN DH.END_HOLE_TIME IS NULL AND DH.START_HOLE_TIME IS NULL THEN 'UNDRILLED'
            WHEN DH.STATUS = 0 THEN 'UNSPECIFIED'
            WHEN DH.STATUS = 1 THEN 'UNDRILLED'
            WHEN DH.STATUS = 2 THEN 'SUCCESS, DRILLED'
            WHEN DH.STATUS = 3 THEN 'FAIL'
            WHEN DH.STATUS = 4 THEN 'OTHERS'
            WHEN DH.STATUS = 5 THEN 'ABORTED'
            WHEN DH.STATUS = 6 THEN 'REDRILLED'
        END AS DRILL_HOLE_STATUS,
        CAST(DH.START_HOLE_TIME AS DATE) AS START_HOLE_DATE,
        DENSE_RANK() OVER (PARTITION BY DHC.PUSHBACK ORDER BY CAST(DH.START_HOLE_TIME AS DATE) DESC) AS START_DATE_RANK,
        PLH.HOLE_NAME AS DESIGNED_AS_HOLENAME,
        DH.RIG_SERIAL_NUMBER,
        DHC.PUSHBACK,
        ROW_NUMBER() OVER (PARTITION BY PLH.RAW_START_POINT_Y, PLH.RAW_START_POINT_X ORDER BY DPLAN.SRC_CREATE_TS DESC) AS rn
    FROM DBO.RCS_PLANNED_HOLE PLH
    INNER JOIN DHC ON PLH.DRILL_PLAN_ID = DHC.PATTERN_ID
        AND PLH.HOLE_ID = DHC.HOLE_NAME
        AND PLH.SITE_CODE = DHC.SITE_CODE
    LEFT JOIN DBO.RCS_DRILLED_HOLE DH
        ON PLH.SITE_CODE = DH.SITE_CODE
        AND PLH.DRILL_PLAN_ID = DH.DRILL_PLAN_ID
        AND PLH.ORIGINAL_HOLE_ID = DH.HOLE_ID
    LEFT JOIN DBO.RCS_DRILL_PLAN DPLAN
        ON PLH.SITE_CODE = DPLAN.SITE_CODE
        AND PLH.DRILL_PLAN_ID = DPLAN.DRILL_PLAN_ID
    WHERE plh.site_code = 'mor'
        AND (DH.STATUS IN (2, 6)) -- SUCCESS, DRILLED or REDRILLED
        AND CAST(DH.START_HOLE_TIME AS DATE) <= DATEADD(DAY, -1, CURRENT_TIMESTAMP)
        AND DHC.PUSHBACK IS NOT NULL
)
, FILTERED_RECENT AS (
    SELECT *
    FROM RECENT_HOLES
    WHERE rn = 1 AND START_DATE_RANK <= 7
),
PER_PIT_PER_DAY AS (
    SELECT
        PUSHBACK,
        START_HOLE_DATE,
        COUNT(DESIGNED_AS_HOLENAME) AS HOLE_COUNT,
        COUNT(DISTINCT RIG_SERIAL_NUMBER) AS DRILL_COUNT
    FROM FILTERED_RECENT
    GROUP BY PUSHBACK, START_HOLE_DATE
)
SELECT
    PUSHBACK,
    SUM(HOLE_COUNT) AS TOTAL_HOLES,
    SUM(DRILL_COUNT) AS TOTAL_DRILLS,
    CAST(SUM(HOLE_COUNT) AS FLOAT) / NULLIF(SUM(DRILL_COUNT), 0) AS AVG_HOLES_PER_DRILL_PER_DAY
FROM PER_PIT_PER_DAY
GROUP BY PUSHBACK;
*/


WITH recent_holes AS (
    SELECT
        dc.pushback,
        dc.site_code,
        dc.drill_hole_status,
        CASE
            WHEN dp.site_code = 'MOR' THEN
                CASE
                    WHEN TRY_CAST(LEFT(dp.original_pattern_name, 3) AS INT) IS NULL
                        THEN SUBSTRING(dp.original_pattern_name, 4, 5)
                    WHEN TRY_CAST(LEFT(dp.original_pattern_name, 10) AS BIGINT) IS NOT NULL
                        THEN dp.original_pattern_name
                    ELSE LEFT(dp.original_pattern_name, 5)
                END
            ELSE dp.original_pattern_name
        END AS pattern_no,
        CAST(LEFT(dc.start_hole_ts_local,10) AS DATE) AS start_hole_date,
        dc.drill_hole_name,
        dc.drill_id,
        DENSE_RANK() OVER (
            P