CREATE VIEW [bag].[ZZZ_CONOPS_BAG_SP_DELTA_C_V_OLD] AS


--SELECT * from [bag].[CONOPS_BAG_SP_DELTA_C_V] where shiftflag = 'prev' order by deltac desc

CREATE VIEW [bag].[CONOPS_BAG_SP_DELTA_C_V_OLD]
AS


WITH DELTAC AS (
SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
b.excav,
--b.soper,
--b.soperid,
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
b.EmptyTravel,
b.emptytraveltarget,
b.LoadedTravel,
b.loadedtraveltarget
FROM dbo.shift_info_v a

LEFT JOIN (

SELECT
dcavg.shiftid,
dcavg.site_code,
dcavg.excav,
--dcavg.soper,
--dcavg.soperid,
dcavg.deltac,
ps.Delta_c_target,
dcavg.idletime,
idletimetarget,
dcavg.spottime,
ps.spottarget,
dcavg.loadtime,
ps.loadtarget,
dcavg.DumpingTime,
ps.dumpingtarget,
dcavg.EFH,
ps.EFHtarget,
dcavg.EmptyTravel,
ps.emptytraveltarget,
dcavg.LoadedTravel,
ps.loadedtraveltarget
FROM [bag].[CONOPS_BAG_SP_DELTA_C_AVG_V] dcavg
LEFT JOIN (
SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
TotalDeltaC as Delta_c_target,
EFH as EFHtarget,'1.1' as spottarget, '2.5' as loadtarget,
--(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget, 
'2.5' AS  dumpingtarget,
shovelidletime AS idletimetarget,
TRUCKLOADEDTRAVEL as loadedtraveltarget, TRUCKEMPTYTRAVEL as emptytraveltarget
FROM [bag].[plan_values_prod_sum] (nolock)) ps
on left(dcavg.shiftid,4) = ps.shiftdate

WHERE dcavg.site_code = 'BAG'  
) b ON a.shiftid = b.shiftid and a.siteflag = b.site_code),


STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [bag].[asset_efficiency] (NOLOCK)
where unittype = 'shovel'),


TONS AS (
select actual.shiftid,actual.shovelid,sum(actual.totalmaterialmined) as tons,
starget.[target]
from [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V] (NOLOCK) actual

LEFT JOIN (
SELECT 
FORMATSHIFTID,
Shovelid,
cast(sum(tons) as int) as [target]
FROM (

select
FORMATSHIFTID,
Shovelid AS ShovelidOrig,
CASE WHEN Shovelid Like '%L01%' THEN 'L01'
WHEN Shovelid Like '%L02%' THEN 'L02'
WHEN Shovelid Like '%S08%' THEN 'S08'
WHEN Shovelid Like '%S10%' THEN 'S10'
WHEN Shovelid Like '%S11%' THEN 'S11'
WHEN Shovelid Like '%S12%' THEN 'S12'
WHEN Shovelid Like '%S22%' THEN 'S22'
WHEN Shovelid Like '%S23%' THEN 'S23'
END AS Shovelid,
Tons

from (
select FORMATSHIFTID, ShovelId,Tons
from [bag].[plan_values]
unpivot
(
  Tons
  for ShovelId in (L01ORE,L01WASTE_OXIDE,L02ORE,L02WASTE_OXIDE,S08ORE,S08WASTE_OXIDE,S10ORE,S10WASTE_OXIDE,
  S11ORE,S11WASTE_OXIDE,S12ORE,S12WASTE_OXIDE,S22ORE,S22WASTE_OXIDE,S23ORE,S23WASTE_OXIDE)
) unpiv
) b) c
group by FORMATSHIFTID,Shovelid) starget
on actual.shiftid = starget.formatshiftid 
AND actual.shovelid = starget.shovelId

group by actual.shiftid,actual.shovelid,starget.[target]),


PL AS (
SELECT  shiftindex,excav,avg(measureton) as payload
FROM dbo.lh_load WITH (nolock)
WHERE site_code = 'BAG'
GROUP BY shiftindex, site_code,excav),

NL AS (
select shiftindex,excav,count(*) as NrofLoad 
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'BAG'
group by shiftindex,excav),


TPRH AS (
SELECT
shiftindex,eqmt,tprh
FROM [bag].[CONOPS_BAG_SHOVEL_TPRH_V] (NOLOCK)
WHERE site_code = 'BAG'),


AE AS (
select 
shiftid,
eqmt,
Ops_efficient_pct as AssetEfficiency,
availability_pct
from [bag].[CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] WITH (NOLOCK)
WHERE [siteflag] = 'BAG'),


OPER AS (
SELECT 
shiftflag,
shovelid,
upper(operator) as operatorname,
RIGHT('00000'+ CONVERT(VARCHAR,operatorid),10) AS operatorid
FROM [bag].[CONOPS_BAG_SHOVEL_INFO_V]
WHERE siteflag = 'BAG')


SELECT 
dc.shiftflag,
dc.siteflag,
dc.shiftid,
dc.excav,
op.operatorname as soper,
op.operatorid as soperid,
tn.tons as actual,
tn.[target],
dc.deltac,
dc.Delta_c_target,
dc.idletime,
dc.idletimetarget,
dc.sp