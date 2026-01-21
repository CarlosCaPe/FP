CREATE VIEW [cli].[CONOPS_CLI_JOB_STATUS_V] AS

--SELECT * FROM CLI.CONOPS_CLI_JOB_STATUS_V
CREATE VIEW CLI.CONOPS_CLI_JOB_STATUS_V
AS

WITH TimezoneDiff AS(
SELECT
	current_utc_offset
FROM CLI.CONOPS_CLI_SHIFT_INFO_V
WHERE SHIFTFLAG = 'CURR'
),

Actual AS(
--SELECT
--	JOB_NAME,
--	'Actual Dispatch' AS JOB_TYPE,
--	NULL AS MAX_DATA_UTC,
--	dw_load_ts AS MAX_DATA_LOAD_UTC,
--	2 AS JOB_SCHEDULE_MINS,
--	15 AS JOB_ALERT_MINS
--FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
--WHERE JOB_QUEUE IN ('JC_DSP_CONOPS_CLI')

--UNION

SELECT
	JOB_NAME,
	'Actual Snowflake' AS JOB_TYPE,
	NULL AS MAX_DATA_UTC,
	dw_load_ts AS MAX_DATA_LOAD_UTC,
	15 AS JOB_SCHEDULE_MINS,
	45 AS JOB_ALERT_MINS
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_NAME IN ('job_conops_equipment_hourly_status_CLI', 'job_conops_asset_efficiency_CLI', 
'job_conops_drill_utilization_CLI', 'job_conops_delta_c', 'job_conops_ios_stockpile_levels', 
'job_conops_lh_dump', 'job_conops_lh_enum', 'job_conops_lh_equip_list', 
'job_conops_lh_load', 'job_conops_lh_oper_total_sum', 'job_conops_lh_reason', 
'job_conops_mmt_truckload_c', 'job_conops_pit_reason', 'job_conops_shovel_elevation', 
'job_conops_status_event', 'job_conops_cr2_mill', 'job_conops_operator_title', 
'job_conops_operator_personnel_map', 'job_conops_operator_logout', 'job_conops_operator_consecutive_workdays', 
'job_conops_oee','job_conops_fr_drilling_scores','job_conops_crusher_status', 'job_conops_crusher_throughput')

UNION

SELECT
	JOB_NAME,
	'Snapshot 15 Min' AS JOB_TYPE,
	NULL AS MAX_DATA_UTC,
	dw_load_ts AS MAX_DATA_LOAD_UTC,
	15 AS JOB_SCHEDULE_MINS,
	45 AS JOB_ALERT_MINS
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN ('JC_CONOPS_SNAP_15MIN')

UNION

SELECT
	JOB_NAME,
	'Snapshot 2 Min' AS JOB_TYPE,
	NULL AS MAX_DATA_UTC,
	dw_load_ts AS MAX_DATA_LOAD_UTC,
	2 AS JOB_SCHEDULE_MINS,
	15 AS JOB_ALERT_MINS
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN ('JC_CONOPS_SNAP')
AND JOB_NAME IN ('job_conops_crusher_stats')

),

DataCheckTarget AS(
SELECT TOP 1
	JOB_NAME,
	'plan_values' AS TABLE_NAME,
	JOB_TYPE,
	MAX_DATA_LOCAL_TS,
	MAX_DATA_LOAD_UTC,
	JOB_SCHEDULE_MINS,
	120 AS JOB_ALERT_MINS
FROM(
	SELECT
		'CLI_SP_To_SQLMI_PlanValues' AS JOB_NAME,
		'Shift Target' AS JOB_TYPE,
		CASE 
			WHEN RIGHT(ShiftId, 1) = '1' THEN DATEADD(HOUR, 19, CONVERT(DATETIME, LEFT(ShiftId, 10), 101))
			ELSE DATEADD(HOUR, 31, CONVERT(DATETIME, LEFT(ShiftId, 10), 101))
		END AS MAX_DATA_LOCAL_TS,
		UTC_CREATED_DATE AS MAX_DATA_LOAD_UTC,
		30 AS JOB_SCHEDULE_MINS
	FROM CLI.plan_values WITH(NOLOCK)
) a
ORDER BY ROW_NUMBER() OVER (ORDER BY MAX_DATA_LOCAL_TS DESC)

UNION

SELECT 
	'CLI_SP_To_SQLMI_PlanValuesMonthly' AS JOB_NAME,
	'plan_values_monthly_target' AS TABLE_NAME,
	'Monthly Target' AS JOB_TYPE,
	CAST(EOMONTH(MAX(CONVERT(DATE, CAST(YEARVALUE AS VARCHAR(4)) + '-' + LEFT(MONTHVALUE, 2) + '-01'))) AS DATETIME) MAX_DATA_LOCAL_TS,
	MAX(UTC_CREATED_DATE) AS MAX_DATA_LOAD_UTC,
	30 AS JOB_SCHEDULE_MINS,
	120 AS JOB_ALERT_MINS
FROM CLI.plan_values_monthly_target WITH(NOLOCK)
),

Final AS(
SELECT
	JOB_NAME,
	REPLACE(REPLACE(JOB_NAME, 'job_conops_', ''), '_CLI', '') AS TABLE_NAME,
	JOB_TYPE,
	DATEADD(HOUR, current_utc_offset, MAX_DATA_UTC) AS MAX_DATA_LOCAL_TS,
	DATEADD(HOUR, current_utc_offset, MAX_DATA_LOAD_UTC) AS MAX_DATA_LOAD_LOCAL_TS,
	MAX_DATA_LOAD_UTC,
	JOB_SCHEDULE_MINS,
	JOB_ALERT_MINS,
	current_utc_offset
FROM Actual
CROSS JOIN TimezoneDiff

UNION

SELECT
	JOB_NAME,
	TABLE_NAME,
	JOB_TYPE,
	MAX_DATA_LOCAL_TS,
	DATEADD(HOUR, current_utc_offset, MAX_DATA_LOAD_UTC) AS MAX_DATA_LOAD_LOCAL_TS,
	MAX_DATA_LOAD_UTC,
	JOB_SCHEDULE_MINS,
	JOB_ALERT_MINS,
	current_utc_offset
FROM DataCheckTarget
CROSS JOIN TimezoneDiff
)

SELECT
	'CMX' AS SITE_CODE,
	f.JOB_NAME,
	UPPER(f.TABLE_NAME) AS TABLE_NAME,
	f.JOB_TYPE,
	f.MAX_DATA_LOCAL_TS,
	f.MAX_DATA_LOAD_LOCAL_TS,
	MAX_DATA_LOAD_UTC,
	DATEDIFF(MIN