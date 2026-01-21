CREATE VIEW [Arch].[CONOPS_ARCH_SHIFT_LINE_GRAPH_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_SHIFT_LINE_GRAPH_V]
AS

SELECT DISTINCT
b.shiftflag,
a.siteflag,
a.shiftid,
a.shiftseq,
a.runningtotal as actual,
c.[target],
c.shifttarget,
b.ShiftStartDateTime,
b.ShiftEndDateTime
FROM [dbo].[SHIFT_SNAPSHOT_SEQ] (nolock) a

LEFT JOIN (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime
FROM [dbo].[SHIFT_INFO_V] (NOLOCK)
WHERE siteflag = '<SITECODE>') b
ON a.shiftid = b.shiftid AND a.siteflag = b.siteflag

LEFT JOIN (
SELECT shiftid, shifttarget,targetvalue as [target]
FROM [Arch].[CONOPS_ARCH_SHIFT_TARGET_V] (NOLOCK)) c 
ON a.shiftid = c.shiftid


WHERE 
a.siteflag = '<SITECODE>'
AND a.shiftseq <= datediff(minute,b.ShiftStartDateTime,dateadd(hour,-7,getutcdate()))



