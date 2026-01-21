CREATE VIEW [CLI].[CONOPS_CLI_SHIFT_LINE_GRAPH_V] AS


--SELECT * FROM [cli].[CONOPS_CLI_SHIFT_LINE_GRAPH_V] where shiftflag = 'curr' order by shiftseq asc

CREATE VIEW [cli].[CONOPS_CLI_SHIFT_LINE_GRAPH_V]
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
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] (NOLOCK)
WHERE siteflag = 'CMX') b
ON a.shiftid = b.shiftid AND a.siteflag = b.siteflag

LEFT JOIN (
SELECT shiftid, shifttarget,targetvalue as [target]
FROM [cli].[CONOPS_CLI_SHIFT_TARGET_V] (NOLOCK)) c 
ON a.shiftid = c.shiftid


WHERE 
a.siteflag = 'CMX'
AND a.shiftseq <= datediff(minute,b.ShiftStartDateTime,dateadd(hour,-7,getutcdate()))



