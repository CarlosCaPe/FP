CREATE VIEW [TYR].[CONOPS_TYR_DELTA_C_WORST_TRUCK_V] AS


  
  
  
  
--select * from [tyr].[CONOPS_TYR_DELTA_C_WORST_TRUCK_V]  
CREATE VIEW [TYR].[CONOPS_TYR_DELTA_C_WORST_TRUCK_V]   
AS  
  
  
SELECT  
a.shiftflag,  
a.ShiftStartDateTime,  
a.ShiftEndDateTime,  
a.siteflag,  
a.shiftid,  
b.truck,  
b.deltac_ts,  
b.delta_c,  
DeltaCTarget  
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a (NOLOCK)  
  
LEFT JOIN (  
select   
site_code,  
shiftindex,  
truck,  
deltac_ts,  
avg(delta_c) as delta_c  
from [dbo].[delta_c] (nolock)  
where site_code = 'TYR'  
group by site_code,truck,deltac_ts,shiftindex) b  
ON a.shiftindex = b.shiftindex AND a.siteflag = b.site_code   
LEFT JOIN [tyr].[CONOPS_TYR_DELTA_C_TARGET_V]  c
ON a.SHIFTID = c.shiftid
  
 
  
  
  
  

