CREATE VIEW [SAF].[CONOPS_SAF_JOB_STATUS_V] AS

--SELECT * FROM SAF.CONOPS_SAF_JOB_STATUS_V
CREATE VIEW SAF.CONOPS_SAF_JOB_STATUS_V
AS

WITH TimezoneDiff AS(
SELECT
	current_utc_offset
FROM SAF.CONOPS_SAF_SHIFT_INFO_V
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
--WHERE JOB_QUEUE IN ('JC_DSP_CONOPS_SAF')

--UNION

SELECT
	REPLACE(JOB_NAME, '_2', '') AS JOB_NAME,
	'Actual Snowflake' AS JOB_TYPE,
	NULL AS MAX_DATA_UTC,
	dw_load_ts AS MAX_DATA_LOAD_UTC,
	15 AS JOB_SCHEDULE_MINS,
	45 AS JOB_ALERT_MINS
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_NAME IN (
'job_conops_equipment_hourly_status_SAF_2', 'job_conops_asset_efficiency_SAF', 'job_conops_drill_utilization_SAF_2',
'job_conops_delta_c_2', 'job_conops_ios_stockpile_levels_2', 'job_conops_lh_dump_2',
'job_conops_lh_equip_list_2', 'job_conops_lh_load_2', 'job_conops_lh_oper_total_sum_2',
'job_conops_lh_reason_2', 'job_conops_mmt_truckload_c_2', 'job_conops_pit_reason_2', 
'job_conops_shovel_elevation_2', 'job_conops_status_event_2', 'job_conops_cr2_mill_2',
'job_conops_operator_title_2', 'job_conops_operator_personnel_map_2',
'job_conops_operator_logout_2', 'job_conops_operator_consecutive_workdays_2',
'job_conops_oee_2', 'job_conops_fr_drilling_scores_2',
'job_conops_crusher_status_2', 'job_conops_crusher_throughput_2')

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
AND JOB_NAME NOT IN ('job_conops_fleet_pit_machine_c')

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
		'SAF_SP_To_SQLMI_PlanValues' AS JOB_NAME,
		'Shift Target' AS JOB_TYPE,
		CASE 
			WHEN SHIFTINDEX = '1' THEN 
				DATEADD(HOUR, 18, DATEADD(MINUTE, 15, CAST(DATEEFFECTIVE AS DATETIME)))
			ELSE 
				DATEADD(HOUR, 30, DATEADD(MINUTE, 15, CAST(DATEEFFECTIVE AS DATETIME)))
		END AS MAX_DATA_LOCAL_TS,
		UTC_CREATED_DATE AS MAX_DATA_LOAD_UTC,
		30 AS JOB_SCHEDULE_MINS
	FROM SAF.plan_values WITH(NOLOCK)
) a
ORDER BY ROW_NUMBER() OVER (ORDER BY MAX_DATA_LOCAL_TS DESC)
),

Final AS(
SELECT
	JOB_NAME,
	REPLACE(REPLACE(JOB_NAME, 'job_conops_', ''), '_SAF', '') AS TABLE_NAME,
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
	'SAF' AS SITE_CODE,
	f.JOB_NAME,
	UPPER(f.TABLE_NAME) AS TABLE_NAME,
	f.JOB_TYPE,
	f.MAX_DATA_LOCAL_TS,
	f.MAX_DATA_LOAD_LOCAL_TS,
	MAX_DATA_LOAD_UTC,
	DATEDIFF(MINUTE, MAX_DATA_LOAD_LOCAL_TS, DATEADD(HOUR, current_utc_offset, GETUTCDATE())) AS LATE_MINS,
	JOB_SCHEDULE_MINS,
	JOB_ALERT_MINS,
	ts.SourceType AS SOURCE_TYPE,
	ts.SourceURL AS SOURCE_URL
FROM Final f
LEFT OUTER JOIN dbo.CONOPS_TARGET_SOURCE ts
	ON f.job_name = ts.SourceName

