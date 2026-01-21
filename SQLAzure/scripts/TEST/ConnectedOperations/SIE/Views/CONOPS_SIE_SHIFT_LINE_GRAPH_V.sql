CREATE VIEW [SIE].[CONOPS_SIE_SHIFT_LINE_GRAPH_V] AS


--SELECT * FROM [sie].[CONOPS_SIE_SHIFT_LINE_GRAPH_V] where shiftflag = 'curr' order by shiftseq asc

CREATE VIEW [sie].[CONOPS_SIE_SHIFT_LINE_GRAPH_V]
AS

SELECT DISTINCT
b.shiftflag,
a.siteflag,
a.shiftid,
a.shiftseq,
a.runningtotal as actual,
0 [target],
0 shifttarget,
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
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] (NOLOCK)
WHERE siteflag = 'SIE') b
ON a.shiftid = b.shiftid AND a.siteflag = b.siteflag

/*LEFT JOIN (
SELECT shiftid, shifttarget,targetvalue as [target]
FROM [sie].[CONOPS_SIE_SHIFT_TARGET_V] (NOLOCK)) c --Need to change to SIE
ON a.shiftid = c.shiftid*/


WHERE 
a.siteflag = 'SIE'
AND a.shiftseq <= datediff(minute,b.ShiftStartDateTime,dateadd(hour,-7,getutcdate()))



