CREATE VIEW [TYR].[CONOPS_TYR_DELTA_C_V] AS

  
--select * from [tyr].[CONOPS_TYR_DELTA_C_V]  
CREATE VIEW [TYR].[CONOPS_TYR_DELTA_C_V]   
AS  
  
SELECT  
a.shiftflag,  
a.ShiftStartDateTime,  
a.ShiftEndDateTime,  
a.siteflag,  
a.shiftid,  
b.deltac_ts,  
b.delta_c  
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a (NOLOCK)  
  
LEFT JOIN (  
select   
site_code,  
shiftindex,  
deltac_ts,  
avg(delta_c) as delta_c  
from [dbo].[delta_c] WITH (nolock)  
where site_code = 'TYR'  
group by site_code,deltac_ts,shiftindex) b  
ON a.shiftindex = b.shiftindex AND a.siteflag = b.site_code  

  
  
  
  
