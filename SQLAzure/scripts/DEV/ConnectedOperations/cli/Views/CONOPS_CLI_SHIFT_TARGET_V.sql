CREATE VIEW [cli].[CONOPS_CLI_SHIFT_TARGET_V] AS







--select * from [cli].[CONOPS_CLI_SHIFT_TARGET_V]

CREATE VIEW [cli].[CONOPS_CLI_SHIFT_TARGET_V]
AS


SELECT xx.siteflag,xx.shiftflag,xx.shiftid,xx.ShiftTarget,
CASE WHEN xx.ShiftCompleteHour IS NULL THEN xx.ShiftTarget ELSE
cast((xx.ShiftCompleteHour/12.0)*xx.ShiftTarget as integer) END as TargetValue,
xx.EFHTarget as EFHShiftTarget,
CASE WHEN xx.ShiftCompleteHour IS NULL THEN xx.EFHTarget ELSE
cast((xx.ShiftCompleteHour/12.0)*xx.EFHTarget as integer) END as EFHTarget
FROM(

select a.siteflag,a.shiftflag,a.shiftid,b.ShiftStartDateTime,b.ShiftEndDateTime,
dateadd(hour,c.site_offset_hour,GETUTCDATE()) as current_local_time,
CASE WHEN a.shiftflag = 'PREV' THEN 
datediff(hour,b.ShiftStartDateTime,b.ShiftEndDateTime) 
WHEN a.shiftflag = 'CURR' THEN 
datediff(hour,b.ShiftStartDateTime,dateadd(hour,c.site_offset_hour,GETUTCDATE()))
ELSE NULL END as ShiftCompleteHour,
d.ShiftTarget,
22616 EFHTarget
from [cli].[CONOPS_CLI_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [cli].[shift_info] (NOLOCK)) b
on a.shiftid = b.shiftid 

CROSS JOIN (
SELECT site_offset_hour from [dbo].[opsportal_site] (NOLOCK)
WHERE site_code = 'CLI') c


LEFT JOIN (
SELECT case when right(shiftid,1) = 1 THEN concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'001')
ELSE concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'002')
END AS Formatshiftid,
sum(cast(TotalTonsMined as integer)) as ShiftTarget
FROM [cli].[plan_values] (NOLOCK)
group by shiftid) d on a.shiftid = d.Formatshiftid 

) XX




