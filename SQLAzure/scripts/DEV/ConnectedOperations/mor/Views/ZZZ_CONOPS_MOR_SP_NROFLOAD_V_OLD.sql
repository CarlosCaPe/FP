CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SP_NROFLOAD_V_OLD] AS





--SELECT * FROM [mor].[CONOPS_MOR_SP_NROFLOAD_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [mor].[CONOPS_MOR_SP_NROFLOAD_V_OLD]
AS

WITH NL AS (
SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
b.excav,
c.payload,
b.NrofLoad
FROM dbo.SHIFT_INFO_V a

LEFT JOIN (
select shiftindex,excav,count(*) as NrofLoad 
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'mor'
group by shiftindex,excav) b
ON a.shiftindex = b.shiftindex AND a.siteflag = 'MOR'

LEFT JOIN (
select shiftindex,excav,avg(measureton) as payload 
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'mor'
group by shiftindex,excav) c
ON a.shiftindex = c.shiftindex and b.excav = c.excav AND a.siteflag = 'MOR'

WHERE a.siteflag = 'MOR'

),

TONS AS (
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
group by site_code,shiftdate,shift_code,excav),

DCTGT AS (

SELECT substring(replace(DateEffective,'-',''),3,4) as shiftdate,DeltaC as Delta_c_target,
EquivalentFlatHaul as EFHtarget,spoting as spottarget, loading as loadtarget,
(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget
FROM [mor].[plan_values_prod_sum] (nolock)),

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
from [mor].[asset_efficiency] (NOLOCK)
where unittype = 'shovel'),


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
nl.shiftflag,
nl.siteflag,
nl.shiftid,
nl.shiftindex,
nl.excav,
nl.payload,
nl.NrofLoad,
(tg.[target]/272.0) AS ShovelNrofLoadTarget,
--(sum(tg.[target]) / 272.0) AS NrofLoadShiftTarget,
op.operatorname,
op.operatorid,
tn.tons as shovelactual,
tg.[target] as shoveltarget,
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
ae.AssetEfficiency,
NULL AS AssetEfficiencyTarget,
tp.TPRH,
(tg.[target] / (12 * (0.9 * ae.availability_pct))) As TPRHTarget,
st.reasonidx,
st.reasons,
st.eqmtcurrstatus
FROM NL nl
LEFT JOIN TONS tn on nl.shiftid = tn.shiftid AND nl.excav = tn.ShovelId
LEFT JOIN TGT tg on nl.shiftid = tg.shiftid AND tn.shovelid = tg.shovelid
LEFT JOIN DELTAC dc on nl.shiftid = dc.shiftid AND dc.excav = tn.shovelid
LEFT JOIN DCTGT dctg on left(nl.shiftid,4) = dctg.shiftdate
LEFT JOIN OPER op on nl.shiftflag = op.shiftflag AND op.shovelid = tn.shovelid
LEFT JOIN STAT st on nl.shiftid = st.shiftid AND st.eqmt = tn.ShovelId
LEFT JOIN AE ae ON ae.shiftid = nl.shiftid AND ae.eqmt = nl.excav
LEFT JOIN TPRH tp ON tp.shiftindex = nl.shiftindex AND tp.eqmt = nl.excav

WHERE nl.siteflag = 'MOR'
AND st.num = 1


