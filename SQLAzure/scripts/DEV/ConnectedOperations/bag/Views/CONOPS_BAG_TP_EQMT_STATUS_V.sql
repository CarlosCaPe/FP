CREATE VIEW [bag].[CONOPS_BAG_TP_EQMT_STATUS_V] AS




--select * from [bag].[CONOPS_BAG_TP_EQMT_STATUS_V] where shiftflag = 'curr'

CREATE VIEW [bag].[CONOPS_BAG_TP_EQMT_STATUS_V]
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
b.eqmt,
b.eqmttype,
b.startdatetime,
b.enddatetime,
b.duration,
b.reasonidx,
b.reasons,
b.[status],
c.eqmtcurrstatus,
d.avg_deltac,
e.avg_payload
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select shiftid,eqmt,eqmttype,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [bag].[asset_efficiency] (NOLOCK)
where unittype = 'Truck') b
on a.shiftid = b.shiftid 

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [bag].[asset_efficiency] (NOLOCK)
where unittype = 'Truck') c
on b.shiftid = c.shiftid
and b.eqmt = c.eqmt

LEFT JOIN (
select 
site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck, avg(delta_c) as avg_deltac
from [dbo].[delta_c] (NOLOCK)
WHERE site_code = 'BAG'
group by site_code,shiftdate,shift_code,truck) d
on b.shiftid = d.shiftid
AND b.eqmt = d.truck
AND a.siteflag = d.site_code

LEFT JOIN (
SELECT shiftflag,truck, avg_payload
FROM [bag].[CONOPS_BAG_TP_AVG_PAYLOAD_V] (NOLOCK)
) e
on a.shiftflag = e.shiftflag
AND b.eqmt = e.truck


WHERE b.eqmt IS NOT NULL


