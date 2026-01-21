CREATE VIEW [ABR].[CONOPS_ABR_DELTA_C_WORST_SHOVEL_V] AS



--select * from [abr].[CONOPS_ABR_DELTA_C_WORST_SHOVEL_V]  
CREATE VIEW [ABR].[CONOPS_ABR_DELTA_C_WORST_SHOVEL_V]   
AS  
  
  
SELECT  
a.shiftflag,  
a.ShiftStartDateTime,  
a.ShiftEndDateTime,  
a.siteflag,  
a.shiftid,  
b.excav,  
b.deltac_ts,  
b.delta_c,  
DeltaCTarget  
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a (NOLOCK)  
  
LEFT JOIN (  
select   
site_code,  
shiftindex,  
excav,  
deltac_ts,  
avg(delta_c) as delta_c  
from [dbo].[delta_c] (nolock)  
where site_code = 'ELA'  
group by site_code,excav,deltac_ts,shiftindex) b  
ON a.shiftindex = b.shiftindex --AND a.siteflag = b.site_code   
LEFT JOIN [abr].[CONOPS_ABR_DELTA_C_TARGET_V] c
ON a.shiftid = c.shiftid
 
  
  
  
  


