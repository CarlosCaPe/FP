CREATE VIEW [dbo].[ZZZ_CONOPS_DB_DRILL_TO_WATCH_V] AS






--select * from [dbo].[CONOPS_DB_DRILL_TO_WATCH_V] where shiftflag = 'prev'
CREATE VIEW [dbo].[CONOPS_DB_DRILL_TO_WATCH_V]
AS

SELECT
siteflag,
shiftflag,
Eqmt AS Equipment,
OperatorImageURL,
OperatorName,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
DrillDepth,
[Availability],
utilization,
AveragePenRate,
UnderDrilled,
OverDrilled,
GPSQuality,
TimeBetweenHoles,
AvgFirstLastDrill,
AvgDrillTime,
eqmtcurrstatus,
reasonidx,
reasons
FROM [bag].[CONOPS_BAG_DB_DRILL_PLAN_V]
WHERE siteflag = 'BAG'
AND FeetTarget - FeetDrilled > 0
AND Eqmt IS NOT NULL

UNION ALL


SELECT
siteflag,
shiftflag,
Eqmt AS Equipment,
OperatorImageURL,
OperatorName,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
DrillDepth,
[Availability],
utilization,
AveragePenRate,
UnderDrilled,
OverDrilled,
GPSQuality,
TimeBetweenHoles,
AvgFirstLastDrill,
AvgDrillTime,
eqmtcurrstatus,
reasonidx,
reasons
FROM [mor].[CONOPS_MOR_DB_DRILL_PLAN_V]
WHERE siteflag = 'MOR'
AND FeetTarget - FeetDrilled > 0
AND Eqmt IS NOT NULL


UNION ALL


SELECT
siteflag,
shiftflag,
Eqmt AS Equipment,
OperatorImageURL,
OperatorName,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
DrillDepth,
[Availability],
utilization,
AveragePenRate,
UnderDrilled,
OverDrilled,
GPSQuality,
TimeBetweenHoles,
AvgFirstLastDrill,
AvgDrillTime,
eqmtcurrstatus,
reasonidx,
reasons
FROM [chi].[CONOPS_CHI_DB_DRILL_PLAN_V]
WHERE siteflag = 'CHI'
AND FeetTarget - FeetDrilled > 0
AND Eqmt IS NOT NULL


UNION ALL


SELECT
siteflag,
shiftflag,
Eqmt AS Equipment,
OperatorImageURL,
OperatorName,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
DrillDepth,
[Availability],
utilization,
AveragePenRate,
UnderDrilled,
OverDrilled,
GPSQuality,
TimeBetweenHoles,
AvgFirstLastDrill,
AvgDrillTime,
eqmtcurrstatus,
reasonidx,
reasons
FROM [cli].[CONOPS_CLI_DB_DRILL_PLAN_V]
WHERE siteflag = 'CMX'
AND FeetTarget - FeetDrilled > 0
AND Eqmt IS NOT NULL


UNION ALL


SELECT
siteflag,
shiftflag,
Eqmt AS Equipment,
OperatorImageURL,
OperatorName,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
DrillDepth,
[Availability],
utilization,
AveragePenRate,
UnderDrilled,
OverDrilled,
GPSQuality,
TimeBetweenHoles,
AvgFirstLastDrill,
AvgDrillTime,
eqmtcurrstatus,
reasonidx,
reasons
FROM [sie].[CONOPS_SIE_DB_DRILL_PLAN_V]
WHERE siteflag = 'SIE'
AND FeetTarget - FeetDrilled > 0
AND Eqmt IS NOT NULL


UNION ALL


SELECT
siteflag,
shiftflag,
Eqmt AS Equipment,
OperatorImageURL,
OperatorName,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
DrillDepth,
[Availability],
utilization,
AveragePenRate,
UnderDrilled,
OverDrilled,
GPSQuality,
TimeBetweenHoles,
AvgFirstLastDrill,
AvgDrillTime,
eqmtcurrstatus,
reasonidx,
reasons
FROM [saf].[CONOPS_SAF_DB_DRILL_PLAN_V]
WHERE siteflag = 'SAF'
AND FeetTarget - FeetDrilled > 0
AND Eqmt IS NOT NULL


UNION ALL


SELECT
siteflag,
shiftflag,
Eqmt AS Equipment,
OperatorImageURL,
OperatorName,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
DrillDepth,
[Availability],
utilization,
AveragePenRate,
UnderDrilled,
OverDrilled,
GPSQuality,
TimeBetweenHoles,
AvgFirstLastDrill,
AvgDrillTime,
eqmtcurrstatus,
reasonidx,
reasons
FROM [cer].[CONOPS_CER_DB_DRILL_PLAN_V]
WHERE siteflag = 'CER'
AND FeetTarget - FeetDrilled > 0
AND Eqmt IS NOT NULL


