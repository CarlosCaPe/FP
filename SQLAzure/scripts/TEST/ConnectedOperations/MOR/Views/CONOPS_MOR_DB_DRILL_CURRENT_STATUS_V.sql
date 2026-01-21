CREATE VIEW [MOR].[CONOPS_MOR_DB_DRILL_CURRENT_STATUS_V] AS

--SELECT * FROM MOR.CONOPS_MOR_DB_DRILL_CURRENT_STATUS_V
CREATE VIEW MOR.CONOPS_MOR_DB_DRILL_CURRENT_STATUS_V
AS
SELECT 
	CONCAT(d.site_code, '_', equip_name) AS site_eqmt
	,d.site_code
	,CAST(LEFT(d.drill_start_ts_local, 23) AS DATETIME) AS shiftdate
	,d.drill_hole_shift_id AS shift
	,d.system_operator_id AS operator_id
	,d.drill_start_ts_local AS starttime_ts
	,d.drill_hole_duration_seconds AS duration_seconds
	,CASE d.drill_hole_status
		WHEN 1 THEN 'Down'
		WHEN 2 THEN 'Ready'
		WHEN 3 THEN 'Spare'
		WHEN 4 THEN 'Delay'
		WHEN 5 THEN 'Shiftchange'
		END AS statusname
	,e.equip_name AS eqmt
	,e.equip_category AS unit
	-- autodrill.AutoDrillEnabled
	,CASE 
		WHEN (d.autodrill_duration_seconds / NULLIF(d.system_drill_state_duration_seconds, 0)) >= 0.5
			THEN 1
		ELSE 0
		END AS AutoDrillEnabled
FROM SNOWFLAKE_WG.dbo.drill_cycle AS d WITH(NOLOCK)
INNER JOIN SNOWFLAKE_WG.dbo.drillblast_equipment AS e
	ON d.site_code = e.site_code
	AND d.drill_id = e.drill_id
--LEFT JOIN autodrill
--    ON e.serial_number = autodrill.RIG_NAME AND d.site_code = autodrill.SITE
WHERE CAST(LEFT(d.drill_start_ts_local, 23) AS DATETIME) >= DATEADD(DAY, - 2, GETDATE())
	AND d.site_code = 'MOR' --LIKE '%MOR%'
	AND d.drill_start_ts_local = (
		SELECT MAX(dc.drill_start_ts_local)
		FROM SNOWFLAKE_WG.dbo.drill_cycle dc WITH(NOLOCK)
		WHERE dc.site_code = d.site_code
			AND dc.drill_id = d.drill_id
		);

