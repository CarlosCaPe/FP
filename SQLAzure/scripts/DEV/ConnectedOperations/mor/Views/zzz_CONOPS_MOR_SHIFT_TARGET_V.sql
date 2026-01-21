CREATE VIEW [mor].[zzz_CONOPS_MOR_SHIFT_TARGET_V] AS


--select * from [mor].[CONOPS_MOR_SHIFT_TARGET_V]

CREATE VIEW [mor].[zzz_CONOPS_MOR_SHIFT_TARGET_V]
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
e.EFHTarget
from [mor].[CONOPS_MOR_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [mor].[shift_info] (NOLOCK)) b
on a.shiftid = b.shiftid AND a.siteflag = 'MOR'

LEFT JOIN (
SELECT site_code,site_offset_hour from [dbo].[opsportal_site] (NOLOCK)) c
on a.siteflag = c.site_code AND a.siteflag = 'MOR'

LEFT JOIN (
SELECT case when right(shiftid,1) = 1 THEN concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'001')
ELSE concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'002')
END AS Formatshiftid,
sum(cast(tons as integer)) as ShiftTarget
FROM [mor].[plan_values] (NOLOCK)
group by shiftid) d on a.shiftid = d.Formatshiftid AND a.siteflag = 'MOR'

LEFT JOIN (
SELECT substring(replace(DateEffective,'-',''),3,4) as shiftdate,
EquivalentFlatHaul as EFHtarget
FROM [mor].[plan_values_prod_sum] (nolock)) e
on left(a.shiftid,4) = e.shiftdate AND a.siteflag = 'MOR'

) XX

WHERE xx.siteflag = 'MOR'
--group by siteflag,shiftflag,shiftid

