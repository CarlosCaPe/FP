CREATE VIEW [BAG].[FLEET_EQUIPMENT_DELAY_OLD_V] AS

CREATE VIEW BAG.FLEET_EQUIPMENT_DELAY_V
AS

WITH cycle_delay AS(
--cross shift delays that need splitting.
SELECT c.OID
	,'BAG' AS site_code
	,c.DELAY_CLASS_OID AS status_event_reason_id
	,c.DELAY_CLASS_NAME AS name
	,d.description AS description
	,c.start_time_utc
	,c.end_time_utc
	,CAST(shift.reporting_date AS VARCHAR) + CAST(shift.shifttype AS VARCHAR) AS shift_id
	,RIGHT(CAST(shift.reporting_date AS VARCHAR), 6) + '00' + CAST(shift.shifttype + 1 AS VARCHAR) AS shift_id_co
	,shift.OID AS SHIFT_OID
	,CASE WHEN shift.starttime_utc >= c.start_time_utc THEN shift.starttime_utc ELSE c.start_time_utc END AS splitted_startime
	,CASE WHEN shift.endtime_utc <= c.end_time_utc THEN shift.endtime_utc ELSE c.end_time_utc END AS splitted_endtime
FROM BAG_MSHIST.dbo.CYCLEDELAY c WITH(NOLOCK)
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
LEFT JOIN BAG_MSHIST.dbo.DELAY d WITH(NOLOCK)
	ON c.delayoid = d.delay_oid
WHERE c.end_time_utc >= DATEADD(DAY, -2, CAST(GETDATE() AS DATE))

UNION -- needs to be union rather than union all, to eliminate the duplicates/overlapping records from both scripts.

--delays that fall within a shift. These delays do not need splitting.
SELECT c.OID
	,'BAG' AS site_code
	,c.DELAY_CLASS_OID AS status_event_reason_id
	,c.DELAY_CLASS_NAME AS name
	,d.description AS description
	,c.start_time_utc
	,c.end_time_utc
	,CAST(shift.reporting_date AS VARCHAR) + CAST(shift.shifttype AS VARCHAR) AS shift_id
	,RIGHT(CAST(shift.reporting_date AS VARCHAR), 6) + '00' + CAST(shift.shifttype + 1 AS VARCHAR) AS shift_id_co
	,shift.OID AS SHIFT_OID
	,CASE WHEN shift.starttime_utc >= c.start_time_utc THEN shift.starttime_utc ELSE c.start_time_utc END AS splitted_startime
	,CASE WHEN shift.endtime_utc <= c.end_time_utc THEN shift.endtime_utc ELSE c.end_time_utc END AS splitted_endtime
FROM BAG_MSHIST.dbo.CYCLEDELAY c WITH(NOLOCK)
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
LEFT JOIN BAG_MSHIST.dbo.DELAY d WITH(NOLOCK)
	ON c.delayoid = d.delay_oid
WHERE c.end_time_utc >= DATEADD(DAY, -2, CAST(GETDATE() AS DATE))
)

SELECT CD.site_code
	,C.primarymachine AS equipment_id
	,CD.shift_id
	,CD.shift_id_co
	,shift.OID AS shift_oid
	,shift.shifttype AS shifttype
	,shift.reporting_date AS shift_reporting_date
	,shift.starttime_utc AS shift_start
	,shift.endtime_utc AS shift_end
	,CD.oid AS cycle_id
	,CD.status_event_reason_id
	,CD.splitted_startime AS start_ts_utc
	,CD.splitted_endtime AS end_ts_utc
	,CD.name
	,CD.description
FROM cycle_delay CD
LEFT JOIN BAG_MSHIST.dbo.CYCLE c WITH(NOLOCK)
	ON CD.OID = C.CYCLE_OID
LEFT JOIN BAG_MSMODEL.dbo.SHIFT shift WITH(NOLOCK)
	ON (
			CD.start_time_utc >= shift.starttime_utc
			AND CD.start_time_utc < shift.endtime_utc
			)
	AND (
			CD.end_time_utc > shift.starttime_utc
			AND CD.end_time_utc <= shift.endtime_utc
			)
WHERE splitted_startime <> splitted_endtime

