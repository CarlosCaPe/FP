CREATE VIEW [cer].[CONOPS_CER_DB_FEETDRILL_SNAPSHOT_V] AS




--SELECT * FROM [cer].[CONOPS_CER_DB_FEETDRILL_SNAPSHOT_V]

CREATE VIEW [cer].[CONOPS_CER_DB_FEETDRILL_SNAPSHOT_V]
AS


WITH CTE AS (
SELECT
shiftindex,
SITE_CODE,
END_HOLE_TS AS DrillTime,
sum(start_point_z - ZACTUALEND) AS FeetDrilled
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)
WHERE SITE_CODE = 'CER'
GROUP BY shiftindex,SITE_CODE,END_HOLE_TS),

FeetDrill AS (
SELECT 
SITE_CODE,
ShiftIndex,
DrillTime,
SUM(FeetDrilled) AS FeetDrilled
FROM CTE 

GROUP BY SITE_CODE,ShiftIndex,DrillTime),

FeetDrillTime AS (
SELECT
a.siteflag,
a.shiftflag,
dt.DrillTime,
dt.FeetDrilled,
CASE WHEN DATEDIFF (second,a.ShiftStartDateTime,dt.DrillTime) 
BETWEEN timeseq.starts and timeseq.ends THEN timeseq.seq ELSE '999999' END AS timeseq
FROM dbo.SHIFT_INFO_V a
CROSS JOIN [DBO].[TIME_SEQ] timeseq WITH (NOLOCK)  
LEFT JOIN FeetDrill dt ON a.ShiftIndex = dt.SHIFTINDEX AND a.siteflag = dt.SITE_CODE 
WHERE a.siteflag = 'CER'
),

FeetDrillTimeSeq AS (
SELECT 
siteflag,
shiftflag,
sum(FeetDrilled) AS FeetDrilled,
timeseq
FROM FeetDrillTime
GROUP BY siteflag,shiftflag,timeseq


UNION ALL

SELECT
siteflag,
shiftflag,
0 AS FeetDrilled,
seq as timeseq
FROM [dbo].[SHIFT_INFO_V] shiftinfo 
CROSS JOIN [DBO].[TIME_SEQ] ts WITH (NOLOCK) 
WHERE shiftinfo.siteflag = 'CER'),

Final AS (
SELECT
siteflag,
shiftflag,
timeseq,
SUM(FeetDrilled) AS FeetDrilled
FROM FeetDrillTimeSeq
WHERE timeseq <> '999999'
GROUP BY 
siteflag,
shiftflag,
timeseq,
FeetDrilled)


SELECT
fn.siteflag,
fn.shiftflag,
timeseq,
dateadd(minute,timeseq,ShiftStartDateTime) AS DrillTime,
SUM(FeetDrilled) OVER (PARTITION BY fn.shiftflag ORDER BY timeseq) AS FeetDrilled,
2372 FeetShiftTarget,
CASE WHEN si.ShiftDuration = 0 THEN 0 
WHEN si.ShiftDuration = '43200' THEN 2372 ELSE 
CAST(2372/(si.ShiftDuration/3600.0) AS INT) END AS FeetTarget
FROM Final fn
LEFT JOIN dbo.SHIFT_INFO_V si ON fn.siteflag = si.siteflag AND fn.shiftflag = si.shiftflag
GROUP BY 
fn.siteflag,
fn.shiftflag,
timeseq,
FeetDrilled,
ShiftStartDateTime,
si.ShiftDuration



