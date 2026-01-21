CREATE VIEW [Arch].[CONOPS_ARCH_TP_EQMT_STATUS_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_TP_EQMT_STATUS_V]
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
b.eqmt,
b.startdatetime,
b.enddatetime,
b.duration,
b.reasonidx,
b.reasons,
b.[status],
c.eqmtcurrstatus,
d.avg_deltac,
e.avg_payload
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'truck') b
on a.shiftid = b.shiftid AND a.siteflag = '<SITECODE>'

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'truck') c
on b.shiftid = c.shiftid
and b.eqmt = c.eqmt

LEFT JOIN (
select 
site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck, avg(delta_c) as avg_deltac
from [dbo].[delta_c] (NOLOCK)
--WHERE site_code = '<SITECODE>'
group by site_code,shiftdate,shift_code,truck) d
on b.shiftid = d.shiftid
AND b.eqmt = d.truck
AND a.siteflag = d.site_code

LEFT JOIN (
SELECT shiftflag,truck, avg_payload
FROM [Arch].[CONOPS_ARCH_TP_AVG_PAYLOAD_V] (NOLOCK)
WHERE siteflag = '<SITECODE>'
) e
on a.shiftflag = e.shiftflag
AND b.eqmt = e.truck


WHERE a.siteflag = '<SITECODE>'
AND c.num = 1

