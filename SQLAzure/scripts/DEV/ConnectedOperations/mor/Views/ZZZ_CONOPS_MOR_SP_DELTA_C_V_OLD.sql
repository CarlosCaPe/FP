CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SP_DELTA_C_V_OLD] AS






CREATE VIEW [mor].[CONOPS_MOR_SP_DELTA_C_V_OLD]
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
b.loadedtraveltarget,
b.AssetEfficiencyTarget
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
'1.1' as idletimetarget,
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
ps.loadedtraveltarget,
ps.AssetEfficiencyTarget
FROM [mor].[CONOPS_MOR_SP_DELTA_C_AVG_V_OLD] dcavg
CROSS JOIN (
SELECT TOP 1
substring(replace(DateEffective,'-',''),3,4) as shiftdate,DeltaC as Delta_c_target,
EquivalentFlatHaul as EFHtarget,spoting as spottarget, loading as loadtarget,
loadingassetefficiency as AssetEfficiencyTarget,
(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget, loadedtravel as loadedtraveltarget, 
emptytravel as emptytraveltarget
FROM [mor].[plan_values_prod_sum] (nolock)
ORDER BY DateEffective DESC) ps


WHERE dcavg.site_code = 'MOR'  
) b ON a.shiftid = b.shiftid and a.siteflag = b.site_code),


STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [mor].[asset_efficiency] (NOLOCK)
where unittype = 'shovel'),


TONS AS (
select actual.shiftid,actual.shovelid,sum(actual.totalmaterialmined) as tons,
starget.[target]
from [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V] (NOLOCK) actual

LEFT JOIN (
select formatshiftid,shovel,sum(tons) as [target]
from [mor].[plan_values] (NOLOCK) 
group by formatshiftid,shovel) starget
on actual.shiftid = starget.formatshiftid 
AND actual.shovelid = starget.shovel

group by actual.shiftid,actual.shovelid,starget.[target]),


PL AS (
SELECT  shiftindex,excav,avg(measureton) as payload
FROM dbo.lh_load WITH (nolock)
WHERE site_code = 'MOR'
GROUP BY shiftindex, site_code,excav),

NL AS (
select shiftindex,excav,count(*) as NrofLoad 
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'mor'
group by shiftindex,excav),


TPRH AS (
SELECT
shiftindex,eqmt,tprh
FROM [mor].[CONOPS_MOR_SHOVEL_TPRH_V] (NOLOCK)
WHERE site_code = 'MOR'),


AE AS (
select 
shiftid,
eqmt,
Ops_efficient_pct as AssetEfficiency,
availability_pct
from [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V_OLD] WITH (NOLOCK)
WHERE [siteflag] = 'MOR'),


OPER AS (
SELECT 
shiftflag,
shovelid,
upper(operator) as operatorname,
RIGHT('00000'+ CONVERT(VARCHAR,operatorid),10) AS operatorid
FROM [mor].[CONOPS_MOR_SHOVEL_INFO_V]
WHERE siteflag = 'MOR')


SELECT 
dc.shiftflag,
dc.siteflag,
dc.shiftid,
dc.shiftindex,
dc.excav as ShovelID,
op.operatorname as Operator,
concat('https://images.services.fmi.com/publishedimages/',op.operatorid,'.jpg') as OperatorImageURL,
tn.tons as TotalMaterialMined,
tn.[target] as TotalMaterialMinedTarget,
dc.deltac,
dc.Delta_c_target as DeltaCTarget,
dc.idletime,
dc.idletimetarget,
dc.spottime as Spotting,
dc.spottarget as SpottingTarget,
dc.loadtime as Loading,
dc.loadtarget as LoadingTarget,
dc.DumpingTime as Dumping,
dc.dumpingtarget,
dc.EFH,
dc.EFHtarget,
pl.payload,
'267' AS payloadtarget,
nl.NrofLoad as NumberOfLoads,
(tn.[target]/267.0) AS NumberOfLoadsTarget,
ae.AssetEfficiency,
dc.AssetEfficiencyTarget,
tp.TPRH as TonsPerReadyHour,
(tn.[target] / (12 * (0.9 * ae.availability_pct))) As TonsPerReadyHourTarget,
stat.reasonidx,
stat.reasons,
stat.eqmtcurrstatus
FROM DELTAC dc
LEFT JOIN TONS tn ON dc.shiftid = tn.shiftid AND