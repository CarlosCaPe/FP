CREATE VIEW [ABR].[CONOPS_ABR_DELTA_C_V] AS



  
--select * from [abr].[CONOPS_ABR_DELTA_C_V]  
CREATE VIEW [ABR].[CONOPS_ABR_DELTA_C_V]   
AS  
  
SELECT  
a.shiftflag,  
a.ShiftStartDateTime,  
a.ShiftEndDateTime,  
a.siteflag,  
a.shiftid,  
b.deltac_ts,  
b.delta_c  
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a (NOLOCK)  
  
LEFT JOIN (  
select   
site_code,  
shiftindex,  
deltac_ts,  
avg(delta_c) as delta_c  
from [dbo].[delta_c] WITH (nolock)  
where site_code = 'ELA'  
group by site_code,deltac_ts,shiftindex) b  
ON a.shiftindex = b.shiftindex 
  
  
  
  


