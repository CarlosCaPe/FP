CREATE VIEW [mor].[CONOPS_MOR_SHIFT_LINE_GRAPH_V] AS



--SELECT * FROM [mor].[CONOPS_MOR_SHIFT_LINE_GRAPH_V] where shiftflag = 'curr' order by shiftseq asc

CREATE VIEW [mor].[CONOPS_MOR_SHIFT_LINE_GRAPH_V]
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
b.ShiftEndDateTime,
dateadd(minute,a.shiftseq,b.ShiftStartDateTime) as [DateTime]
FROM [dbo].[SHIFT_SNAPSHOT_SEQ] (nolock) a

LEFT JOIN (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] (NOLOCK)
WHERE siteflag = 'MOR') b
ON a.shiftid = b.shiftid AND a.siteflag = b.siteflag

LEFT JOIN (
SELECT shiftid, shifttarget,targetvalue as [target]
FROM [mor].[CONOPS_MOR_SHIFT_TARGET_V] (NOLOCK)) c 
ON a.shiftid = c.shiftid


WHERE 
a.siteflag = 'MOR'
--AND a.shiftflag = 'CURR'
AND a.shiftseq <= datediff(minute,b.ShiftStartDateTime,dateadd(hour,-7,getutcdate()))
--ORDER BY a.shiftseq asc


