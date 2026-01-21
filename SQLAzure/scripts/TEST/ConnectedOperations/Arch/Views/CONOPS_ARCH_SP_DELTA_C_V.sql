CREATE VIEW [Arch].[CONOPS_ARCH_SP_DELTA_C_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_SP_DELTA_C_V]
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
FROM [Arch].[CONOPS_ARCH_SP_DELTA_C_AVG_V] dcavg
LEFT JOIN (
SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
					   TotalDeltaC as Delta_c_target,
					   EFH as EFHtarget,
					   '1.1' as spottarget,
					   '2.5' as loadtarget,
					   '2.5' AS  dumpingtarget,
					   shovelidletime AS idletimetarget,
					   TRUCKLOADEDTRAVEL as loadedtraveltarget, 
					   TRUCKEMPTYTRAVEL as emptytraveltarget,
					   SHOVELASSETEFFICIENCY as AssetEfficiencyTarget
				FROM [Arch].[plan_values_prod_sum] (nolock)) ps
on left(dcavg.shiftid,4) = ps.shiftdate

WHERE dcavg.site_code = '<SITECODE>'  
) b ON a.shiftid = b.shiftid and a.siteflag = b.site_code),


STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'shovel'),


TONS AS (
SELECT 
actual.shiftid,
actual.shovelid,
sum(actual.totalmaterialmined) as tons,
sum(tgt.shovelshifttarget) AS  [target] 
FROM [Arch].[CONOPS_ARCH_SHIFT_OVERVIEW_V] (NOLOCK) actual
LEFT JOIN [Arch].[CONOPS_ARCH_SHOVEL_TARGET_V] tgt
ON actual.shiftid = tgt.FORMATSHIFTID AND actual.ShovelId = tgt.shovel
GROUP BY actual.shiftid,actual.shovelid),


PL AS (
SELECT  shiftindex,excav,avg(measureton) as payload
FROM dbo.lh_load WITH (nolock)
--WHERE site_code = '<SITECODE>'
GROUP BY shiftindex, site_code,excav),

NL AS (
select shiftindex,excav,count(*) as NrofLoad 
FROM dbo.lh_load WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
group by shiftindex,excav),


TPRH AS (
SELECT
shiftindex,eqmt,tprh
FROM [Arch].[CONOPS_ARCH_SHOVEL_TPRH_V] (NOLOCK)
--WHERE site_code = '<SITECODE>'
),


AE AS (
select 
shiftid,
eqmt,
Ops_efficient_pct as AssetEfficiency,
availability_pct
from [Arch].[CONOPS_ARCH_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] WITH (NOLOCK)
WHERE [siteflag] = '<SITECODE>'),


OPER AS (
SELECT 
shiftflag,
shovelid,
upper(operator) as operatorname,
RIGHT('00000'+ CONVERT(VARCHAR,operatorid),10) AS operatorid
FROM [Arch].[CONOPS_ARCH_SHOVEL_INFO_V]
WHERE siteflag = '<SITECODE>')


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
'272' AS payloadtarget,
nl.NrofLoad as NumberOfLoads,
(tn.[target]/272.0) AS NumberOfLoadsTarget,
ae.AssetEfficiency,
dc.AssetEfficiencyTarget,
tp.TPRH as TonsPerReadyHour,
(tn.[target] / (12 * (0.9 * ae.availability_pct))) As TonsPerReadyHourTarget,
stat.reasonidx,
stat.reasons,
stat.eqmtcurrstatus
FROM DELTAC dc
LEFT JOIN TO