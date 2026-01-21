CREATE VIEW [bag].[ZZZ_CONOPS_BAG_SP_WORST_LOAD_TIME_V_OLD] AS



--SELECT distinct siteflag FROM [bag].[CONOPS_BAG_SP_WORST_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_SP_WORST_LOAD_TIME_V_OLD]
AS


WITH NL AS (
SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
b.excav,
c.payload,
b.NrofLoad,
d.LoadTime,
'2.5' AS LoadTimeTarget
FROM dbo.SHIFT_INFO_V a

LEFT JOIN (
select site_code,shiftindex,excav,count(*) as NrofLoad 
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'BAG'
group by shiftindex,excav,site_code) b
ON a.shiftindex = b.shiftindex AND a.siteflag = b.site_code

LEFT JOIN (
select site_code,shiftindex,excav,avg(measureton) as payload 
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'BAG'
group by shiftindex,excav,site_code) c
ON a.shiftindex = c.shiftindex and b.excav = c.excav AND a.siteflag = b.site_code


LEFT JOIN (

SELECT 
site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(loadtime) as loadtime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'BAG'
GROUP BY site_code,shiftdate,shift_code,excav) d
ON a.shiftid = d.shiftid and b.excav = d.excav AND a.siteflag = d.site_code

WHERE a.siteflag = 'BAG'

),

TONS AS (
SELECT 
shiftid,
shovelid,
sum(totalmaterialmined) as tons
FROM [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V]
group by shiftid,shovelid),


TGT AS (
SELECT 
shiftid,
shovelid,
sum(shoveltarget) as [target]
FROM [bag].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V]
WHERE siteflag = 'BAG'
GROUP BY shiftid,shovelid),


DELTAC AS (

select site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(delta_c) as deltac, avg(idletime) as idletime,
avg(spottime) as spottime,avg(loadtime) as loadtime, avg(dumpingtime) as dumpingtime,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
from dbo.delta_c
where site_code = 'BAG'
group by site_code,shiftdate,shift_code,excav),

DCTGT AS (

SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,TotalDeltaC as Delta_c_target,
EFH as EFHtarget,'1.1' as spottarget, '2.5' as loadtarget, SHOVELIDLETIME as idletimetarget,
'2.5' as dumpingtarget,SHOVELASSETEFFICIENCY AS AssetEfficiencyTarget
FROM [bag].[plan_values_prod_sum] (nolock)),

OPER AS (
SELECT 
shiftflag,
shovelid,
upper(operator) as operatorname,
RIGHT('00000'+ CONVERT(VARCHAR,operatorid),10) AS operatorid
FROM [bag].[CONOPS_BAG_SHOVEL_INFO_V]
WHERE siteflag = 'BAG'),


STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [bag].[asset_efficiency] (NOLOCK)
where unittype = 'shovel'),


AE AS (
select 
shiftid,
eqmt,
Ops_efficient_pct as AssetEfficiency,
availability_pct
from [bag].[CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] WITH (NOLOCK)
WHERE [siteflag] = 'BAG'),


TPRH AS (
SELECT
shiftindex,eqmt,tprh
FROM [bag].[CONOPS_BAG_SHOVEL_TPRH_V] (NOLOCK)
WHERE site_code = 'BAG')


SELECT
nl.shiftflag,
nl.siteflag,
nl.shiftid,
nl.shiftindex,
nl.excav,
nl.payload,
nl.NrofLoad,
(tg.[target]/272.0) AS ShovelNrofLoadTarget,
nl.LoadTime,
nl.LoadTimeTarget,
op.operatorname,
op.operatorid,
tn.tons as shovelactual,
tg.[target] as shoveltarget,
dc.deltac as delta_c,
dctg.Delta_c_target as deltac_target,
dc.idletime,
dctg.idletimetarget,
dc.spottime as spotting,
dctg.spottarget as SpotingTarget,
dc.loadtime as loading,
dctg.loadtarget as LoadingTarget,
dc.dumpingtime as dumping,
dctg.dumpingtarget,
dc.EFH,
dctg.EFHtarget,
st.reasonidx,
st.reasons,
st.eqmtcurrstatus,
ae.AssetEfficiency,
dctg.AssetEfficiencyTarget,
tp.TPRH,
(tg.[target] / (12 * (0.9 * ae.availability_pct))) As TPRHTarget
FROM NL nl
LEFT JOIN TONS tn on nl.shiftid = tn.shiftid AND nl.excav = tn.ShovelId
LEFT JOIN TGT tg on nl.shiftid = tg.shiftid AND tn.shovelid = tg.shovelid
LEFT JOIN DELTAC dc on nl