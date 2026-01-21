CREATE VIEW [saf].[CONOPS_SAF_SHIFT_LINE_GRAPH_V] AS




--SELECT * FROM [saf].[CONOPS_SAF_SHIFT_LINE_GRAPH_V] where shiftflag = 'curr' order by shiftseq asc

CREATE VIEW [saf].[CONOPS_SAF_SHIFT_LINE_GRAPH_V]
AS

SELECT DISTINCT b.shiftflag,
                a.siteflag,
                a.shiftid,
                a.shiftseq,
                a.runningtotal AS actual,
                c.[target],
                c.shifttarget,
                b.ShiftStartDateTime,
                b.ShiftEndDateTime,
				dateadd(minute,a.shiftseq,b.ShiftStartDateTime) as [DateTime]
FROM [dbo].[SHIFT_SNAPSHOT_SEQ] (nolock) a
LEFT JOIN (
   SELECT shiftflag,
          siteflag,
          shiftid,
          ShiftStartDateTime,
          ShiftEndDateTime
   FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] (NOLOCK)
   WHERE siteflag = 'SAF'
) b ON a.shiftid = b.shiftid AND a.siteflag = b.siteflag
LEFT JOIN (
   SELECT shiftid,
          shifttarget,
          targetvalue AS [target]
   FROM [saf].[CONOPS_SAF_SHIFT_TARGET_V] (NOLOCK)
) c ON a.shiftid = c.shiftid
WHERE a.siteflag = 'SAF'
AND a.shiftseq <= datediff(MINUTE, b.ShiftStartDateTime, dateadd(HOUR, -7, getutcdate()))


