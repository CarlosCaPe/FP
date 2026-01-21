CREATE VIEW [dbo].[CONOPS_EFH_SNAPSHOT_SEQ_V] AS



CREATE VIEW [dbo].[CONOPS_EFH_SNAPSHOT_SEQ_V]
AS

SELECT 

EFHSnapSeq.siteflag,
CAST(EFHSnapSeq.shiftid AS DECIMAL(19,0)) AS shiftid,
EFHSnapSeq.ShiftStartDateTime,
EFHSnapSeq.ShiftEndDateTime,
EFHSnapSeq.currenttime,
EFHSnapSeq.EFH,
EFHSnapSeq.EFHTarget,
EFHSnapSeq.EFHSeq
FROM (

SELECT 
EFHSnap.shiftid,
EFHSnap.siteflag,
ShiftSnap.ShiftStartDateTime,
ShiftSnap.ShiftEndDateTime,
EFHSnap.currenttime,
EFHSnap.EFH,
EFHSnap.EFHTarget,
CASE WHEN datediff(
        minute, ShiftSnap.ShiftStartDateTime,
        EFHSnap.currenttime
      ) between timeseq.starts
      and timeseq.ends THEN timeseq.seq ELSE '99' END AS EFHSeq
FROM (

select 
a.shiftid,
a.siteflag,
shiftinfo.ShiftStartDateTime,
shiftinfo.ShiftEndDateTime,
shiftinfo.currenttime,
avg(b.distloaded + (b.fliftup * 27.1428) + (b.fliftdown * 16)) as EFH,
(avg(b.distloaded + (b.fliftup * 27.1428) + (b.fliftdown * 16))) / shiftinfo.ShiftCompleteHour as EFHTarget
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select 
CASE WHEN site_code = 'CLI' THEN 'CMX'
ELSE site_code END AS site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
distloaded,
fliftup,
fliftdown
from [dbo].[delta_c] WITH (nolock)

) b
on a.shiftid = b.shiftid AND a.siteflag = b.site_code

LEFT JOIN (
SELECT 
siteflag,
shiftid, 
ShiftStartDateTime,
CASE WHEN LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) IS NULL THEN
CASE WHEN RIGHT(shiftid,1) = 2 THEN concat(dateadd(day,1,cast(LEFT(ShiftStartDateTime,10)as date)),' 07:15:00.000')
ELSE concat(dateadd(day,0,cast(LEFT(ShiftStartDateTime,10)as date)),' 19:15:00.000') END
ELSE LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) END AS ShiftEndDateTime,
dateadd(hour,-7,GETUTCDATE()) as currenttime,
datediff(hour,ShiftStartDateTime,dateadd(hour,-7,GETUTCDATE())) as ShiftCompleteHour
from [dbo].[SHIFT_INFO_V] (nolock)) shiftinfo
on a.shiftid = shiftinfo.shiftid AND a.siteflag = shiftinfo.siteflag

group by a.shiftid,a.siteflag,shiftinfo.ShiftCompleteHour,
shiftinfo.ShiftStartDateTime,shiftinfo.ShiftEndDateTime,shiftinfo.currenttime
) EFHSnap

CROSS JOIN [DBO].[EFH_TIME_SEQ] (NOLOCK) timeseq
LEFT JOIN [dbo].[SHIFT_INFO_V] ShiftSnap
ON EFHSnap.shiftid = ShiftSnap.shiftid AND EFHSnap.siteflag = ShiftSnap.siteflag
) EFHSnapSeq

WHERE EFHSnapSeq.EFHSeq <> '99'

