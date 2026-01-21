

/******************************************************************  
* PROCEDURE	: dbo.CONOPS_JOB_MONITORING_GET
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 25 Oct 2024
* SAMPLE	: 
	1. EXEC dbo.CONOPS_JOB_MONITORING_GET 
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2024}		{ggosal1}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CONOPS_JOB_MONITORING_GET] 
AS                        
BEGIN          

SELECT
SITE_CODE,
JOB_TYPE,
JOB_CHAIN
JOB_NAME,
TABLE_NAME,
LAST_DATA_LOAD_UTC,
JOB_SCHEDULE_MINS,
JOB_ALERT_MINS,
DATEDIFF(MINUTE, LAST_DATA_LOAD_UTC, GETUTCDATE()) AS LATE_MINS
FROM
(	
	--BAG Fleet
	SELECT
		'BAG' AS SITE_CODE,
		'ADF' AS JOB_TYPE,
		'BAG Fleet' AS JOB_CHAIN,
		JOB_NAME,
		REPLACE(JOB_NAME, 'pl_bag_fleet_', '') AS TABLE_NAME,
		DATEADD(HOUR,7,dw_load_ts) AS LAST_DATA_LOAD_UTC,
		60 AS JOB_SCHEDULE_MINS,
		120 AS JOB_ALERT_MINS
	FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
	WHERE JOB_QUEUE IN ('ADF')
	AND job_name LIKE 'pl%'
	AND job_name NOT LIKE '%_full'
	AND job_name NOT IN ('pl_bag_fleet_cycle',
	'pl_bag_fleet_cycleactivitycomponent', 'pl_bag_fleet_cycledelay',
	'pl_bag_fleet_machine_in_pit', 'pl_bag_fleet_shift','pl_bag_fleet_virtualbeacon')

	UNION

	--BAG Fleet (2)
	SELECT
		'BAG' AS SITE_CODE,
		'ADF' AS JOB_TYPE,
		'BAG Fleet' AS JOB_CHAIN,
		JOB_NAME,
		REPLACE(JOB_NAME, 'pl_bag_fleet_', '') AS TABLE_NAME,
		DATEADD(HOUR,7,dw_load_ts) AS LAST_DATA_LOAD_UTC,
		5 AS JOB_SCHEDULE_MINS,
		15 AS JOB_ALERT_MINS
	FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
	WHERE JOB_QUEUE IN ('ADF')
	AND job_name LIKE 'pl%'
	AND job_name NOT LIKE '%_full'
	AND job_name IN ('pl_bag_fleet_cycle',
	'pl_bag_fleet_cycleactivitycomponent', 'pl_bag_fleet_cycledelay',
	'pl_bag_fleet_machine_in_pit', 'pl_bag_fleet_shift')

	UNION

	--Dispatch Job
	SELECT
		RIGHT(JOB_QUEUE, 3) AS SITE_CODE,
		'BO Data Services' AS JOB_TYPE,
		JOB_QUEUE AS JOB_CHAIN,
		JOB_NAME,
		REPLACE(REPLACE(JOB_NAME, 'job_conops_', ''), RIGHT(JOB_NAME, 4), '') AS TABLE_NAME,
		dw_load_ts AS LAST_DATA_LOAD_UTC,
		2 AS JOB_SCHEDULE_MINS,
		15 AS JOB_ALERT_MINS
	FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
	WHERE JOB_QUEUE IN ('JC_DSP_CONOPS_CER', 'JC_DSP_CONOPS_CHI', 'JC_DSP_CONOPS_CLI', 
	'JC_DSP_CONOPS_MOR', 'JC_DSP_CONOPS_SAF', 'JC_DSP_CONOPS_SIE', 'JC_DSP_CONOPS_ABR', 'JC_DSP_CONOPS_TYR')

	UNION

	--Snapshot 15 Mins
	SELECT
		'All Sites' AS SITE_CODE,
		'BO Data Services' AS JOB_TYPE,
		JOB_QUEUE AS JOB_CHAIN,
		JOB_NAME,
		REPLACE(JOB_NAME, 'job_conops_', '') AS TABLE_NAME,
		dw_load_ts AS LAST_DATA_LOAD_UTC,
		15 AS JOB_SCHEDULE_MINS,
		45 AS JOB_ALERT_MINS
	FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
	WHERE JOB_QUEUE IN ('JC_CONOPS_SNAP_15MIN')

	UNION

	--Snapshot 2 Mins
	SELECT
		'All Sites' AS SITE_CODE,
		'BO Data Services' AS JOB_TYPE,
		JOB_QUEUE AS JOB_CHAIN,
		JOB_NAME,
		REPLACE(JOB_NAME, 'job_conops_', '') AS TABLE_NAME,
		dw_load_ts AS LAST_DATA_LOAD_UTC,
		2 AS JOB_SCHEDULE_MINS,
		15 AS JOB_ALERT_MINS
	FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
	WHERE JOB_QUEUE IN ('JC_CONOPS_SNAP')
	AND JOB_NAME IN ('job_conops_crusher_stats')

	UNION

	--Snapshot 3 Mins
	SELECT
		'All Sites' AS SITE_CODE,
		'BO Data Services' AS JOB_TYPE,
		JOB_QUEUE AS JOB_CHAIN,
		JOB_NAME,
		REPLACE(JOB_NAME, 'job_conops_', '') AS TABLE_NAME,
		dw_load_ts AS LAST_DATA_LOAD_UTC,
		3 AS JOB_SCHEDULE_MINS,
		21 AS JOB_ALERT_MINS
	FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
	WHERE JOB_QUEUE IN ('JC_CONOPS_SNAP_3MIN')

	UNION

	--Snowflake
	SELECT
		'All Sites' AS SITE_CODE,
		'BO Data Services' AS JOB_TYPE,
		JOB_QUEUE AS JOB_CHAIN,
		JOB_NAME,
		REPLACE(JOB_NAME, 'job_conops_', '') AS TABLE_NAME,
		dw_load_ts AS LAST_DATA_LOAD_UTC,
		15 AS JOB_SCHEDULE