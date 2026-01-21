CREATE VIEW [MOR].[CONOPS_MOR_DB_AVG_HOLES_PER_DAY_V] AS


--SELECT * FROM MOR.CONOPS_MOR_DB_AVG_HOLES_PER_DAY_V
CREATE VIEW MOR.CONOPS_MOR_DB_AVG_HOLES_PER_DAY_V
AS

WITH recent_holes AS (
SELECT 
    dc.pushback
	,dc.site_code
	,dc.drill_hole_status
	,CASE 
		WHEN dp.site_code = 'MOR'
			THEN CASE 
					WHEN TRY_CAST(LEFT(dp.original_pattern_name, 3) AS INT) IS NULL
						THEN SUBSTRING(dp.original_pattern_name, 4, 5)
					WHEN TRY_CAST(LEFT(dp.original_pattern_name, 10) AS BIGINT) IS NOT NULL
						THEN dp.original_pattern_name
					ELSE LEFT(dp.original_pattern_name, 5)
					END
		ELSE dp.original_pattern_name
		END AS pattern_no
	,CAST(LEFT(dc.start_hole_ts_local, 10) AS DATE) AS start_hole_date
	,dc.drill_hole_name
	,dc.drill_id
	,DENSE_RANK() OVER (
		PARTITION BY dc.pushback ORDER BY CAST(LEFT(dc.start_hole_ts_local, 10) AS DATE) DESC
		) AS start_date_rank
	,ROW_NUMBER() OVER (
		PARTITION BY dc.ACTUAL_DRILL_HOLE_START_METERS_X
		,dc.ACTUAL_DRILL_HOLE_START_METERS_Y ORDER BY dc.PLAN_CREATION_TS_LOCAL DESC
		) AS rn
FROM SNOWFLAKE_WG.dbo.DRILL_CYCLE AS dc WITH(NOLOCK)
LEFT JOIN SNOWFLAKE_WG.dbo.DRILL_PLAN AS dp WITH(NOLOCK)
	ON dc.drill_plan_sk = dp.drill_plan_sk
WHERE dc.site_code = 'MOR' -- ILIKE → LIKE
	AND dc.drill_hole_status IN (2, 6)
	AND CAST(LEFT(dc.start_hole_ts_local, 10) AS DATE) <= DATEADD(DAY, - 1, GETDATE())
	AND dc.pushback IS NOT NULL
	-- Uncomment if you want to filter by most recent start dates (Snowflake's comment hinted this)
	-- AND start_date_rank <= 7
),

per_pit_per_day AS (
SELECT 
    pushback
	,start_hole_date
	,COUNT(drill_hole_name) AS hole_count
	,COUNT(DISTINCT drill_id) AS drill_count
FROM recent_holes
WHERE rn = 1
	AND start_date_rank <= 7 -- QUALIFY rn = 1 → WHERE rn = 1
GROUP BY pushback
	,start_hole_date -- GROUP BY ALL → explicit columns
)

SELECT 
    pushback
	,SUM(hole_count) AS total_holes
	,SUM(drill_count) AS total_drills
	,CAST(SUM(hole_count) AS DECIMAL(18, 2)) / NULLIF(SUM(drill_count), 0) AS avg_holes_per_drill_per_day
FROM per_pit_per_day
GROUP BY pushback;


