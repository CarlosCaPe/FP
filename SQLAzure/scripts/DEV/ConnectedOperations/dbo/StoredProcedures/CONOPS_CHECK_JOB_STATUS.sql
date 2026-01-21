




/******************************************************************    
* PROCEDURE		: [DBO].[CONOPS_CHECK_JOB_STATUS]   
* PURPOSE		: Upsert [CONOPS_CHECK_JOB_STATUS]  
* NOTES			:   
* CREATED		: GGOSAL1  
* SAMPLE		: EXEC DBO.[CONOPS_CHECK_JOB_STATUS]  
* MODIFIED DATE	 AUTHOR		DESCRIPTION    
*------------------------------------------------------------------       
* {05 DEC 2023}  {GGOSAL1}  {Initial Created}
*******************************************************************/    
CREATE  PROCEDURE [dbo].[CONOPS_CHECK_JOB_STATUS]   
AS  
BEGIN  

--Check Job Dispatch (Interval 2 mins)
SELECT
	'Dispatch' AS job_type,
	2 AS job_interval_min,
	job_name,
	job_queue as job_chain,
	dw_load_ts as last_load_utc,
	DATEDIFF(mi, dw_load_ts, GETUTCDATE()) AS late_mins
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN (
'JC_DSP_CONOPS_BAG','JC_DSP_CONOPS_CER','JC_DSP_CONOPS_CLI','JC_DSP_CONOPS_CHI','JC_DSP_CONOPS_MOR','JC_DSP_CONOPS_SAF','JC_DSP_CONOPS_SIE','JC_DSP_CONOPS_ABR','JC_DSP_CONOPS_TYR'
)
AND dw_load_ts < DATEADD(mi,-30,GETUTCDATE())

UNION

--Check Job Snowflake (Interval 15 mins)
SELECT
	'Snowflake' AS job_type,
	15 AS job_interval_min,
	job_name,
	job_queue as job_chain,
	dw_load_ts as last_load_utc,
	DATEDIFF(mi, dw_load_ts, GETUTCDATE()) AS late_mins
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN (
'JC_SF_CONOPS','JC_SF_CONOPS_DRILL', 'JC_SF_CONOPS_EQ_HR_STS_ASSET_EFF'
)
AND dw_load_ts < DATEADD(mi,-45,GETUTCDATE())

UNION

--Check Job Snowflake (Interval 1 hour)
SELECT
	'Snowflake' AS job_type,
	60 AS job_interval_min,
	job_name,
	job_queue as job_chain,
	dw_load_ts as last_load_utc,
	DATEDIFF(mi, dw_load_ts, GETUTCDATE()) AS late_mins
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN ('JC_SF_CONOPS_1HR')
AND dw_load_ts < DATEADD(mi,-180,GETUTCDATE())

UNION

--Check Job Snapshot (Interval 2 mins)
SELECT
	'Snapshot' AS job_type,
	2 AS job_interval_min,
	job_name,
	job_queue as job_chain,
	dw_load_ts as last_load_utc,
	DATEDIFF(mi, dw_load_ts, GETUTCDATE()) AS late_mins
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN ('JC_CONOPS_SNAP')
AND dw_load_ts < DATEADD(mi,-10,GETUTCDATE())

UNION

--Check Job Snapshot (Interval 3 mins)
SELECT
	'Snapshot' AS job_type,
	3 AS job_interval_min,
	job_name,
	job_queue as job_chain,
	dw_load_ts as last_load_utc,
	DATEDIFF(mi, dw_load_ts, GETUTCDATE()) AS late_mins
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN ('JC_CONOPS_SNAP_3MIN')
AND dw_load_ts < DATEADD(mi,-12,GETUTCDATE())

UNION

--Check Job Snapshot (Interval 15 mins)
SELECT
	'Snapshot' AS job_type,
	15 AS job_interval_min,
	job_name,
	job_queue as job_chain,
	dw_load_ts as last_load_utc,
	DATEDIFF(mi, dw_load_ts, GETUTCDATE()) AS late_mins
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN ('JC_CONOPS_SNAP_15MIN')
AND dw_load_ts < DATEADD(mi,-45,GETUTCDATE())

UNION

--Check Job ADF (Interval 1 hour)
SELECT
	'ADF' AS job_type,
	60 AS job_interval_min,
	job_name,
	job_queue as job_chain,
	dw_load_ts as last_load_utc,
	DATEDIFF(mi, dw_load_ts, GETUTCDATE()) AS late_mins
FROM dbo.DI_JOB_CONTROL_ENTRY_TS_BASE WITH(NOLOCK)
WHERE JOB_QUEUE IN ('ADF')
AND dw_load_ts < DATEADD(mi,-180,GETUTCDATE())


END

