CREATE VIEW [ABR].[CONOPS_ABR_TP_EQMT_STATUS_V] AS




--select * from [abr].[CONOPS_ABR_TP_EQMT_STATUS_V] where shiftflag = 'curr'

CREATE VIEW [abr].[CONOPS_ABR_TP_EQMT_STATUS_V] 
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
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [abr].[asset_efficiency] (NOLOCK)
where unittype = 'truck') b
on a.shiftid = b.shiftid 

LEFT JOIN (
select shiftid,eqmt,startdatetime,enddatetime,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [abr].[asset_efficiency] (NOLOCK)
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
WHERE site_code = 'ELA'
group by site_code,shiftdate,shift_code,truck) d
on b.shiftid = d.shiftid
AND b.eqmt = d.truck
AND a.siteflag = d.site_code

LEFT JOIN (
SELECT shiftindex,truck, avg_payload
FROM [abr].[CONOPS_ABR_TP_AVG_PAYLOAD_V] (NOLOCK)
) e
on a.shiftindex = e.shiftindex
AND b.eqmt = e.truck


LEFT JOIN (
SELECT
shiftindex,
eqmtid,
eqmttype
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
WHERE SITE_CODE = 'ELA'
AND UNIT = 'Camion') f
ON a.shiftindex = f.shiftindex
AND b.eqmt = f.eqmtid

WHERE b.eqmt IS NOT NULL


