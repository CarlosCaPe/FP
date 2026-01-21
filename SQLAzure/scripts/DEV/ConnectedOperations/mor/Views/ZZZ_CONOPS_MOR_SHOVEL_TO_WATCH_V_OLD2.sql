CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SHOVEL_TO_WATCH_V_OLD2] AS



--select * from [mor].[CONOPS_MOR_SHOVEL_TO_WATCH_V] where shiftflag = 'prev'
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_TO_WATCH_V_OLD2]
AS

WITH TONS AS (
SELECT 
shiftid,
shovelid,
sum(totalmaterialmined) as tons
FROM [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V]
group by shiftid,shovelid),

TGT AS (
SELECT 
shiftid,
shovelid,
sum(shoveltarget) as [target]
FROM [mor].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V]
WHERE siteflag = 'MOR'
GROUP BY shiftid,shovelid),


DELTAC AS (

select site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(delta_c) as deltac, avg(idletime) as idletime,
avg(spottime) as spottime,avg(loadtime) as loadtime, avg(dumpingtime) as dumpingtime,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
from dbo.delta_c WITH (NOLOCK)
where site_code = 'mor'
--and shiftdate = '2022-12-19'
--and shift_code = 1
--and excav = 's40'
group by site_code,shiftdate,shift_code,excav),

DCTGT AS (

SELECT substring(replace(DateEffective,'-',''),3,4) as shiftdate,DeltaC as Delta_c_target,
EquivalentFlatHaul as EFHtarget,spoting as spottarget, loading as loadtarget,
(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget
FROM [mor].[plan_values_prod_sum] WITH (nolock)),

OPER AS (
SELECT 
shiftflag,
shovelid,
upper(operator) as operatorname,
RIGHT('00000'+ CONVERT(VARCHAR,operatorid),10) AS operatorid
FROM [mor].[CONOPS_MOR_SHOVEL_INFO_V]
WHERE siteflag = 'MOR'),


STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [mor].[asset_efficiency] WITH (NOLOCK)
where unittype = 'shovel'),


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
from [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] WITH (NOLOCK)
WHERE [siteflag] = 'MOR')


SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
tn.shovelid,
op.operatorname,
op.operatorid,
tn.tons as shovelactual,
tg.[target] as shoveltarget,
(tg.[target] - tn.tons) as offtarget,
dc.deltac as delta_c,
dctg.Delta_c_target as deltac_target,
dc.idletime,
'1.1' as idletimetarget,
dc.spottime as spotting,
dctg.spottarget as SpotingTarget,
dc.loadtime as loading,
dctg.loadtarget as LoadingTarget,
dc.dumpingtime as dumping,
dctg.dumpingtarget,
dc.EFH,
dctg.EFHtarget,
pl.payload,
'272' as payloadTarget,
nl.NrofLoad,
(tg.[target]/272.0) AS ShovelNrofLoadTarget,
tp.TPRH,
(tg.[target] / (12 * (0.9 * ae.availability_pct))) As TPRHTarget,
ae.AssetEfficiency,
NULL AS AssetEfficiencyTarget,
st.reasonidx,
st.reasons,
st.eqmtcurrstatus
FROM dbo.SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = 'MOR'
LEFT JOIN TGT tg on a.shiftid = tg.shiftid AND tn.shovelid = tg.shovelid AND a.siteflag = 'MOR'
LEFT JOIN DELTAC dc on a.shiftid = dc.shiftid AND dc.excav = tn.shovelid AND a.siteflag = 'MOR'
LEFT JOIN DCTGT dctg on left(a.shiftid,4) = dctg.shiftdate AND a.siteflag = 'MOR'
LEFT JOIN OPER op on a.shiftflag = op.shiftflag AND op.shovelid = tn.shovelid AND a.siteflag = 'MOR'
LEFT JOIN STAT st on a.shiftid = st.shiftid AND st.eqmt = tn.ShovelId AND a.siteflag = 'MOR'
LEFT JOIN PL pl on pl.SHIFTINDEX = a.ShiftIndex AND pl.EXCAV = tn.ShovelId AND a.siteflag = 'MOR'
LEFT JOIN NL nl on a.shiftindex = nl.shiftindex AND tn.shovelid = nl.excav AND a.siteflag = 'MOR'
LEFT JOIN TPRH tp on a.shiftindex = tp.shiftindex AND tn.shovelid = tp.eqmt AND a.siteflag