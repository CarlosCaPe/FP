CREATE VIEW [SIE].[CONOPS_SIE_EQMT_TRUCK_V] AS



  
    
    
    
-- SELECT * FROM [sie].[CONOPS_SIE_EQMT_TRUCK_V] WHERE SHIFTFLAG = 'PREV'    
CREATE VIEW [sie].[CONOPS_SIE_EQMT_TRUCK_V]    
AS    
    
WITH Truck AS (
SELECT
a.shiftflag,
siteflag,
a.shiftindex,
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
AssignedShovel ,
SUM(TotalMaterialMoved) AS TonsMined,
SUM(TotalMineralsMined) AS TonsMoved,
ROUND(SUM(shoveltarget),0) AS TonsTarget,
SUM(NrOfDumps) AS NumberOfDumps
FROM [sie].[CONOPS_SIE_TRUCK_DETAIL_V] a
LEFT JOIN [sie].[CONOPS_SIE_TRUCK_SHIFT_OVERVIEW_V] b
ON a.shiftid = b.shiftid AND a.truckid = b.truckid
LEFT JOIN (
SELECT 
shiftflag,
shovelid,
SUM(shoveltarget) AS shoveltarget
from [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V]
GROUP BY shiftflag,shovelid) c
ON a.shiftflag = c.shiftflag AND a.assignedshovel = c.ShovelID
GROUP BY 
a.shiftflag,
siteflag,
a.shiftindex,
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
FROM [sie].[CONOPS_SIE_TRUCK_POPUP] WITH (NOLOCK)),

/*NrofDump AS (
SELECT
[sd].ShiftId,
[t].FieldId [TruckId],
COUNT([sd].FieldTons) NumberofDumps
FROM [sie].[shift_dump] [sd] WITH(NOLOCK)
LEFT JOIN [sie].[shift_eqmt] [t] WITH(NOLOCK)
ON [sd].FieldTruck = [t].Id
GROUP BY [sd].ShiftId, [t].FieldId),*/

NrofDump AS (
SELECT
shiftindex,
truck AS TruckId,
count(truck) AS NumberofDumps
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'SIE' 
GROUP BY shiftindex,truck),

TonsHaul AS (
SELECT 
shiftid,
truck,
TonsHaul
FROM [sie].[CONOPS_SIE_TRUCK_TPRH])


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
NULL AS TonsMinedTarget,
TonsMoved,
NULL AS TonsMovedTarget,
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
--ON a.shiftindex = c.shiftindex
--AND a.TruckID = c.TruckId
LEFT JOIN TonsHaul d
ON a.shiftid = d.ShiftId
AND a.TruckID = d.Truck
LEFT JOIN SIE.CONOPS_SIE_EQMT_DELTA_C_V dc
ON a.TruckID = dc.EQMT
AND a.shiftindex = dc.shiftindex
AND dc.eqmttype = 1
    
    
    
    
  



