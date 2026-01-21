CREATE VIEW [Arch].[CONOPS_ARCH_SP_EQMT_STATUS_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_SP_EQMT_STATUS_V]
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
b.eqmt,
b.startdatetime,
b.enddatetime,
b.duration,
b.reasonidx,
b.reasons,
b.[status],
c.eqmtcurrstatus,
d.EFH,
e.tprh
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'shovel') b
on a.shiftid = b.shiftid AND a.siteflag = '<SITECODE>'

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'shovel') c
on b.shiftid = c.shiftid
AND b.eqmt = c.eqmt
AND a.siteflag = '<SITECODE>'

LEFT JOIN (
select site_code,concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c (NOLOCK)
--WHERE site_code = '<SITECODE>'
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
FROM [Arch].[CONOPS_ARCH_SHOVEL_TPRH_V] (NOLOCK)
--WHERE site_code = '<SITECODE>'
) e
ON a.ShiftIndex = e.shiftindex
and b.eqmt = e.eqmt
AND a.siteflag = e.site_code


WHERE a.siteflag = '<SITECODE>'
AND c.num = 1

