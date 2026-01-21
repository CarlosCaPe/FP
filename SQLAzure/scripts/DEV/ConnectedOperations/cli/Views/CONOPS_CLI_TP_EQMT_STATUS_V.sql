CREATE VIEW [cli].[CONOPS_CLI_TP_EQMT_STATUS_V] AS



--select * from [cli].[CONOPS_CLI_TP_EQMT_STATUS_V] where shiftflag = 'curr'

CREATE VIEW [cli].[CONOPS_CLI_TP_EQMT_STATUS_V] 
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
b.eqmt,
f.eqmttype,
b.startdatetime,
b.enddatetime,
b.duration,
b.reasonidx,
b.reasons,
b.[status],
c.eqmtcurrstatus,
d.avg_deltac,
e.avg_payload
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [cli].[asset_efficiency] (NOLOCK)
where unittype = 'truck') b
on a.shiftid = b.shiftid 

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [cli].[asset_efficiency] (NOLOCK)
where unittype = 'truck') c
on b.shiftid = c.shiftid
and b.eqmt = c.eqmt
AND c.num = 1

LEFT JOIN (
select 
site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck, avg(delta_c) as avg_deltac
from [dbo].[delta_c] (NOLOCK)
WHERE site_code = 'CLI'
group by site_code,shiftdate,shift_code,truck) d
on b.shiftid = d.shiftid
AND b.eqmt = d.truck


LEFT JOIN (
SELECT shiftflag,truck, avg_payload
FROM [cli].[CONOPS_CLI_TP_AVG_PAYLOAD_V] (NOLOCK)
) e
on a.shiftflag = e.shiftflag
AND b.eqmt = e.truck


LEFT JOIN (
SELECT
shiftindex,
eqmtid,
eqmttype
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
WHERE SITE_CODE = 'CLI'
AND UNIT = 'Truck') f
ON a.shiftindex = f.shiftindex
AND b.eqmt = f.eqmtid

WHERE b.eqmt IS NOT NULL


