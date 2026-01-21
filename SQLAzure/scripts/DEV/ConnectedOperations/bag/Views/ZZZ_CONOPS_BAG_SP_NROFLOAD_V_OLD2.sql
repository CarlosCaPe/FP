CREATE VIEW [bag].[ZZZ_CONOPS_BAG_SP_NROFLOAD_V_OLD2] AS




--SELECT * FROM [bag].[CONOPS_BAG_SP_NROFLOAD_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_SP_NROFLOAD_V_OLD2]
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
select site_code,shiftindex,excav,count(*) as NrofLoad 
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'BAG'
group by shiftindex,excav,site_code) b
ON a.shiftindex = b.shiftindex AND b.site_code = a.siteflag 

LEFT JOIN (
select site_code,shiftindex,excav,avg(measureton) as payload 
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'BAG'
group by shiftindex,excav,site_code) c
ON a.shiftindex = c.shiftindex and b.excav = c.excav AND c.site_code = a.siteflag

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
from dbo.delta_c WITH (NOLOCK)
where site_code = 'BAG'
group by site_code,shiftdate,shift_code,excav),

DCTGT AS (

SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,TotalDeltaC as Delta_c_target,
EFH as EFHtarget,'1.1' as spottarget, '2.5' as loadtarget,SHOVELIDLETIME AS idletimetarget,
'2.5' as dumpingtarget
FROM [bag].[plan_values_prod_sum] WITH (nolock)),

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
WHERE [siteflag] = 'BAG')


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
dctg.idletimetarget,
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

WHERE nl.siteflag = 'BAG'