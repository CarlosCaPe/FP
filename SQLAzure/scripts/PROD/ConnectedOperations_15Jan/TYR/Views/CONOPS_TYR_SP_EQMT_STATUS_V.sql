CREATE VIEW [TYR].[CONOPS_TYR_SP_EQMT_STATUS_V] AS


  
  
--select * from [tyr].[CONOPS_TYR_SP_EQMT_STATUS_V] where shiftflag = 'curr'  
  
CREATE VIEW [TYR].[CONOPS_TYR_SP_EQMT_STATUS_V]  
AS  
  
SELECT  
a.shiftflag,  
a.siteflag,  
a.shiftid,  
a.ShiftStartDateTime,  
a.ShiftEndDateTime,  
b.eqmt,  
f.eqmttype,  
b.startdatetime,  
b.enddatetime,  
b.duration,  
b.reasonidx,  
b.reasons,  
b.[status],  
c.eqmtcurrstatus,  
d.EFH,  
e.tprh  
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a (NOLOCK)  
  
LEFT JOIN (  
select shiftid,eqmt,startdatetime,enddatetime,duration,reasonidx,reasons,[status]  
from [tyr].[asset_efficiency] (NOLOCK)  
where unittype = 'shovel') b  
on a.shiftid = b.shiftid   
  
LEFT JOIN (  
select shiftid,eqmt,startdatetime,enddatetime,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [tyr].[asset_efficiency] (NOLOCK)  
where unittype = 'shovel') c  
on b.shiftid = c.shiftid  
AND b.eqmt = c.eqmt  
AND c.num = 1  
  
LEFT JOIN (  
select site_code,concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,  
excav,  
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH  
FROM dbo.delta_c (NOLOCK)  
WHERE site_code = 'TYR'  
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
FROM [tyr].[CONOPS_TYR_SHOVEL_TPRH_V] (NOLOCK)) e  
ON a.ShiftIndex = e.shiftindex  
and b.eqmt = e.eqmt  
AND a.siteflag = e.site_code  
  
LEFT JOIN (  
SELECT  
shiftindex,  
eqmtid,  
eqmttype  
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)  
WHERE SITE_CODE = 'TYR'  
AND UNIT = 'Shovel') f  
ON a.shiftindex = f.shiftindex  
AND b.eqmt = f.eqmtid  
  
WHERE b.eqmt IS NOT NULL  
  
  
  
  

