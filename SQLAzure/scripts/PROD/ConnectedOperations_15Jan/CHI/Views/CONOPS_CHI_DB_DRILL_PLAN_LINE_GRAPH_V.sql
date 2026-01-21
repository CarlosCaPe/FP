CREATE VIEW [CHI].[CONOPS_CHI_DB_DRILL_PLAN_LINE_GRAPH_V] AS









--SELECT * FROM [CHI].[CONOPS_CHI_DB_DRILL_PLAN_LINE_GRAPH_V] WHERE shiftflag = 'PREV'
CREATE VIEW [CHI].[CONOPS_CHI_DB_DRILL_PLAN_LINE_GRAPH_V]
AS



WITH CTE AS (
SELECT
a.shiftflag,
a.siteflag,
a.shiftindex,
a.shiftid,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
START_HOLE_TS AS StartHoleTS,
'DRL' + LEFT(DRILL_ID, 2) AS DRILL_ID,
b.[DRILL_HOLE],
b.start_point_z - b.zactualend AS FEET_DRILLED,
datediff(MINUTE, a.ShiftStartDateTime,START_HOLE_TS) TimeDiff
FROM [CHI].[CONOPS_CHI_SHIFT_INFO_V] a 
LEFT JOIN [dbo].[FR_DRILLING_SCORES] b WITH (NOLOCK)
ON a.shiftindex = b.shiftindex AND a.siteflag = b.SITE_CODE),

TimeSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShiftStartDateTime,
ShiftEndDateTime,
StartHoleTS,
DRILL_ID,
DRILL_HOLE,
FEET_DRILLED,
CASE WHEN TimeDiff between b.starts and b.ends THEN b.seq 
ELSE '999999' END AS shiftseq
FROM CTE a
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b WITH (NOLOCK)),


TonsSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShiftStartDateTime,
ShiftEndDateTime,
StartHoleTS,
DRILL_ID,
COUNT(DRILL_HOLE) AS DRILL_HOLE,
SUM(FEET_DRILLED) AS FEET_DRILLED,
shiftseq
FROM TimeSeq 
WHERE shiftseq <> '999999'
AND shiftseq <= datediff(second,ShiftStartDateTime,dateadd(hour,-7,getutcdate()))
GROUP BY shiftflag,siteflag,shiftid,shiftindex,ShiftStartDateTime,ShiftEndDateTime,StartHoleTS,DRILL_ID,shiftseq),

TonsFinal AS (

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShiftStartDateTime,
ShiftEndDateTime,
DRILL_ID,
SUM(DRILL_HOLE) DRILL_HOLE,
SUM(FEET_DRILLED) AS FEET_DRILLED,
StartHoleTS,
shiftseq
FROM TonsSeq
--WHERE shiftflag = 'prev'
GROUP BY shiftflag,siteflag,shiftid,shiftindex,ShiftStartDateTime,ShiftEndDateTime,StartHoleTS,DRILL_ID,shiftseq

),

Final AS (
SELECT
shiftflag,
siteflag,
shiftid,
shiftindex,
ShiftStartDateTime,
ShiftEndDateTime,
DRILL_ID,
SUM(DRILL_HOLE) DRILL_HOLE,
SUM(FEET_DRILLED) AS FEET_DRILLED,
--StartHoleTS,
shiftseq,
ROW_NUMBER() OVER (PARTITION BY shiftid,StartHoleTS ORDER BY StartHoleTS ASC) num
FROM TonsFinal
WHERE shiftseq IS NOT NULL 
--AND shiftflag = 'prev'
--AND shovelid = 'S12'
GROUP BY 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShiftStartDateTime,
ShiftEndDateTime,
StartHoleTS,
DRILL_ID,
shiftseq
--order by shiftseq
),

EqmtStatus AS (
	SELECT SHIFTINDEX,
	       site_code,
	       Drill_ID AS eqmt,
	       [status] AS eqmtcurrstatus,
		   [MODEL] AS eqmttype,
	       ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID
	                          ORDER BY startdatetime DESC) num
	FROM [CHI].[drill_asset_efficiency_v] WITH (NOLOCK)
)

SELECT 
[f].shiftflag,
[f].siteflag,
[f].shiftid,
[f].ShiftStartDateTime,
[f].ShiftEndDateTime,
[f].DRILL_ID,
DATEADD(hour,[f].shiftseq-1,[f].ShiftStartDateTime) AS DateTime,
SUM([f].DRILL_HOLE) DRILL_HOLE,
SUM([f].FEET_DRILLED) AS FEET_DRILLED,
--StartHoleTS,
[f].shiftseq,
[es].eqmtcurrstatus,
[es].eqmttype
FROM Final [f]
LEFT JOIN EqmtStatus [es]
    ON [es].eqmt = [f].DRILL_ID 
	AND [es].num = 1
	AND [es].SHIFTINDEX = [F].ShiftIndex
WHERE [f].num = 1
GROUP BY 
[f].shiftflag,
[f].siteflag,
[f].shiftid,
[f].ShiftStartDateTime,
[f].ShiftEndDateTime,
[f].DRILL_ID,
[f].shiftseq,
[es].eqmtcurrstatus,
[es].eqmttype






