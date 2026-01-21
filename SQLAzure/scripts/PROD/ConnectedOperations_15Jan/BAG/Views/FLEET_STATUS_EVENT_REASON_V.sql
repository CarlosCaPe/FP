CREATE VIEW [BAG].[FLEET_STATUS_EVENT_REASON_V] AS

CREATE VIEW BAG.FLEET_STATUS_EVENT_REASON_V
AS

WITH CTE AS(
select
delayclass.delayclass_oid as delayclass_oid --as statuseventreasonid
,'BAG' as site_code
,(case 
    when (delayclass.externalref is null or CAST(delayclass.externalref AS INT) is null) then '29'
    when (delayclass.externalref not between -1 and 5500) then '29' -- It is newely added category for the unassigned reasons
    else delayclass.externalref end) as dw_status_event_reason_code
,(case when delayclass.duration=-1 then NULL else delayclass.duration/60 end) as dw_expected_duration_minutes
from BAG_MSMODEL.dbo.DELAYCLASS delayclass WITH(NOLOCK)
)

select
delayclass.delayclass_oid as delayclass_oid --as statuseventreasonid
,'BAG' as site_code
,dw_status_event_reason_code
,reasonmap.reason as reason
,dw_expected_duration_minutes
,reasonmap.time_category_code as time_category_code
,reasonmap.time_category as time_category
,reasonmap.time_category_1 as time_category_1
,reasonmap.time_category_2 as time_category_2
,reasonmap.maint_event as maint_event_flag
,reasonmap.unplanned_maint as unplanned_maint_flag
,reasonmap.planned_maint as planned_maint_flag
,reasonmap.oper_event AS oper_event_flag
from CTE delayclass
left join bag.LH_REASON_MAP reasonmap WITH(NOLOCK)
ON dw_status_event_reason_code = reasonmap.reason_code