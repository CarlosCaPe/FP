CREATE VIEW [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V] AS


--select * from [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V]
CREATE VIEW [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V]
AS

select 
a.shiftflag,
b.siteflag,
b.shiftid,
b.excav,
RIGHT('00000'+ CONVERT(VARCHAR,b.soperid),10) as soperid,
b.soper,
b.truck,
RIGHT('00000'+ CONVERT(VARCHAR,b.toperid),10) as toperid,
b.toper,
b.unit,
b.truck_idledelta,
b.shovel_idledelta,
b.spotdelta,
b.loaddelta,
b.dumpdelta,
b.ET_delta,
b.LT_delta,
b.Bench,
b.Delta_C,
c.Delta_c_target,
b.deltac_ts,
b.DumpingTime,
b.Distloaded,
b.FLiftUP,
b.FLiftDown,
b.region
FROM [dbo].[SHIFT_INFO_V] a
LEFT JOIN (
select 
site_code as siteflag,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
soperid,
soper,
truck,
toperid,
toper,
unit,
truck_idledelta,
shovel_idledelta,
spotdelta,
loaddelta,
dumpdelta,
ET_delta,
LT_delta,
Bench,
Delta_C,
deltac_ts,
DumpingTime,
Distloaded,
FLiftUP,
FLiftDown,
region
from [dbo].[delta_c]
where site_code = 'MOR'
) b
on a.shiftid = b.shiftid

LEFT JOIN (
SELECT substring(replace(DateEffective,'-',''),3,4) as shiftdate,DeltaC as Delta_c_target,
EquivalentFlatHaul as EFHtarget,spoting as spottarget, loading as loadtarget,
(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget, DumpingAtCrusher as dumpingAtCrusherTarget,
DumpingatStockpile as dumpingatStockpileTarget, ElecShovelUseOfAvailability as useOfAvailabilityTarget
FROM [mor].[plan_values_prod_sum] (nolock)) c
on left(a.shiftid,4) = c.shiftdate


