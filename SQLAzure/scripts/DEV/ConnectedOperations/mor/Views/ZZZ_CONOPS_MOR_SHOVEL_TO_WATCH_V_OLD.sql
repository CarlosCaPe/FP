CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SHOVEL_TO_WATCH_V_OLD] AS


--select * from [mor].[CONOPS_MOR_SHOVEL_TO_WATCH_V] where shiftflag = 'curr'
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_TO_WATCH_V_OLD]
AS


SELECT 
a.shiftflag,
a.siteflag,
a.shiftindex,
a.shiftid,
a.shovelid,
b.soper as operatorname,
b.soperid as operatorid,
a.Actualvalue as shovelactual,
a.shoveltarget,
(a.shoveltarget - a.Actualvalue) as offtarget,
b.delta_c,
c.deltac_target,
b.idletime,
'1,1' as idletimeTarget,
b.spotting,
c.SpotingTarget,
b.loading,
c.LoadingTarget,
b.dumping,
c.dumpingtarget,
b.EFH,
c.EFHTarget,
d.reasonidx,
d.reasons,
d.eqmtcurrstatus
FROM [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] a (NOLOCK)

LEFT JOIN (
select site_code,concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,soper,soperid,avg(delta_c) as delta_c,avg(idletime) as idletime,
avg(spottime) as spotting,avg(loadtime) as loading,avg(dumpingtime) as dumping,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
from [dbo].[delta_c] (NOLOCK)
where site_code = 'MOR'
group by shiftdate,shift_code,site_code,excav,soper,soperid) b
on a.shiftid = b.shiftid
and a.siteflag = b.site_code
and a.shovelid = b.excav


LEFT JOIN (
SELECT  substring(replace(DateEffective,'-',''),3,4) as shiftdate, DeltaC as deltac_target,
Spoting as SpotingTarget, Loading as LoadingTarget,dumpingatcrusher + dumpingatstockpile as dumpingtarget,
Equivalentflathaul as EFHTarget
from [mor].[plan_values_prod_sum] (NOLOCK) ) c
on left(a.shiftid,4) = c.shiftdate


LEFT JOIN (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [mor].[asset_efficiency] (NOLOCK)
where unittype = 'shovel') d
on a.shiftid = d.shiftid
and a.shovelid = d.eqmt

WHERE (a.shoveltarget - a.Actualvalue) > 0
AND a.siteflag = 'MOR'
AND d.num = 1

