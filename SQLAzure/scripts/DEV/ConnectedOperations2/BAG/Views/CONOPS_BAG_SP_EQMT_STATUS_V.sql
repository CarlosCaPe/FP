CREATE VIEW [BAG].[CONOPS_BAG_SP_EQMT_STATUS_V] AS


--select * from [bag].[CONOPS_BAG_SP_EQMT_STATUS_V] where shiftflag = 'curr'

CREATE VIEW [BAG].[CONOPS_BAG_SP_EQMT_STATUS_V]
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
b.eqmt,
b.eqmttype,
b.startdatetime,
b.enddatetime,
b.duration,
b.reasonidx,
b.reasons,
b.[status],
c.eqmtcurrstatus,
d.EFH,
e.tprh
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select shiftid,eqmt,eqmttype,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [bag].[ASSET_EFFICIENCY] (NOLOCK)
where unittype IN ('Shovel','Loader')) b
on a.shiftid = b.shiftid 

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [bag].[ASSET_EFFICIENCY] (NOLOCK)
where unittype IN ('Shovel','Loader')) c
on b.shiftid = c.shiftid
AND b.eqmt = c.eqmt
AND c.num = 1

LEFT JOIN (
select site_code,concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c (NOLOCK)
WHERE site_code = 'BAG'
group by shiftdate,shift_code,site_code,excav) d
ON b.shiftid = d.shiftid
AND b.eqmt = d.excav
AND a.siteflag = d.site_code

LEFT JOIN (
SELECT
shiftindex,
site_code,
eqmt,
tprh 
FROM [bag].[CONOPS_BAG_SHOVEL_TPRH_V] (NOLOCK)) e
ON a.ShiftIndex = e.shiftindex
and b.eqmt = e.eqmt
AND a.siteflag = e.site_code

WHERE b.eqmt IS NOT NULL



