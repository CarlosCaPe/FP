CREATE VIEW [mor].[ZZZ_CONOPS_MOR_TP_DELTA_C_V_OLD] AS



--select  shiftflag,siteflag,truck,deltac from [mor].[CONOPS_MOR_TP_DELTA_C_V] where shiftflag = 'prev' and truck = 'T622'

CREATE VIEW [mor].[CONOPS_MOR_TP_DELTA_C_V_OLD] 
AS

WITH DELTAC AS (
SELECT
b.shiftindex,
b.truck,
b.deltac,
b.Delta_c_target,
b.idletime,
b.idletimetarget,
b.spottime,
b.spottarget,
b.loadtime,
b.loadtarget,
b.DumpingTime,
b.dumpingtarget,
b.EFH,
b.EFHtarget,
b.DumpingAtStockpile,
b.dumpingatStockpileTarget,
b.DumpingAtCrusher,
b.dumpingAtCrusherTarget,
b.useOfAvailabilityTarget
FROM (

SELECT
dcavg.shiftindex,
dcavg.site_code,
dcavg.truck,
dcavg.deltac,
ps.Delta_c_target,
dcavg.idletime,
'1.1' as idletimetarget,
dcavg.spottime,
ps.spottarget,
dcavg.loadtime,
ps.loadtarget,
dcavg.DumpingTime,
ps.dumpingtarget,
dcavg.EFH,
ps.EFHtarget,
dcavg.DumpingAtStockpile,
ps.dumpingatStockpileTarget,
dcavg.DumpingAtCrusher,
ps.dumpingAtCrusherTarget,
ps.useOfAvailabilityTarget
FROM [mor].[CONOPS_MOR_TP_DELTA_C_AVG_V] dcavg
CROSS JOIN (
SELECT TOP 1
substring(replace(DateEffective,'-',''),3,4) as shiftdate,DeltaC as Delta_c_target,
EquivalentFlatHaul as EFHtarget,spoting as spottarget, loading as loadtarget,
(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget, DumpingAtCrusher as dumpingAtCrusherTarget,
DumpingatStockpile as dumpingatStockpileTarget, ElecShovelUseOfAvailability as useOfAvailabilityTarget
FROM [mor].[plan_values_prod_sum] (nolock)
ORDER BY DateEffective DESC) ps

) b ),


STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [mor].[asset_efficiency] (NOLOCK)
where unittype = 'truck'),


TONS AS (
SELECT 
pavg.shiftindex,
pavg.truck, 
pavg.AVG_Payload,
pavg.[target] AS AVG_PayloadTarget,
f.toper,
f.OperatorImageURL
FROM [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V] pavg
LEFT JOIN (
SELECT 
shiftindex,
truckid,
Operator as toper,
OperatorImageURL
FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V]) f
ON pavg.shiftindex = f.shiftindex
and pavg.truck = f.truckid),

UoA AS (
SELECT
shiftid,
eqmt,
use_of_availability_pct AS useOfAvailability
FROM [mor].[CONOPS_MOR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V]
WHERE siteflag = 'MOR'),

LOC AS (
SELECT
shiftid,
truckid,
[Location] AS [destination]
FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V]
WHERE siteflag = 'MOR'),

TMD AS (
SELECT 
sd.shiftid,
t.FieldId AS [TruckId],
SUM(sd.FieldLsizetons) AS TotalMaterialDelivered,
NULL As TotalMaterialDeliveredTarget
FROM mor.shift_dump_v sd WITH (NOLOCK)
LEFT JOIN mor.shift_eqmt t ON t.Id = sd.FieldTruck
GROUP BY sd.shiftid, t.FieldId),

PIT AS (
select 
site_code,
ldump.shiftindex,
ldump.truck,
case when ldump.dump_blast like '%WT%' THEN 'W COOPER 10'
when ldump.dump_blast like '%WF%' THEN 'W COOPER 14'
when ldump.dump_blast like '%SR%' THEN 'SUN RIDGE MINE'
when ldump.dump_blast like '%AM%' THEN 'AMT MINE'
when ldump.dump_blast like '%WC%' THEN 'W COOPER'
when ldump.dump_blast like '%CO%' THEN 'CORONADO'
when ldump.dump_blast IS NULL THEN 'Other'
when ldump.grade like '%MILL%' THEN 'Mill Stockpiles'
ELSE ldump.grade end as Pushback,
ROW_NUMBER() OVER (PARTITION BY ldump.shiftindex,ldump.truck ORDER BY ldump.TIMEDUMP_TS DESC) row_num
from dbo.lh_dump ldump

WHERE ldump.site_code = 'MOR')

SELECT 
[shift].shiftflag,
[shift].siteflag,
[shift].shiftid,
dc.truck,
UPPER(tn.toper) as toper,
tn.OperatorImageURL,
tn.AVG_Payload,
tn.AVG_PayloadTarget,
dc.deltac,
dc.Delta_c_target,
dc.idletime,
dc.idletimetarget,
dc.spottime,
dc.spottarget,
dc.loadtime,
dc.loadtarget,
dc.DumpingTime,
dc.dumpingtarget,
dc.EFH,
dc.EFHtarget,
dc.DumpingAtStockpile,
dc.dumpingatStockpileTarget,
dc.DumpingAtCrusher,
dc.dumpingAtCrusherTarget,
uo.useOfAvailability,
dc.useOfAvailabilityTarget,
tmd.TotalMaterialDelivered,
tmd.TotalMaterialDeliveredTarget,
loc.[destination],
pit.Pushback AS Pit,
stat.reasonidx,
stat.