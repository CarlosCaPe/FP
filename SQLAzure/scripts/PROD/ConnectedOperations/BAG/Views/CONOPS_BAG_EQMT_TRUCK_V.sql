CREATE VIEW [BAG].[CONOPS_BAG_EQMT_TRUCK_V] AS






-- SELECT * FROM [bag].[CONOPS_BAG_EQMT_TRUCK_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [BAG].[CONOPS_BAG_EQMT_TRUCK_V]
AS

WITH Truck AS (
SELECT
shiftflag,
siteflag,
shiftindex,
a.shiftid,
a.truckid,
[location],
statusname,
reasonid,
reasondesc,
TimeInState,
CrewName AS Crew,
UPPER(operator) AS operator,
operatorimageURL,
AssignedShovel,
SUM(TotalMaterialMined) TonsMined,
SUM(TOtalMaterialMoved) TonsMoved,
ROUND(SUM(shoveltarget),0) AS TonsTarget,
SUM(NrOfDumps) AS NumberOfDumps
FROM [bag].[CONOPS_BAG_TRUCK_DETAIL_V] a
LEFT JOIN [bag].[CONOPS_BAG_TRUCK_SHIFT_OVERVIEW_V] b
ON a.shiftid = b.shiftid AND a.truckid = b.truckid
LEFT JOIN (
SELECT
shiftid,
shovelid,
sum(shoveltarget) as shoveltarget
FROM [bag].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V]
WHERE shovelid IS NOT NULL
GROUP BY shiftid,shovelid) c
ON a.shiftid = c.shiftid AND a.AssignedShovel = c.shovelid
GROUP BY
shiftflag,
siteflag,
shiftindex,
a.shiftid,
a.truckid,
[location],
statusname,
reasonid,
reasondesc,
TimeInState,
CrewName,
operator,
operatorimageURL,
AssignedShovel),


Details AS (
SELECT
shiftflag,
siteflag,
truckid,
payload,
PayloadTarget,
DeltaC,
DeltaCTarget,
IdleTime,
IdleTimeTarget,
Spotting,
SpottingTarget,
Loading,
LoadingTarget,
LoadedTravel,
LoadedTravelTarget,
DumpsAtStockpile,
DumpsAtStockpileTarget,
DumpsAtCrusher,
DumpsAtCrusherTarget,
EmptyTravel,
EmptyTravelTarget,
Efh,
EfhTarget,
TotalMaterialDelivered,
TotalMaterialDeliveredTarget,
AvgUseOfAvailibility,
AvgUseOfAvailibilityTarget,
[Availability],
AvailabilityTarget
FROM [bag].[CONOPS_BAG_TRUCK_POPUP] WITH (NOLOCK)),

/*NrofDump AS (
SELECT
[sd].ShiftId,
[t].FieldId [TruckId],
COUNT([sd].FieldTons) NumberofDumps
FROM [bag].[shift_dump] [sd] WITH(NOLOCK)
LEFT JOIN [bag].[shift_eqmt] [t] WITH(NOLOCK)
ON [sd].FieldTruck = [t].Id
GROUP BY [sd].ShiftId, [t].FieldId),*/

--NrofDump AS (
--SELECT
-- SITE_CODE AS SITEFLAG,
-- SHIFT_ID AS SHIFTID,
-- TRUCK_NAME AS TruckId,
-- COUNT(*) AS NumberOfDumps
--FROM BAG.FLEET_TRUCK_CYCLE_V
--GROUP BY SITE_CODE, SHIFT_ID, TRUCK_NAME),

TonsHaul AS (
SELECT 
shiftid,
truck,
TonsHaul
FROM [bag].[CONOPS_BAG_TRUCK_TPRH])




SELECT
a.shiftflag,
a.siteflag,
a.truckid,
[location],
statusname,
reasonid,
reasondesc,
Crew,
TimeInState,
'Recent operator feedback was submitted, please check employee HR records for details' AS Comment,
operator,
operatorimageURL,
AssignedShovel,
(TotalMaterialDelivered * 1000) AS TotalMaterialDelivered,
TotalMaterialDeliveredTarget, 
TonsMined,
0 AS TonsMinedTarget,
TonsMoved,
0 AS TonsMovedTarget,
NumberofDumps,
0 NumberofDumpsTarget,
payload,
PayloadTarget,
TonsHaul,
0 TonsHaulTarget,
DeltaC,
DeltaCTarget,
IdleTime,
IdleTimeTarget,
Spotting,
SpottingTarget,
Loading,
LoadingTarget,
LoadedTravel,
LoadedTravelTarget,
DumpsAtStockpile,
DumpsAtStockpileTarget,
DumpsAtCrusher,
DumpsAtCrusherTarget,
EmptyTravel,
EmptyTravelTarget,
b.Efh,
EfhTarget,
ISNULL(AvgUseOfAvailibility,0) UseOfAvailability,
ISNULL(AvgUseOfAvailibilityTarget,0) useOfAvailabilityTarget,
ISNULL([Availability],0) [Availability],
ISNULL(AvailabilityTarget,0) AvailabilityTarget,
dc.CycleEfficiency,
dc.AvgCycleTime,
dc.MOE_TotalCycle AS MinsOverExpected
FROM Truck a
LEFT JOIN Details b
ON a.shiftflag = b.shiftflag 
AND a.siteflag = b.siteflag 
AND a.truckid = b.truckid
--LEFT JOIN NrofDump c
--ON a.shiftid = c.shiftid
--AND a.TruckID = c.TruckId
LEFT JOIN TonsHaul d
ON a.shiftid = d.ShiftId 
AND a.TruckID = d.Truck 
LEFT JOIN BAG.CONOPS_BAG_EQMT_DELTA_C_V dc
ON a.TruckID = dc.EQMT
AND a.shiftindex = dc.shiftindex
AND dc.eqmttype = 1







