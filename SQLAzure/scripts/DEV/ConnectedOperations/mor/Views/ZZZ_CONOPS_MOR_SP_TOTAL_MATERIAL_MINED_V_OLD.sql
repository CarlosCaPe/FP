CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SP_TOTAL_MATERIAL_MINED_V_OLD] AS




--select * from [mor].[CONOPS_MOR_SP_TOTAL_MATERIAL_MINED_V] where shiftflag = 'prev' order by shovelid asc
CREATE VIEW [mor].[CONOPS_MOR_SP_TOTAL_MATERIAL_MINED_V_OLD]
AS

WITH SHOVEL AS (

SELECT 
shiftflag,
siteflag,
shiftindex,
shiftid,
shovelid,
operatorid,
operatorname,
shovelactual,
shoveltarget,
offtarget,
delta_c,
deltac_target,
idletime,
idletimeTarget,
spotting,
SpotingTarget,
loading,
loadingtarget,
dumping,
dumpingtarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SHOVEL_TO_WATCH_V_OLD]
WHERE siteflag = 'MOR'),

TPRH AS (
SELECT
shiftindex,eqmt,tprh
FROM [mor].[CONOPS_MOR_SHOVEL_TPRH_V] (NOLOCK)
WHERE site_code = 'MOR'),

TGT AS (
SELECT 
Formatshiftid,shovel,sum(tons) as tons
FROM mor.plan_values
GROUP BY Formatshiftid,shovel),

NLOAD AS (
SELECT  shiftindex,excav,COUNT(*) as NrofLoad
FROM dbo.lh_load WITH (nolock)
WHERE site_code = 'MOR'
GROUP BY shiftindex, site_code,excav),

AE AS (
select 
shiftid,
eqmt,
Ops_efficient_pct as AssetEfficiency,
availability_pct
from [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] WITH (NOLOCK)
WHERE [siteflag] = 'MOR'),

PL AS (
SELECT  shiftindex,excav,avg(measureton) as payload
FROM dbo.lh_load WITH (nolock)
WHERE site_code = 'MOR'
GROUP BY shiftindex, site_code,excav),


DCTGT AS (

SELECT 
substring(replace(DateEffective,'-',''),3,4) as shiftdate,
LoadingAssetEfficiency AS AssetEfficiencyTarget
FROM [mor].[plan_values_prod_sum] (nolock))

SELECT
a.shiftflag,
a.siteflag,
a.shiftindex,
a.shovelid,
a.operatorid,
a.operatorname,
a.shovelactual,
a.shoveltarget,
a.offtarget,
a.delta_c,
a.deltac_target,
a.idletime,
a.idletimeTarget,
a.spotting,
a.SpotingTarget,
a.loading,
a.loadingtarget,
a.dumping,
a.dumpingtarget,
b.TPRH,
(f.tons / (12 * (0.9 * d.availability_pct))) As TPRHTarget,
c.NrofLoad,
d.AssetEfficiency,
dc.AssetEfficiencyTarget,
e.payload,
'272' as payloadtarget,
a.reasonidx,
a.reasons,
a.eqmtcurrstatus
FROM SHOVEL a
LEFT JOIN TPRH b ON a.shiftindex = b.shiftindex AND a.shovelid = b.eqmt
LEFT JOIN NLOAD c ON a.shiftindex = c.shiftindex AND a.shovelid = c.excav
LEFT JOIN AE d ON a.shiftid = d.shiftid AND a.shovelid = d.eqmt
LEFT JOIN PL e ON a.shiftindex = e.shiftindex AND a.shovelid = e.excav
LEFT JOIN TGT f on a.shiftid = f.Formatshiftid AND a.shovelid = f.Shovel
LEFT JOIN DCTGT dc ON left(a.shiftid,4) = dc.shiftdate

WHERE a.siteflag = 'MOR'

