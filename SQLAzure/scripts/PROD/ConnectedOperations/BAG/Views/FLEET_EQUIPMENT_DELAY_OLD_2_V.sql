CREATE VIEW [BAG].[FLEET_EQUIPMENT_DELAY_OLD_2_V] AS

--SELECT * FROM BAG.FLEET_EQUIPMENT_DELAY_NEW_V
CREATE VIEW BAG.FLEET_EQUIPMENT_DELAY_NEW_V
AS

WITH cte AS (
SELECT DISTINCT
	d.TARGET_MACHINE AS EQUIPMENT_ID
	,cd.DELAY_CLASS_OID
	,cd.DELAY_CLASS_NAME
	,d.START1_UTC AS start_time_utc
	,CASE WHEN d.FINISH_UTC IS NULL
		THEN GETUTCDATE()
		ELSE d.FINISH_UTC
		END AS end_time_utc
	,d.description
	,CD.OID
	,ROW_NUMBER() OVER(PARTITION BY d.delay_oid ORDER BY cd.OID DESC) AS RN
FROM BAG_MSHIST.dbo.DELAY d WITH(NOLOCK)
LEFT JOIN BAG_MSHIST.dbo.CYCLEDELAY cd WITH(NOLOCK)
	ON cd.delayoid = d.delay_oid
LEFT JOIN BAG_MSMODEL.dbo.MACHINE m WITH(NOLOCK)
	ON d.TARGET_MACHINE = m.MACHINE_OID
WHERE (d.FINISH_UTC >= DATEADD(DAY, -2, CAST(GETDATE() AS DATE)) OR d.FINISH_UTC IS NULL)
	AND d.TARGET_MACHINE IS NOT NULL
	AND CD.OID IS NOT NULL
),

cteD AS(
SELECT
	c.EQUIPMENT_ID
	,c.DELAY_CLASS_OID
	,c.DELAY_CLASS_NAME
	,c.start_time_utc
	,c.end_time_utc
	,c.description
	,c.OID
FROM cte c
WHERE RN = 1
),

cycle_delay AS(
--cross shift delays that need splitting.
SELECT
	c.OID
	,'BAG' AS site_code
	,c.EQUIPMENT_ID
	,c.DELAY_CLASS_OID AS status_event_reason_id
	,c.DELAY_CLASS_NAME AS name
	,c.description AS description
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
FROM BAG_MSMODEL.dbo.SHIFT shift WITH(NOLOCK)
CROSS APPLY (
	SELECT 
		c.EQUIPMENT_ID
		,c.DELAY_CLASS_OID
		,c.DELAY_CLASS_NAME
		,c.start_time_utc
		,c.end_time_utc
		,c.description
		,c.OID
	FROM cteD AS c
	WHERE 
	(
		shift.starttime_utc >= c.start_time_utc 
		AND shift.starttime_utc < c.end_time_utc
		)
	OR (
		shift.endtime_utc > c.start_time_utc 
		AND shift.endtime_utc <= c.end_time_utc
		)
) AS c

UNION -- needs to be union rather than union all, to eliminate the duplicates/overlapping records from both scripts.

--delays that fall within a shift. These delays do not need splitting.
SELECT
	c.OID
	,'BAG' AS site_code
	,c.EQUIPMENT_ID
	,c.DELAY_CLASS_OID AS status_event_reason_id
	,c.DELAY_CLASS_NAME AS name
	,c.description AS description
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
FROM BAG_MSMODEL.dbo.SHIFT shift WITH(NOLOCK)
CROSS APPLY (
	SELECT 
		c.EQUIPMENT_ID
		,c.DELAY_CLASS_OID
		,c.DELAY_CLASS_NAME
		,c.start_time_utc
		,c.end_time_utc
		,c.description
		,c.OID
	FROM cteD AS c
	WHERE 
	(
		c.start_time_utc BETWEEN shift.starttime_utc
		AND shift.endtime_utc
		)
	AND (
		c.end_time_utc BETWEEN shift.starttime_utc
		AND shift.endtime_utc
		)
) AS c
)

SELECT CD.site_code
	,CD.equipment_id
	,CD.shift_id
	,CD.shift_id_co
	,CD.shift_oid
	,CD.shifttype
	,CD.shift_reporting_date
	,CD.shift_start
	,CD.shift_end
	,CD.oid AS cycle_id
	,CD.status_event_reason_id
	,CD.splitted_startime AS start_ts_utc
	,CD.splitted_