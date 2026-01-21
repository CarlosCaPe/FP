CREATE VIEW [Arch].[CONOPS_ARCH_SHIFT_TARGET_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_SHIFT_TARGET_V]
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
from [dbo].[SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [Arch].[shift_info] (NOLOCK)) b
on a.shiftid = b.shiftid AND a.siteflag = '<SITECODE>'

LEFT JOIN (
SELECT site_code,site_offset_hour from [dbo].[opsportal_site] (NOLOCK)) c
on a.siteflag = c.site_code AND a.siteflag = '<SITECODE>'

LEFT JOIN (
SELECT 
FORMATSHIFTID,
cast(sum(TOTALMINED) as int) as shifttarget
FROM [Arch].[plan_values]
group by FORMATSHIFTID) d on a.shiftid = d.Formatshiftid AND a.siteflag = '<SITECODE>'

LEFT JOIN (
SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
EFH as EFHtarget
FROM [Arch].[plan_values_prod_sum] (nolock)) e
on left(a.shiftid,4) = e.shiftdate AND a.siteflag = '<SITECODE>'

) XX

--group by siteflag,shiftflag,shiftid
WHERE xx.siteflag = '<SITECODE>'

