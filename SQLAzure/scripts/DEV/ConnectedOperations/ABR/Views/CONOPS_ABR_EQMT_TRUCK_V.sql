CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TRUCK_V] AS


-- SELECT * FROM [abr].[CONOPS_ABR_EQMT_TRUCK_V] WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TRUCK_V]  
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
operatorid,
operatorimageURL,
AssignedShovel,
SUM(TotalMaterialMined) AS TonsMined,
SUM(TotalMaterialMoved) AS TonsMoved,
ROUND(SUM(shoveltarget),0) AS TonsTarget,
SUM(NRofDUmps) AS NumberOfDumps
FROM [abr].[CONOPS_ABR_TRUCK_DETAIL_V] a
LEFT JOIN [abr].[CONOPS_ABR_TRUCK_SHIFT_OVERVIEW_V] b
ON a.shiftid = b.shiftid AND a.truckid = b.truckid
LEFT JOIN (
SELECT
shiftid,
shovelid,
sum(shoveltarget) as shoveltarget
FROM [abr].[CONOPS_ABR_SHOVEL_SHIFT_TARGET_V]
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
operatorid,
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
FROM [abr].[CONOPS_ABR_TRUCK_POPUP_V]),

/*NrofDump AS (
SELECT
[sd].ShiftId,
[t].FieldId [TruckId],
COUNT([sd].FieldLsizeTons) NumberofDumps
FROM [abr].[shift_dump_v] [sd] WITH(NOLOCK)
LEFT JOIN [abr].[shift_eqmt] [t] WITH(NOLOCK)
ON [sd].FieldTruck = [t].id
GROUP BY [sd].ShiftId, [t].FieldId),*/

--NrofDump AS (
--SELECT
--shiftindex,
--truck AS TruckId,
--count(truck) AS NumberofDumps
--FROM dbo.lh_load WITH (NOLOCK)
--where site_code = 'ELA' 
--GROUP BY shiftindex,truck),

TonsHaul AS (
SELECT 
shiftid,
truck,
TonsHaul
FROM [abr].[CONOPS_ABR_TRUCK_TPRH])


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
operatorid,
operatorimageURL,
AssignedShovel,
(TotalMaterialDelivered * 1000) AS TotalMaterialDelivered,
TotalMaterialDeliveredTarget,
TonsMined,
NULL AS TonsMinedTarget,
TonsMoved,
NULL As TonsMovedTarget,
NumberofDumps,
NULL NumberofDumpsTarget,
payload,
PayloadTarget,
TonsHaul,
NULL TonsHaulTarget,
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
ISNULL(AvgUseOfAvailibilityTarget,0) useOfAvailabilityTarget ,
ISNULL([Availability],0) AS [Availability],
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
--ON a.shiftindex = c.shiftindex
--AND a.TruckID = c.TruckId
LEFT JOIN TonsHaul d
ON a.shiftid = d.ShiftId
AND a.TruckID = d.Truck
LEFT JOIN ABR.CONOPS_ABR_EQMT_DELTA_C_V dc
ON a.TruckID = dc.EQMT
AND a.shiftindex = dc.shiftindex
AND dc.eqmttype = 1
  
  
  
  
  





