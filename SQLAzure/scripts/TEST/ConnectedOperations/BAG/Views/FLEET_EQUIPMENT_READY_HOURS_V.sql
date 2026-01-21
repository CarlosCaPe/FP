CREATE VIEW [BAG].[FLEET_EQUIPMENT_READY_HOURS_V] AS

CREATE VIEW BAG.FLEET_EQUIPMENT_READY_HOURS_V
AS

WITH cycle_activity AS(
--cross shift activities that need splitting.
SELECT c.OID
	,'BAG' AS site_code
	,c.name
	,c.start_time_utc
	,c.end_time_utc
	,CAST(shift.reporting_date AS VARCHAR) + CAST(shift.shifttype AS VARCHAR) AS shift_id
	,RIGHT(CAST(shift.reporting_date AS VARCHAR), 6) + '00' + CAST(shift.shifttype + 1 AS VARCHAR) AS shift_id_co
	,shift.OID AS SHIFT_OID
	,shift.shifttype AS shifttype
	,shift.reporting_date AS shift_reporting_date
	,shift.starttime_utc AS shift_start
	,shift.endtime_utc AS shift_end
	,CASE WHEN shift.starttime_utc >= c.start_time_utc THEN shift.starttime_utc ELSE c.start_time_utc END AS splitted_startime
	,CASE WHEN shift.endtime_utc <= c.end_time_utc THEN shift.endtime_utc ELSE c.end_time_utc END AS splitted_endtime
FROM BAG_MSHIST.dbo.CYCLEACTIVITYCOMPONENT c WITH(NOLOCK)
INNER JOIN BAG_MSMODEL.dbo.SHIFT shift WITH(NOLOCK)
	ON (
			(
				shift.starttime_utc >= c.start_time_utc
				AND shift.starttime_utc < c.end_time_utc
				) --2025-02-06
			OR (
				shift.endtime_utc > c.start_time_utc
				AND shift.endtime_utc <= c.end_time_utc
				)
			)
WHERE c.name NOT IN ('Machine.Delay')
--AND c.end_time_utc >= DATEADD(DAY, -2, CAST(GETDATE() AS DATE))
AND c.end_time_utc BETWEEN CAST('2024-01-24' AS DATE) AND CAST('2024-01-25' AS DATE)

UNION -- needs to be union rather than union all, to eliminate the duplicates/overlapping records from both scripts.
		
-- activitties that fall within a shift. These activities do not need splitting.
SELECT c.OID
	,'BAG' AS site_code
	,c.name
	,c.start_time_utc
	,c.end_time_utc
	,CAST(shift.reporting_date AS VARCHAR) + CAST(shift.shifttype AS VARCHAR) AS shift_id
	,RIGHT(CAST(shift.reporting_date AS VARCHAR), 6) + '00' + CAST(shift.shifttype + 1 AS VARCHAR) AS shift_id_co
	,shift.OID AS SHIFT_OID
	,shift.shifttype AS shifttype
	,shift.reporting_date AS shift_reporting_date
	,shift.starttime_utc AS shift_start
	,shift.endtime_utc AS shift_end
	,CASE WHEN shift.starttime_utc >= c.start_time_utc THEN shift.starttime_utc ELSE c.start_time_utc END AS splitted_startime
	,CASE WHEN shift.endtime_utc <= c.end_time_utc THEN shift.endtime_utc ELSE c.end_time_utc END AS splitted_endtime
FROM BAG_MSHIST.dbo.CYCLEACTIVITYCOMPONENT c WITH(NOLOCK)
INNER JOIN BAG_MSMODEL.dbo.SHIFT shift WITH(NOLOCK)
	ON (
			(
				c.start_time_utc BETWEEN shift.starttime_utc
					AND shift.endtime_utc
				)
			AND (
				c.end_time_utc BETWEEN shift.starttime_utc
					AND shift.endtime_utc
				)
			)
WHERE c.name NOT IN ('Machine.Delay')
--AND c.end_time_utc >= DATEADD(DAY, -2, CAST(GETDATE() AS DATE))
AND c.end_time_utc BETWEEN CAST('2024-01-24' AS DATE) AND CAST('2024-01-25' AS DATE)
),

SER AS(
SELECT 
	DELAYCLASS_OID AS status_event_reason_id
FROM BAG_MSMODEL.dbo.DELAYCLASS WITH(NOLOCK)
WHERE NAME = 'PRODUCTION'
)

SELECT cac.site_code
	,C.primarymachine AS equipment_id
	,CAC.shift_id
	,CAC.shift_id_co
	,CAC.shift_oid
	,CAC.shifttype
	,CAC.shift_reporting_date
	,CAC.shift_start
	,CAC.shift_end
	,cac.oid AS cycle_id
	,SER.status_event_reason_id
	,CAC.splitted_startime AS start_ts_utc
	,CAC.splitted_endtime AS end_ts_utc
	,CAC.name AS name
FROM cycle_activity CAC
LEFT JOIN BAG_MSHIST.dbo.CYCLE c WITH(NOLOCK)
	ON CAC.OID = C.CYCLE_OID
LEFT JOIN SER
	ON 1=1
WHERE splitted_startime <> splitted_endtime

