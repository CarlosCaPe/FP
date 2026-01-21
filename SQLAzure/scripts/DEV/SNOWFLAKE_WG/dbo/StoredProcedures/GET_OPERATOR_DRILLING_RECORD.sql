CREATE   PROCEDURE dbo.GET_OPERATOR_DRILLING_RECORD
    @SiteCode      NVARCHAR(20) = N'MOR',         -- Site code filter (default MOR)
    @DaysBack      INT          = 1,              -- How many days back from today to include
    @TopN          INT          = 3              -- Top N most recent drill plans per Rig+Operator+Site
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Input window: from (today - @DaysBack) at 00:00 local to now
    -------------------------------------------------------------------------
    DECLARE @StartDate DATE = CAST(DATEADD(DAY, -@DaysBack, GETDATE()) AS DATE);

    ;WITH RankedHoles AS (
        SELECT
            dc.site_code,
            dp.pattern_name AS drill_plan_name,
            dc.drill_hole_name AS hole_name,
            DE.EQUIP_NAME AS RIG_NAME,
            o.operator_name,
            TRY_CONVERT(datetime2(3), LEFT(dc.start_hole_ts_local, 23))  as start_hole_ts_local,
            CASE
                WHEN dc.system_drill_state_duration_seconds IS NOT NULL
                     AND dc.system_drill_state_duration_seconds <> 0
                     AND (CAST(dc.autodrill_duration_seconds AS FLOAT)
                          / CAST(dc.system_drill_state_duration_seconds AS FLOAT)) >= 0.5
                THEN 1 ELSE 0
            END AS Auto_drill,
            CASE
                WHEN dc.system_drill_state_duration_seconds IS NOT NULL
                     AND dc.system_drill_state_duration_seconds <> 0
                     AND (CAST(dc.autodrill_duration_seconds AS FLOAT)
                          / CAST(dc.system_drill_state_duration_seconds AS FLOAT)) < 0.5
                THEN 1 ELSE 0
            END AS Manual,
            TRY_CONVERT(datetime2(3), LEFT(dp.plan_creation_ts_local, 23))  AS drill_createdate,
            ROW_NUMBER() OVER (
                PARTITION BY o.operator_name, DE.EQUIP_NAME , dp.pattern_name, dc.site_code
                ORDER BY dp.plan_creation_ts_local DESC
            ) AS rn
        FROM dbo.DRILL_CYCLE AS dc
        left JOIN dbo.DRILL_PLAN  AS dp
          ON dc.drill_plan_sk = dp.drill_plan_sk
        LEFT JOIN dbo.DRILLBLAST_EQUIPMENT AS DE 
        ON dc.DRILL_ID = DE.DRILL_ID
       AND dc.SITE_CODE = DE.SITE_CODE
        LEFT JOIN dbo.DRILLBLAST_OPERATOR AS O
        ON DC.SYSTEM_OPERATOR_ID = RIGHT(REPLICATE('0', 10) + O.APPLICATION_OPERATOR_ID, 10)
       AND DC.SITE_CODE = O.SITE_CODE
        WHERE
            TRY_CONVERT(datetime2(3), LEFT(dc.start_hole_ts_local, 23))  >=@StartDate
            AND dc.site_code = @SiteCode
    )
    
        SELECT
            site_code,
            drill_plan_name,
            rig_name,
            operator_name,
            SUM(Auto_drill)  AS autos,
            SUM(Manual)      AS manuals,
            MAX(start_hole_ts_local) AS latest_ts
        FROM RankedHoles
        WHERE rn <= @TopN
        GROUP BY
            site_code,
            drill_plan_name,
            rig_name,
            operator_name
  
END;
