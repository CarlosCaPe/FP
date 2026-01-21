


--SELECT * FROM [mor].[CONOPS_MOR_EFH_SNAPSHOT_SEQ_V] where shiftflag = 'curr' 

CREATE PROCEDURE [mor].[CONOPS_MOR_EFH_SNAPSHOT_SEQ_V_NEW]
AS

BEGIN 

WITH EFHSnap AS (
select a.shiftflag,a.shiftid,a.siteflag,shiftinfo.ShiftStartDateTime,shiftinfo.ShiftEndDateTime,shiftinfo.currenttime,
avg(b.distloaded + (b.fliftup * 27.1428) + (b.fliftdown * 16)) as EFH,
c.EFHtarget as EFHShiftTarget,
(avg(b.distloaded + (b.fliftup * 27.1428) + (b.fliftdown * 16))) / shiftinfo.ShiftCompleteHour as EFHTarget
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select site_code,concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
distloaded,
fliftup,fliftdown
from [dbo].[delta_c] (nolock)
where site_code = 'MOR'
) b
on a.shiftid = b.shiftid

LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,
CASE WHEN LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) IS NULL THEN
CASE WHEN RIGHT(shiftid,1) = 2 THEN concat(dateadd(day,1,cast(LEFT(ShiftStartDateTime,10)as date)),' 07:15:00.000')
ELSE concat(dateadd(day,0,cast(LEFT(ShiftStartDateTime,10)as date)),' 19:15:00.000') END
ELSE LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) END AS ShiftEndDateTime,
dateadd(hour,-7,GETUTCDATE()) as currenttime,
datediff(hour,ShiftStartDateTime,dateadd(hour,-7,GETUTCDATE())) as ShiftCompleteHour
from [mor].[shift_info] (nolock)) shiftinfo
on a.shiftid = shiftinfo.shiftid

LEFT JOIN (
SELECT substring(replace(DateEffective,'-',''),3,4) as shiftdate,
EquivalentFlatHaul as EFHtarget
FROM [mor].[plan_values_prod_sum] (nolock)) c
on left(a.shiftid,4) = c.shiftdate

WHERE a.shiftflag = 'PREV'

group by a.shiftflag,a.shiftid,a.siteflag,c.EFHtarget,shiftinfo.ShiftCompleteHour,
shiftinfo.ShiftStartDateTime,shiftinfo.ShiftEndDateTime,shiftinfo.currenttime
),

EFHSnapSeq AS (
SELECT 
a.shiftflag,
a.shiftid,
a.siteflag,
b.ShiftStartDateTime,
b.ShiftEndDateTime,
a.currenttime,
a.EFH,
a.EFHShiftTarget,
a.EFHTarget,
CASE WHEN datediff(
        minute, b.ShiftStartDateTime,
        a.currenttime
      ) between timeseq.starts
      and timeseq.ends THEN timeseq.seq ELSE '99' END AS EFHSeq
FROM EFHSnap a CROSS
JOIN [DBO].[EFH_TIME_SEQ] (NOLOCK) timeseq
LEFT JOIN [dbo].[SHIFT_INFO_V] b
ON a.shiftid = b.shiftid)


SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime,
currenttime,
EFH,
EFHShiftTarget,
EFHTarget,
EFHSeq
FROM EFHSnapSeq 
WHERE EFHSeq <> '99'

END

