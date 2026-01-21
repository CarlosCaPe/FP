CREATE VIEW [Arch].[CONOPS_ARCH_TP_DELTA_C_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_TP_DELTA_C_V]
AS

WITH DELTAC AS (
SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
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
FROM dbo.shift_info_v a

LEFT JOIN (

SELECT
dcavg.shiftid,
dcavg.site_code,
dcavg.truck,
dcavg.deltac,
ps.Delta_c_target,
dcavg.idletime,
'2.12' as idletimetarget,
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
FROM [Arch].[CONOPS_ARCH_TP_DELTA_C_AVG_V] dcavg
LEFT JOIN (
SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,TotalDeltaC as Delta_c_target,
EFH as EFHtarget,'1.1' as spottarget, '2.5' as loadtarget,
--(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget,
'2.5' AS dumpingtarget,
'1.25' as dumpingAtCrusherTarget,
'1.25' as dumpingatStockpileTarget, TRUCKUSEOFAVAILABILITY as useOfAvailabilityTarget
FROM [Arch].[plan_values_prod_sum] (nolock)) ps
on left(dcavg.shiftid,4) = ps.shiftdate

WHERE dcavg.site_code = '<SITECODE>' 
 
) b ON a.shiftid = b.shiftid and a.siteflag = b.site_code
WHERE a.siteflag = '<SITECODE>'),


STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'truck'),


TONS AS (
SELECT 
pavg.shiftflag,pavg.truck, 
pavg.AVG_Payload,
pavg.[target] AS AVG_PayloadTarget,
f.toper,
f.OperatorImageURL
FROM [Arch].[CONOPS_ARCH_TP_AVG_PAYLOAD_V] pavg
LEFT JOIN (
SELECT 
shiftflag,
truckid,
Operator as toper,
OperatorImageURL
FROM [Arch].[CONOPS_ARCH_TRUCK_DETAIL_V]) f
ON pavg.shiftflag = f.shiftflag
and pavg.truck = f.truckid
WHERE pavg.siteflag = '<SITECODE>'),

UoA AS (
SELECT
shiftid,
eqmt,
use_of_availability_pct AS useOfAvailability
FROM [Arch].[CONOPS_ARCH_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V]
WHERE siteflag = '<SITECODE>'),

LOC AS (
SELECT
shiftid,
truckid,
[Location] AS [destination]
FROM [Arch].[CONOPS_ARCH_TRUCK_DETAIL_V]
WHERE siteflag = '<SITECODE>'),

TMD AS (
SELECT 
sd.shiftid,
'<SITECODE>' siteflag,
t.FieldId AS [TruckId],
SUM(sd.FieldLsizetons) AS TotalMaterialDelivered,
NULL AS TotalMaterialDeliveredTarget
FROM ARCH.shift_dump_v sd WITH (NOLOCK)
LEFT JOIN ARCH.shift_eqmt t ON t.Id = sd.FieldTruck
GROUP BY sd.shiftid, t.FieldId),

PIT AS (
select 
si.shiftid,
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
from dbo.SHIFT_INFO_V si
LEFT JOIN dbo.lh_dump ldump
ON si.shiftindex = ldump.shiftindex
AND si.siteflag = ldump.SITE_CODE

WHERE si.siteflag = '<SITECODE>')

SELECT 
dc.shiftflag,
dc.siteflag,
dc.shiftid,
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
dc.dumpingA