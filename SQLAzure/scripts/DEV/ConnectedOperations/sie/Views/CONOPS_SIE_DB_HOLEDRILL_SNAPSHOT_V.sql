CREATE VIEW [sie].[CONOPS_SIE_DB_HOLEDRILL_SNAPSHOT_V] AS




--SELECT * FROM [SIE].[CONOPS_SIE_DB_HOLEDRILL_SNAPSHOT_V] WHERE shiftflag = 'prev'

CREATE VIEW [sie].[CONOPS_SIE_DB_HOLEDRILL_SNAPSHOT_V]
AS


WITH CTE AS (
SELECT
shiftindex,
SITE_CODE,
END_HOLE_TS AS DrillTime,
COUNT(DRILL_HOLE) AS HoleDrilled
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)
WHERE SITE_CODE = 'SIE'
GROUP BY shiftindex,SITE_CODE,END_HOLE_TS),

HoleDrill AS (
SELECT 
SITE_CODE,
ShiftIndex,
DrillTime,
SUM(HoleDrilled) AS HoleDrilled
FROM CTE 

GROUP BY SITE_CODE,ShiftIndex,DrillTime),

HoleDrillTime AS (
SELECT
a.siteflag,
a.shiftflag,
dt.DrillTime,
dt.HoleDrilled,
CASE WHEN DATEDIFF (second,a.ShiftStartDateTime,dt.DrillTime) 
BETWEEN timeseq.starts and timeseq.ends THEN timeseq.seq ELSE '999999' END AS timeseq
FROM dbo.SHIFT_INFO_V a
CROSS JOIN [DBO].[TIME_SEQ] timeseq WITH (NOLOCK)  
LEFT JOIN HoleDrill dt ON a.ShiftIndex = dt.SHIFTINDEX AND a.siteflag = dt.SITE_CODE 
WHERE a.siteflag = 'SIE'),

HoleDrillTimeSeq AS (
SELECT 
siteflag,
shiftflag,
sum(HoleDrilled) AS HoleDrilled,
timeseq
FROM HoleDrillTime
GROUP BY siteflag,shiftflag,timeseq


UNION ALL

SELECT
siteflag,
shiftflag,
0 AS HoleDrilled,
seq as timeseq
FROM [dbo].[SHIFT_INFO_V] shiftinfo 
CROSS JOIN [DBO].[TIME_SEQ] ts WITH (NOLOCK) 
WHERE shiftinfo.siteflag = 'SIE'),

Final AS (
SELECT
siteflag,
shiftflag,
timeseq,
SUM(HoleDrilled) AS HoleDrilled
FROM HoleDrillTimeSeq
WHERE timeseq <> '999999'
GROUP BY 
siteflag,
shiftflag,
timeseq,
HoleDrilled )

SELECT
fn.siteflag,
fn.shiftflag,
timeseq,
dateadd(minute,timeseq,ShiftStartDateTime) AS DrillTime,
SUM(HoleDrilled) OVER (PARTITION BY fn.shiftflag ORDER BY timeseq) AS HoleDrilled,
tg.HoleShiftTarget,
CASE WHEN si.ShiftDuration = 0 THEN 0 
WHEN si.ShiftDuration = '43200' THEN tg.HoleShiftTarget
ELSE CAST(tg.HoleShiftTarget/(si.ShiftDuration/3600.0) AS INT) END AS HoleTarget
FROM Final fn
LEFT JOIN dbo.SHIFT_INFO_V si ON fn.siteflag = si.siteflag AND fn.shiftflag = si.shiftflag
CROSS JOIN (
SELECT TOP 1
HOLESDRILLEDTARGET AS HoleShiftTarget
FROM sie.PLAN_VALUES_PROD_SUM
ORDER BY DATEEFFECTIVE DESC) tg
GROUP BY 
fn.siteflag,
fn.shiftflag,
timeseq,
HoleDrilled,
ShiftStartDateTime,
tg.HoleShiftTarget,
si.ShiftDuration



