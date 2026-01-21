CREATE VIEW [ABR].[CONOPS_ABR_OVERALL_DELTA_C_V] AS


  
  
  
  
--select * from [abr].[CONOPS_ABR_OVERALL_DELTA_C_V]  
CREATE VIEW [abr].[CONOPS_ABR_OVERALL_DELTA_C_V]   
AS  
  
SELECT  
a.shiftflag,  
a.siteflag,  
a.shiftid,  
avg(b.delta_c) As delta_c,  
ISNULL(DeltaCTarget, 0) AS DeltaCTarget
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a (NOLOCK)  
LEFT JOIN (  
select   
site_code,  
shiftindex,  
avg(delta_c) as delta_c  
from [dbo].[delta_c] (nolock)  
where site_code = 'ELA'  
group by site_code,shiftindex) b  
ON a.shiftindex = b.shiftindex --AND a.siteflag = b.site_code  
LEFT JOIN [abr].[CONOPS_ABR_DELTA_C_TARGET_V]  ps 
ON a.shiftid = ps.shiftid
  
  
GROUP BY a.shiftflag,a.siteflag,a.shiftid,DeltaCTarget
  
  
  


