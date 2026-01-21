CREATE VIEW [BAG].[CONOPS_BAG_JOB_STATUS_V] AS

--SELECT * FROM BAG.CONOPS_BAG_JOB_STATUS_V
CREATE VIEW BAG.CONOPS_BAG_JOB_STATUS_V
AS

WITH TimezoneDiff AS(
SELECT
	current_utc_offset
FROM bag.CONOPS_BAG_SHIFT_INFO_V
WHERE SHIFTFLAG = 'CURR'
),

Actual AS(
--SELECT
--	JOB_NAME,
--	REPLACE(JOB_NAME, 'pl_bag_fleet_', '') AS TABLE_NAME,
--	'Actual' AS JOB_TYPE,
--	NULL AS MAX_DATA_UTC,
--	DATEADD(HOUR,7,dw_load_ts) AS MAX_DATA_LOAD_UTC,
--	60 AS JOB_SCHEDULE_MINS,
--	120 AS JOB_ALERT_MINS
--FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
--WHERE JOB_QUEUE IN ('ADF')
--AND job_name LIKE 'pl%'
--AND job_name NOT LIKE '%_full'
--AND job_name NOT IN ('pl_bag_fleet_cycle',
--'pl_bag_fleet_cycleactivitycomponent', 'pl_bag_fleet_cycledelay',
--'pl_bag_fleet_machine_in_pit', 'pl_bag_fleet_shift','pl_bag_fleet_virtualbeacon')

--UNION

--SELECT
--	JOB_NAME,
--	REPLACE(JOB_NAME, 'pl_bag_fleet_', '') AS TABLE_NAME,
--	'Actual' AS JOB_TYPE,
--	NULL AS MAX_DATA_UTC,
--	DATEADD(HOUR,7,dw_load_ts) AS MAX_DATA_LOAD_UTC,
--	5 AS JOB_SCHEDULE_MINS,
--	15 AS JOB_ALERT_MINS
--FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
--WHERE JOB_QUEUE IN ('ADF')
--AND job_name LIKE 'pl%'
--AND job_name NOT LIKE '%_full'
--AND job_name IN ('pl_bag_fleet_cycle',
--'pl_bag_fleet_cycleactivitycomponent', 'pl_bag_fleet_cycledelay',
--'pl_bag_fleet_machine_in_pit', 'pl_bag_fleet_shift')

--UNION

SELECT
	JOB_NAME,
	REPLACE(REPLACE(JOB_NAME, 'job_conops_', ''), '_mor', '') AS TABLE_NAME,
	'Actual Snowflake' AS JOB_TYPE,
	NULL AS MAX_DATA_UTC,
	dw_load_ts AS MAX_DATA_LOAD_UTC,
	15 AS JOB_SCHEDULE_MINS,
	45 AS JOB_ALERT_MINS
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_NAME IN ('job_conops_equipment_hourly_status_BAG', 'job_conops_asset_efficiency_BAG', 
'job_conops_drill_utilization_BAG', 'job_conops_delta_c', 'job_conops_ios_stockpile_levels', 
'job_conops_lh_dump', 'job_conops_lh_enum', 'job_conops_lh_equip_list', 
'job_conops_lh_load', 'job_conops_lh_oper_total_sum', 'job_conops_lh_reason', 
'job_conops_mmt_truckload_c', 'job_conops_pit_reason', 'job_conops_shovel_elevation', 
'job_conops_status_event', 'job_conops_cr2_mill', 'job_conops_operator_title', 
'job_conops_operator_personnel_map', 'job_conops_operator_logout', 'job_conops_operator_consecutive_workdays', 
'job_conops_oee','job_conops_fr_drilling_scores','job_conops_crusher_status', 'job_conops_crusher_throughput')

UNION

SELECT
	JOB_NAME,
	REPLACE(REPLACE(JOB_NAME, 'job_conops_', ''), '_mor', '') AS TABLE_NAME,
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
	REPLACE(REPLACE(JOB_NAME, 'job_conops_', ''), '_mor', '') AS TABLE_NAME,
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
	'BAG_SP_To_SQLMI_PlanValues' AS JOB_NAME,
	'plan_values' AS TABLE_NAME,
	'Shift Target' AS JOB_TYPE,
	MAX(s.SHIFTSTARTDATETIME) MAX_DATA_LOCAL_TS,
	MAX(UTC_CREATED_DATE) AS MAX_DATA_LOAD_UTC,
	30 AS JOB_SCHEDULE_MINS,
	120 AS JOB_ALERT_MINS
FROM BAG.plan_values pv WITH(NOLOCK)
LEFT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V s
	ON s.shiftid = pv.formatshiftid

UNION

SELECT 
	'BAG_SP_To_SQLMI_PlanValuesProdSum' AS JOB_NAME,
	'plan_values_prod_sum' AS TABLE_NAME,
	'Monthly Target' AS JOB_TYPE,
	CAST(EOMONTH(MAX(EFFECTIVEDATE)) AS DATETIME) MAX_DATA_LOCAL_TS,
	MAX(UTC_CREATED_DATE) AS MAX_DATA_LOAD_UTC,
	30 AS JOB_SCHEDULE_MINS,
	120 AS JOB_ALERT_MINS
FROM BAG.plan_values_prod_sum WITH(NOLOCK)
),

Final AS(
SELECT
	JOB_NAME,
	TABLE_NAME,
	JOB_TYPE,
	DATEADD(HOUR, current_utc_offset, MAX_