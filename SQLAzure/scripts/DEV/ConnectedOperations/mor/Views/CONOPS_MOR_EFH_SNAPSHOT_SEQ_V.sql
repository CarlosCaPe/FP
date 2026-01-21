CREATE VIEW [mor].[CONOPS_MOR_EFH_SNAPSHOT_SEQ_V] AS


--SELECT * FROM [mor].[CONOPS_MOR_EFH_SNAPSHOT_SEQ_V] where shiftflag = 'curr' 

CREATE VIEW [mor].[CONOPS_MOR_EFH_SNAPSHOT_SEQ_V]
AS

SELECT 
EFHSnapSeq.shiftflag,
EFHSnapSeq.siteflag,
CAST(EFHSnapSeq.shiftid AS DECIMAL(19,0)) AS shiftid,
EFHSnapSeq.ShiftStartDateTime,
EFHSnapSeq.ShiftEndDateTime,
EFHSnapSeq.currenttime,
--EFHSnapSeq.excav,
--EFHSnapSeq.truck,
EFHSnapSeq.EFH,
EFHSnapSeq.EFHShiftTarget,
EFHSnapSeq.EFHTarget,
EFHSnapSeq.EFHSeq
FROM (

SELECT 
EFHSnap.shiftflag,
EFHSnap.shiftid,
EFHSnap.siteflag,
ShiftSnap.ShiftStartDateTime,
ShiftSnap.ShiftEndDateTime,
EFHSnap.currenttime,
--EFHSnap.excav,
--EFHSnap.truck,
EFHSnap.EFH,
EFHSnap.EFHShiftTarget,
EFHSnap.EFHTarget,
CASE WHEN datediff(
        minute, ShiftSnap.ShiftStartDateTime,
        EFHSnap.currenttime
      ) between timeseq.starts
      and timeseq.ends THEN timeseq.seq ELSE '99' END AS EFHSeq
FROM (

select 
a.shiftflag,
a.shiftid,
a.siteflag,
shiftinfo.ShiftStartDateTime,
shiftinfo.ShiftEndDateTime,
shiftinfo.currenttime,
--b.excav,
--b.truck,
avg(b.distloaded + (b.fliftup * 27.1428) + (b.fliftdown * 16)) as EFH,
c.EFHtarget as EFHShiftTarget,
(avg(b.distloaded + (b.fliftup * 27.1428) + (b.fliftdown * 16))) / shiftinfo.ShiftCompleteHour as EFHTarget
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select site_code,concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
--excav,
--truck,
distloaded,
fliftup,
fliftdown
from [dbo].[delta_c] (nolock)
where site_code = 'MOR'
) b
on a.shiftid = b.shiftid AND a.siteflag = 'MOR'

LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,
CASE WHEN LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) IS NULL THEN
CASE WHEN RIGHT(shiftid,1) = 2 THEN concat(dateadd(day,1,cast(LEFT(ShiftStartDateTime,10)as date)),' 07:15:00.000')
ELSE concat(dateadd(day,0,cast(LEFT(ShiftStartDateTime,10)as date)),' 19:15:00.000') END
ELSE LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) END AS ShiftEndDateTime,
dateadd(hour,-7,GETUTCDATE()) as currenttime,
datediff(hour,ShiftStartDateTime,dateadd(hour,-7,GETUTCDATE())) as ShiftCompleteHour
from [mor].[shift_info] (nolock)) shiftinfo
on a.shiftid = shiftinfo.shiftid AND a.siteflag = 'MOR'

LEFT JOIN (
SELECT substring(replace(DateEffective,'-',''),3,4) as shiftdate,
EquivalentFlatHaul as EFHtarget
FROM [mor].[plan_values_prod_sum] (nolock)) c
on left(a.shiftid,4) = c.shiftdate AND a.siteflag = 'MOR'

--WHERE a.shiftflag = 'PREV'

group by a.shiftflag,a.shiftid,a.siteflag,c.EFHtarget,shiftinfo.ShiftCompleteHour,
shiftinfo.ShiftStartDateTime,shiftinfo.ShiftEndDateTime,shiftinfo.currenttime ) EFHSnap

CROSS JOIN [DBO].[EFH_TIME_SEQ] (NOLOCK) timeseq
LEFT JOIN [dbo].[SHIFT_INFO_V] ShiftSnap
ON EFHSnap.shiftid = ShiftSnap.shiftid AND EFHSnap.siteflag = ShiftSnap.siteflag
) EFHSnapSeq

WHERE EFHSnapSeq.EFHSeq <> '99'

