CREATE VIEW [TYR].[CONOPS_TYR_JOB_STATUS_V] AS

--SELECT * FROM TYR.CONOPS_TYR_JOB_STATUS_V
CREATE VIEW TYR.CONOPS_TYR_JOB_STATUS_V
AS

WITH TimezoneDiff AS(
SELECT
	current_utc_offset
FROM TYR.CONOPS_TYR_SHIFT_INFO_V
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
--WHERE JOB_QUEUE IN ('JC_DSP_CONOPS_TYR')

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
'job_conops_equipment_hourly_status_TYR_2', 'job_conops_asset_efficiency_TYR', 'job_conops_drill_utilization_TYR_2',
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
SELECT
	'TYR_SP_To_SQLMI_PlanValues' AS JOB_NAME,
	'plan_values' AS TABLE_NAME,
	'Shift Target' AS JOB_TYPE,
	CASE 
        WHEN RIGHT(MAX(formatshiftid), 3) = '001' THEN 
            DATEADD(HOUR, 12, CONVERT(DATETIME, '20' + LEFT(MAX(formatshiftid), 6) + ' 07:00', 120))
        ELSE 
            DATEADD(HOUR, 12, CONVERT(DATETIME, '20' + LEFT(MAX(formatshiftid), 6) + ' 19:00', 120))
    END AS MAX_DATA_LOCAL_TS,
	MAX(UTC_CREATED_DATE) AS MAX_DATA_LOAD_UTC,
	30 AS JOB_SCHEDULE_MINS,
	120 AS JOB_ALERT_MINS
FROM TYR.plan_values pv WITH(NOLOCK)
),

Final AS(
SELECT
	JOB_NAME,
	REPLACE(REPLACE(JOB_NAME, 'job_conops_', ''), '_TYR', '') AS TABLE_NAME,
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
	'TYR' AS SITE_CODE,
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



