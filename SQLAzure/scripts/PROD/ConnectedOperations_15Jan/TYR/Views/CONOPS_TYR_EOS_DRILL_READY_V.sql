CREATE VIEW [TYR].[CONOPS_TYR_EOS_DRILL_READY_V] AS



--SELECT * FROM [tyr].[CONOPS_TYR_EOS_DRILL_READY_V] WHERE shiftflag = 'curr' order by datetime
CREATE VIEW [TYR].[CONOPS_TYR_EOS_DRILL_READY_V]
AS

WITH CTE AS (
SELECT
shiftindex,
drill_id as eqmt,
StartDateTime
FROM [tyr].drill_asset_efficiency_v
WHERE reasonidx = 200),

TimeDiff AS (
SELECT
siteflag,
shiftflag,
ShiftStartDateTime,
SHIFTENDDATETIME,
eqmt,
datediff(minute, a.ShiftStartDateTime,StartDateTime) TimeDiff
FROM [tyr].CONOPS_TYR_SHIFT_INFO_V a
LEFT JOIN CTE b
ON a.shiftindex = b.shiftindex),

TimeSeq AS (
SELECT
siteflag,
shiftflag,
ShiftStartDateTime,
SHIFTENDDATETIME,
eqmt,
CASE WHEN TimeDiff between b.starts and b.ends THEN b.seq 
ELSE '999999' END AS shiftseq
FROM TimeDiff a
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b WITH (NOLOCK)),

Final AS (
SELECT
siteflag,
shiftflag,
ShiftStartDateTime,
SHIFTENDDATETIME,
COUNT(eqmt) Equipment,
shiftseq 
FROM TimeSeq
WHERE shiftseq <> '999999'
GROUP BY 
siteflag,
shiftflag,
ShiftStartDateTime,
SHIFTENDDATETIME,
shiftseq)

SELECT
siteflag,
shiftflag,
ShiftStartDateTime,
ShiftEndDateTime,
Equipment,
dateadd(hour,shiftseq,ShiftStartDateTime) as [DateTime]
FROM Final



