CREATE VIEW [MOR].[CONOPS_MOR_DELTA_C_OVERVIEW_V] AS



--select * from [mor].[CONOPS_MOR_DELTA_C_OVERVIEW_V]
CREATE VIEW [mor].[CONOPS_MOR_DELTA_C_OVERVIEW_V]
AS

select 
a.shiftflag,
b.siteflag,
b.shiftid,
b.excav,
b.soperid,
b.soper,
b.truck,
b.toperid,
b.toper,
b.unit,
b.idletime,
'1.1' as idletimetarget,
b.spottime,
c.spottarget,
b.loadtime,
c.loadtarget,
b.Bench,
b.Delta_C,
c.Delta_c_target,
b.deltac_ts,
b.DumpingTime,
b.DUMPDELTA,
c.dumpingtarget,
c.EFHtarget,
b.Distloaded,
b.FLiftUP,
b.FLiftDown,
b.region,
c.dumpingAtCrusherTarget,
c.dumpingatStockpileTarget,
c.useOfAvailabilityTarget,
d.eqmtcurrstatus
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)

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
idletime,
spottime,
loadtime,
Bench,
Delta_C,
deltac_ts,
DumpingTime,
DUMPDELTA,
Distloaded,
FLiftUP,
FLiftDown,
region
from [dbo].[delta_c] (nolock)
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


LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [mor].[asset_efficiency] (NOLOCK)) d
on b.shiftid = d.shiftid
AND (b.excav = d.eqmt
OR b.truck = d.eqmt)

WHERE b.siteflag = 'MOR'

