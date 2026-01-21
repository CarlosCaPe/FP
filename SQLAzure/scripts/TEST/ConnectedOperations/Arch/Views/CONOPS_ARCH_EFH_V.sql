CREATE VIEW [Arch].[CONOPS_ARCH_EFH_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_EFH_V]
AS

SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
b.currenttime as breakbyhour,
b.EFH,
b.EFHTarget,
d.EFHShiftTarget,
c.avgEFH,
b.EFHSeq
FROM dbo.shift_info_v a

LEFT JOIN (
SELECT 
snapseq.shiftid,
snapseq.currenttime,
snapseq.EFH,
snapseq.EFHTarget,
--snapseq.EFHShiftTarget,
snapseq.EFHSeq
FROM [dbo].[EFH_SNAPSHOT_SEQ] snapseq WITH (NOLOCK) 

INNER JOIN (
SELECT shiftid,EFHSeq,max(currenttime) as currenttime
FROM [dbo].[EFH_SNAPSHOT_SEQ]  WITH (NOLOCK) 
GROUP BY shiftid,EFHSeq) snap
ON snapseq.shiftid = snap.shiftid
AND snapseq.currenttime = snap.currenttime

) b
ON a.shiftid = b.shiftid AND a.siteflag = '<SITECODE>'

LEFT JOIN (
SELECT
siteflag,
Shiftid,
avg(EFH) as avgEFH
FROM [dbo].[EFH_SNAPSHOT_SEQ] WITH (NOLOCK) 
where siteflag = '<SITECODE>'
GROUP BY shiftid,siteflag) c
ON a.shiftid = c.shiftid AND a.siteflag = c.siteflag


LEFT JOIN (
SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
EFH as EFHShifttarget
FROM [Arch].[plan_values_prod_sum] (nolock)) d
on left(a.shiftid,4) = d.shiftdate AND a.siteflag = '<SITECODE>'

WHERE a.siteflag = '<SITECODE>'

