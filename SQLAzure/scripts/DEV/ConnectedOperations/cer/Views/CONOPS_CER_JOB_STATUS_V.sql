CREATE VIEW [cer].[CONOPS_CER_JOB_STATUS_V] AS

--SELECT * FROM CER.CONOPS_CER_JOB_STATUS_V
CREATE VIEW CER.CONOPS_CER_JOB_STATUS_V
AS

WITH TimezoneDiff AS(
SELECT
	current_utc_offset
FROM CER.CONOPS_CER_SHIFT_INFO_V
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
--WHERE JOB_QUEUE IN ('JC_DSP_CONOPS_CER')

--UNION

SELECT
	JOB_NAME,
	'Actual Snowflake' AS JOB_TYPE,
	NULL AS MAX_DATA_UTC,
	dw_load_ts AS MAX_DATA_LOAD_UTC,
	15 AS JOB_SCHEDULE_MINS,
	45 AS JOB_ALERT_MINS
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_NAME IN ('job_conops_equipment_hourly_status_CER', 'job_conops_asset_efficiency_CER', 
'job_conops_drill_utilization_CER', 'job_conops_delta_c', 'job_conops_ios_stockpile_levels', 
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
	TABLE_NAME,
	JOB_TYPE,
	MAX_DATA_LOCAL_TS,
	MAX_DATA_LOAD_UTC,
	JOB_SCHEDULE_MINS,
	120 AS JOB_ALERT_MINS
FROM(
	SELECT
		'CER_SP_To_SQLMI_PlanValuesShovel' AS JOB_NAME,
		'plan_values_shovel' AS TABLE_NAME,
		'Shift Target' AS JOB_TYPE,
		CASE 
			WHEN TURNO = 'Dia' THEN 
				DATEADD(HOUR, 19, DATEADD(MINUTE, 30, CAST(FECHA AS DATETIME)))
			ELSE 
				DATEADD(HOUR, 31, DATEADD(MINUTE, 30, CAST(FECHA AS DATETIME)))
		END AS MAX_DATA_LOCAL_TS,
		UTC_CREATED_DATE AS MAX_DATA_LOAD_UTC,
		30 AS JOB_SCHEDULE_MINS
	FROM CER.plan_values_shovel WITH(NOLOCK)
) a
ORDER BY ROW_NUMBER() OVER (ORDER BY MAX_DATA_LOCAL_TS DESC)

UNION

SELECT 
	'CER_SP_To_SQLMI_PlanValues' AS JOB_NAME,
	'plan_values' AS TABLE_NAME,
	'Monthly Target' AS JOB_TYPE,
	CAST(MAX(EOMONTH(CONVERT(DATE, '01 ' + TITLE, 113))) AS DATETIME) MAX_DATA_LOCAL_TS,
	MAX(UTC_CREATED_DATE) AS MAX_DATA_LOAD_UTC,
	30 AS JOB_SCHEDULE_MINS,
	120 AS JOB_ALERT_MINS
FROM CER.plan_values WITH(NOLOCK)
),

Final AS(
SELECT
	JOB_NAME,
	REPLACE(REPLACE(JOB_NAME, 'job_conops_', ''), '_CER', '') AS TABLE_NAME,
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
	'CER' AS SITE_CODE,
	f.JOB_NAME,
	UPPER(f.TABLE_NAME) AS TABLE_NAME,
	f.JOB_TYPE,
	f.MAX_DATA_LOCAL_TS,
	f.MAX_DATA_LOAD_LOCAL_TS,
	MAX_DATA_LOAD_UTC,
	DATEDIFF(MINUTE, MAX_DATA_LOAD_LOCAL_TS, DATEADD(HOUR