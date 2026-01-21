CREATE VIEW [BAG].[FLEET_EQUIPMENT_STATUS_EVENT_V] AS

CREATE VIEW BAG.FLEET_EQUIPMENT_STATUS_EVENT_V 

AS

WITH equipment_status_details AS (
	--Getting Delays details
	SELECT site_code AS site_code
		,equipment_id
		,shift_id
		,cycle_id
		,status_event_reason_id
		,start_ts_utc
		,end_ts_utc
		,CASE WHEN trim(cycledelay.description) = '' THEN NULL ELSE cycledelay.description END AS event_comments
	FROM bag.FLEET_EQUIPMENT_DELAY_V cycledelay
	
	UNION ALL
	
	--Getting Ready Hours details
	SELECT site_code
		,equipment_id
		,shift_id
		,cycle_id
		,status_event_reason_id
		,start_ts_utc
		,end_ts_utc
		,NULL AS event_comments
	FROM bag.FLEET_EQUIPMENT_READY_HOURS_V
),--put all the activities of the same type together

activities_list AS (
SELECT 
	cycle_id
	,event_comments
	,status_event_reason_id
	,equipment_id
	,shift_id
	,site_code
	,start_ts_utc
	,end_ts_utc
	,LAG(status_event_reason_id) OVER (
		PARTITION BY site_code
		,shift_id
		,equipment_id
		,cycle_id ORDER BY start_ts_utc
		) AS LAG_activity_group
	,LEAD(status_event_reason_id) OVER (
		PARTITION BY site_code
		,shift_id
		,equipment_id
		,cycle_id ORDER BY start_ts_utc
		) AS LEAD_activity_group
FROM equipment_status_details
),-- Identify the sequence of the reasons across time and categorize them into groups.
-- Later will need to use the group so that the reason can be merged into one single record.

GroupingCTE AS (
SELECT 
	b.cycle_id
	,b.event_comments
	,b.status_event_reason_id
	,b.equipment_id
	,b.shift_id
	,b.site_code
	,b.start_ts_utc
	,b.end_ts_utc
	,b.LAG_activity_group
	,b.LEAD_activity_group
	,SUM(CASE WHEN LAG_activity_group IS NULL THEN 1 WHEN LAG_activity_group = status_event_reason_id THEN 0 WHEN LAG_activity_group <> status_event_reason_id THEN 1 ELSE 0 END) OVER (
		PARTITION BY site_code
		,shift_id ORDER BY start_ts_utc
		) AS grp
FROM activities_list b
),

ready_time AS (
SELECT 
	status_event_reason_id
	,cycle_id
	,shift_id
	,equipment_id
	,site_code
	,MIN(start_ts_utc) AS start_ts_utc
	,MAX(end_ts_utc) AS end_ts_utc
	,event_comments
FROM GroupingCTE
GROUP BY 
	status_event_reason_id
	,cycle_id
	,shift_id
	,equipment_id
	,site_code
	,grp
	,event_comments
--ORDER BY start_ts_utc
),

time_zone AS(
SELECT
	CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) AS current_utc_offset
FROM sys.time_zone_info
WHERE name = 'US Mountain Standard Time'
),

FinalDT AS(
--Final Select
SELECT r.site_code AS site_code
	,coalesce(r.equipment_id, -1) AS equipment_id
	,mca.name AS equipment_category
	,r.site_code + '_' + CONVERT(VARCHAR,r.equipment_id) + '_' + CONVERT(VARCHAR, r.start_ts_utc) AS equipment_status_event_sk
	,coalesce(r.shift_id, '-1') AS shift_id
	,coalesce(r.cycle_id, -1) AS cycle_id
	,coalesce(r.status_event_reason_id, -1) AS status_event_reason_id
	,r.start_ts_utc
	,r.end_ts_utc
	,DATEADD(HOUR, tz.current_utc_offset, r.start_ts_utc) AS start_ts_local
	,DATEADD(HOUR, tz.current_utc_offset, r.end_ts_utc) AS end_ts_local
	,cast(cast(DATEDIFF(second, r.start_ts_utc, r.end_ts_utc) AS DECIMAL(38, 12)) / cast(60 AS DECIMAL(38, 12)) AS DECIMAL(38, 12)) AS dw_duration_mins
	,r.event_comments
	,CASE WHEN (
				LAG(r.status_event_reason_id) OVER (
					PARTITION BY r.site_code
					,r.equipment_id ORDER BY r.equipment_id
						,r.status_event_reason_id
						,r.start_ts_utc
					) IS NULL
				) THEN 1 -- Exception for handling the first values shift_id, cross shift fails 
		WHEN r.status_event_reason_id <> LAG(r.status_event_reason_id) OVER (
				PARTITION BY r.site_code
				,r.equipment_id ORDER BY r.equipment_id
					,r.cycle_id
					,start_ts_utc
				) THEN 1 ELSE 0 END AS distinct_status_event_flag
FROM ready_time r
LEFT JOIN BAG_MSMODEL.dbo.MACHINE m WITH(NOLOCK)
	ON r.equipment_id = m.machine_oid
LEFT JOIN BAG_MSMODEL.dbo.MACHINECLASS mcl WITH(NOLOCK)
	ON m.class = mcl.machineclass_oid
LEFT JOIN BAG_MSMODEL.dbo.MACHINECATEGORY mca WITH(NOLOCK)
	ON mcl.category = m