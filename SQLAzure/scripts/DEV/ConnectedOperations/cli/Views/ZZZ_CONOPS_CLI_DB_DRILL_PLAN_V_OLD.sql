CREATE VIEW [cli].[ZZZ_CONOPS_CLI_DB_DRILL_PLAN_V_OLD] AS






--select * from [cli].[CONOPS_CLI_DB_DRILL_PLAN_V] where shiftflag = 'prev'
CREATE VIEW [cli].[CONOPS_CLI_DB_DRILL_PLAN_V]
AS


WITH HOLES AS (
SELECT  
fdr.SHIFTINDEX,
'CMX' AS SITE_CODE,
LEFT(DRILL_ID, 2) + RIGHT('00' + RIGHT(DRILL_ID, 1), 2) AS Eqmt,
CASE WHEN operatorId IS NULL THEN NULL ELSE
CONCAT('https://images.services.fmi.com/publishedimages/',RIGHT('0000000000' + OperatorId, 10),'.jpg') END AS OperatorImageURL,
UPPER(OperatorName) AS OperatorName,
COUNT(DRILL_HOLE) AS holes,
CASE WHEN start_point_z IS NULL THEN 0 ELSE 
sum(start_point_z - ZACTUALEND) END AS FeetDrilled,
DEPTH AS DrillDepth,
avg(datediff(minute,START_HOLE_TS,END_HOLE_TS)) As AvgDrillTime
FROM [dbo].[FR_DRILLING_SCORES] fdr WITH (NOLOCK) 
WHERE fdr.SITE_CODE = 'CLI'
GROUP BY fdr.SHIFTINDEX, fdr.SITE_CODE, fdr.DRILL_ID,fdr.DEPTH,fdr.operatorId,OperatorName,start_point_z),

KPI AS (
SELECT
siteflag,
shiftflag,
DRILL_ID AS Eqmt,
Over_Drill AS OverDrilled,
Under_Drill AS UnderDrilled,
Average_Pen_Rate AS AveragePenRate,
Avg_Time_Between_Holes AS TimeBetweenHoles,
Average_GPS_Quality AS GPSQuality,
Average_First_Last_Drill AS AvgFirstLastDrill
FROM [dbo].[CONOPS_DB_DRILL_SCORES_V]
WHERE siteflag = 'CMX'),

AE AS (
SELECT 
shiftflag,
siteflag,
eqmt,
availability_pct,
use_of_availability_pct as utilization
FROM [cli].[CONOPS_CLI_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] ),

TGT AS (
SELECT TOP 1
FeetDrilled AS FeetShiftTarget,
HolesDrilled AS HoleShiftTarget
FROM cli.PLAN_VALUES WITH (NOLOCK)
ORDER BY ShiftId DESC),


EqmtStatus AS (
SELECT 
shiftindex,
drill_id AS eqmt,
startdatetime,
enddatetime,
[status] AS eqmtcurrstatus,
reasonidx,
reason as reasons,
ROW_NUMBER() OVER (PARTITION BY shiftindex,
drill_id
ORDER BY startdatetime DESC) num
FROM [cli].[drill_asset_efficiency_v] WITH (NOLOCK))

SELECT
a.siteflag,
a.shiftflag,
b.Eqmt,
b.OperatorImageURL,
b.OperatorName,
AVG(b.AvgDrillTime) AS AvgDrillTime,
SUM(b.Holes) AS HolesDrilled,
SUM(b.FeetDrilled) AS FeetDrilled,
tg.HoleShiftTarget,
CASE WHEN a.ShiftDuration = 0 THEN 0 
WHEN a.ShiftDuration = '43200' THEN tg.HoleShiftTarget 
ELSE CAST(tg.HoleShiftTarget/(a.ShiftDuration/3600.0) AS INT) END AS HoleTarget,
tg.FeetShiftTarget,
CASE WHEN a.ShiftDuration = 0 THEN 0 
WHEN a.ShiftDuration = '43200' THEN tg.FeetShiftTarget
ELSE CAST(tg.FeetShiftTarget/(a.ShiftDuration/3600.0) AS INT) END AS FeetTarget,
SUM(b.DrillDepth) AS DrillDepth,
c.availability_pct AS [Availability],
c.utilization,
e.AveragePenRate,
e.UnderDrilled,
e.OverDrilled,
e.AvgFirstLastDrill,
e.GPSQuality,
e.TimeBetweenHoles,
d.eqmtcurrstatus,
d.reasonidx,
d.reasons
FROM DBO.SHIFT_INFO_V a
LEFT JOIN HOLES b ON a.ShiftIndex = b.SHIFTINDEX AND a.siteflag = b.SITE_CODE
LEFT JOIN AE c ON a.shiftflag = c.shiftflag AND a.siteflag = c.siteflag AND b.Eqmt = c.eqmt
LEFT JOIN EqmtStatus d ON a.ShiftIndex = d.ShiftIndex AND b.Eqmt = d.eqmt AND a.siteflag = 'CMX' and d.num = 1
LEFT JOIN KPI e ON a.shiftflag = e.shiftflag AND a.siteflag = e.siteflag AND b.Eqmt = e.Eqmt
CROSS JOIN TGT tg

WHERE a.siteflag = 'CMX'

GROUP BY 
a.siteflag,
a.shiftflag,
b.Eqmt,
b.OperatorImageURL,
b.OperatorName,
tg.HoleShiftTarget,
tg.FeetShiftTarget,
c.availability_pct,
c.utilization,
e.AveragePenRate,
e.UnderDrilled,
e.OverDrilled,
e.AvgFirstLastDrill,
e.GPSQuality,
e.TimeBetweenHoles,
d.eqmtcurrstatus,
d.reasonidx,
d.reasons,
a.ShiftDuration

