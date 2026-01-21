CREATE VIEW [dbo].[RCS_OPERATOR_DRILLING_RECORD_V] AS

create view [dbo].[RCS_OPERATOR_DRILLING_RECORD_V] as 
WITH RankedHoles AS (
  SELECT
    dc.site_code,
    dp.pattern_name AS drill_plan_name,
    dc.drill_hole_name AS hole_name,
    r.rig_name,
    rdh.operator_name,
    dc.start_hole_ts_local,
    CASE
      WHEN dc.system_drill_state_duration_seconds IS NOT NULL AND dc.system_drill_state_duration_seconds <> 0
           AND (dc.autodrill_duration_seconds / dc.system_drill_state_duration_seconds) >= 0.5 THEN 1
      ELSE 0
    END AS Auto_drill,
    CASE
      WHEN dc.system_drill_state_duration_seconds IS NOT NULL AND dc.system_drill_state_duration_seconds <> 0
           AND (dc.autodrill_duration_seconds / dc.system_drill_state_duration_seconds) < 0.5 THEN 1
      ELSE 0
    END AS Manual,
    dp.plan_creation_ts_local AS drill_createdate,
    ROW_NUMBER() OVER (
      PARTITION BY rdh.operator_name, r.rig_name, dp.pattern_name, dc.site_code
      ORDER BY dp.plan_creation_ts_local DESC
    ) AS rn
  FROM
    dbo.DRILL_CYCLE AS dc
    JOIN dbo.DRILL_PLAN AS dp ON dc.drill_plan_sk = dp.drill_plan_sk
    JOIN dbo.RCS_RIG AS r ON dc.site_code = r.site_code
    JOIN dbo.rcs_drilled_hole AS rdh ON dc.drill_hole_name = rdh.hole_name
  WHERE
    dc.start_hole_ts_local >= CAST(GETDATE() - 1 AS DATE)
    AND dc.site_code = 'MOR'
   
)
SELECT
  site_code,
  drill_plan_name AS drill_plan,
  rig_name,
  operator_name,
  SUM(Auto_drill) AS autos,
  SUM(Manual) AS manuals
FROM
  RankedHoles
WHERE
  rn <= 3
GROUP BY
  site_code,
  drill_plan_name,
  rig_name,
  operator_name;
