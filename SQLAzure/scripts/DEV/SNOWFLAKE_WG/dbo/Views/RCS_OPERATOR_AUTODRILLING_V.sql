CREATE VIEW [dbo].[RCS_OPERATOR_AUTODRILLING_V] AS



CREATE     VIEW [dbo].[RCS_OPERATOR_AUTODRILLING_V]
AS
-----------------------------------------------------------------------------------------------------------------------
--  DATE                 USERID                  Description
--  Dec 5 2025          61011427                Created new view for operator autodrilling 
--  Dec 8 2025          61011427                Updated the logic to filter only current date data and rows where there is not hole done on autodrilling
-----------------------------------------------------------------------------------------------------------------------
WITH DCX AS (
    SELECT
        dc.*,
        TRY_CONVERT(datetime2(3), LEFT(dc.START_HOLE_TS_LOCAL, 23)) AS start_hole_ts_dt
    FROM dbo.DRILL_CYCLE AS dc
    WHERE dc.SITE_CODE = 'MOR'
      -- If START_HOLE_TS_LOCAL is varchar, this predicate is still non-SARGable; see index notes.
      AND TRY_CONVERT(date, LEFT(dc.START_HOLE_TS_LOCAL, 10)) > DATEADD(DAY, -1, CONVERT(date, SYSDATETIME()))
),
DSX AS (
    SELECT
        ds.*,
        TRY_CONVERT(datetime2(3), LEFT(ds.SHIFT_START_TS_LOCAL, 23)) AS shift_start_dt,
        TRY_CONVERT(datetime2(3), LEFT(ds.SHIFT_END_TS_LOCAL, 23))   AS shift_end_dt
    FROM dbo.DRILLBLAST_SHIFT AS ds
     WHERE ds.SITE_CODE = 'MOR'
)
SELECT
    DCX.SITE_CODE,
    DS.SHIFT_DATE AS SHIFT_DATE,
    DCX.PATTERN_NAME,
    CASE
        WHEN DCX.start_hole_ts_dt IS NOT NULL
             AND DATEPART(HOUR, DCX.start_hole_ts_dt) >= 6
             AND DATEPART(HOUR, DCX.start_hole_ts_dt) < 18
        THEN 'Day Shift'
        ELSE 'Night Shift'
    END AS SHIFT,
    DE.EQUIP_NAME AS RIG_NAME,
    O.APPLICATION_OPERATOR_ID,
    O.OPERATOR_NAME AS FIRST_LAST_NAME,
    SUM(CASE
        WHEN (DCX.AUTODRILL_DURATION_SECONDS / NULLIF(DCX.SYSTEM_DRILL_STATE_DURATION_SECONDS, 0)) >= 0.5 THEN 1
        ELSE 0
    END) AS AUTO_DRILLED_HOLES
FROM DCX
LEFT JOIN dbo.DRILLBLAST_OPERATOR AS O
    ON DCX.SYSTEM_OPERATOR_ID = RIGHT(REPLICATE('0', 10) + O.APPLICATION_OPERATOR_ID, 10)
   AND DCX.SITE_CODE = O.SITE_CODE
LEFT JOIN dbo.DRILLBLAST_EQUIPMENT AS DE 
    ON DCX.DRILL_ID = DE.DRILL_ID
   AND DCX.SITE_CODE = DE.SITE_CODE
LEFT JOIN DSX AS DS
    ON DCX.start_hole_ts_dt IS NOT NULL
   AND DS.shift_start_dt IS NOT NULL
   AND DS.shift_end_dt IS NOT NULL
   AND DCX.start_hole_ts_dt >= DS.shift_start_dt
   AND DCX.start_hole_ts_dt <  DS.shift_end_dt
GROUP BY
    DCX.SITE_CODE,
    DS.SHIFT_DATE,
    DCX.PATTERN_NAME,
    DE.EQUIP_NAME,
    CASE
        WHEN DCX.start_hole_ts_dt IS NOT NULL
             AND DATEPART(HOUR, DCX.start_hole_ts_dt) >= 6
             AND DATEPART(HOUR, DCX.start_hole_ts_dt) < 18
        THEN 'Day Shift'
        ELSE 'Night Shift'
    END,
    O.APPLICATION_OPERATOR_ID,
    O.OPERATOR_NAME
HAVING SUM(CASE
        WHEN (DCX.AUTODRILL_DURATION_SECONDS / NULLIF(DCX.SYSTEM_DRILL_STATE_DURATION_SECONDS, 0)) >= 0.5 THEN 1
        ELSE 0
    END) = 0;
