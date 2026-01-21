CREATE VIEW [cer].[CONOPS_CER_EQMT_TRUCK_V] AS



  
   
-- SELECT * FROM [cer].[CONOPS_CER_EQMT_TRUCK_V] WHERE SHIFTFLAG = 'PREV'    
CREATE VIEW [cer].[CONOPS_CER_EQMT_TRUCK_V]    
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
SUM(TotalMaterialMoved) TonsMoved,
ROUND(SUM(shoveltarget),0) AS TonsTarget,
SUM(NrOfDump) AS NumberofDumps
FROM [cer].[CONOPS_CER_TRUCK_DETAIL_V] a
LEFT JOIN [cer].[CONOPS_CER_TRUCK_SHIFT_OVERVIEW_V] b
ON a.shiftid = b.shiftid AND a.truckid = b.truckid
LEFT JOIN (
SELECT 
shiftid,
shovelid,
sum(shoveltarget) AS shoveltarget
FROM [cer].[CONOPS_CER_SHOVEL_SHIFT_TARGET_V]
GROUP BY shiftid, shovelid) c
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
/*Loading,
LoadingTarget,
LoadedTravel,
LoadedTravelTarget,
EmptyTravel,
EmptyTravelTarget,*/
DumpsAtStockpile,
DumpsAtStockpileTarget,
DumpsAtCrusher,
DumpsAtCrusherTarget,
Efh,
EfhTarget,
TotalMaterialDelivered,
TotalMaterialDeliveredTarget,
AvgUseOfAvailibility,
AvgUseOfAvailibilityTarget,
[Availability],
AvailabilityTarget
FROM [cer].[CONOPS_CER_TRUCK_POPUP] WITH (NOLOCK)),

TruckLoad AS (
SELECT
Shiftindex,
truck,
avg(Loading) Loading,
avg(LoadingTarget) LoadingTarget,
avg(EmptyTravel) EmptyTravel,
avg(EmptyTravelTarget) EmptyTravelTarget,
avg(LoadedTravel) LoadedTravel,
avg(LoadedTravelTarget) LoadedTravelTarget
FROM [cer].[CONOPS_CER_EQMT_TRUCK_LOAD_DELTAC_V]
GROUP BY shiftindex,truck),

/*NrofDump AS (
SELECT
[sd].ShiftId,
[t].FieldId [TruckId],
COUNT([sd].FieldLsizetons) NumberofDumps
FROM [cer].[shift_dump] [sd] WITH(NOLOCK)
LEFT JOIN [cer].[shift_eqmt] [t] WITH(NOLOCK)
ON [sd].FieldTruck = [t].shift_eqmt_id
GROUP BY [sd].ShiftId, [t].FieldId),*/

--NrofDump AS (
--SELECT
--shiftindex,
--truck AS TruckId,
--count(truck) AS NumberofDumps
--FROM dbo.lh_load WITH (NOLOCK)
--where site_code = 'CER' 
--GROUP BY shiftindex,truck),

TonsHaul AS (
SELECT 
shiftid,
truck,
TonsHaul
FROM [cer].[CONOPS_CER_TRUCK_TPRH])
/*
TruckTons AS (
SELECT
dumps.shiftid,
t.FieldId AS [TruckId],
SUM(dumps.FieldLsizetons)AS TotalMaterialDelivered
FROM cer.shift_dump_v dumps WITH (NOLOCK)
LEFT JOIN cer.shift_loc s ON shift_loc_id = dumps.FieldLoc
LEFT JOIN cer.shift_eqmt t ON t.shift_eqmt_id = dumps.FieldTruck
LEFT JOIN cer.shift_eqmt SSE ON SSE.shift_eqmt_id = dumps.FieldTruck AND SSE.ShiftId=dumps.ShiftId
LEFT JOIN cer.Enum enums on enums.enum_Id=dumps.FieldLoad AND enums.Idx NOT IN (26,27,28,29,30)
WHERE s.FieldId in ('MILLCHAN','MILLCRUSH1','MILLCRUSH2','HIDROCHAN')
GROUP BY dumps.shiftid, t.FieldId 
)*/


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
ISNULL(AvgUseOfAvailibility