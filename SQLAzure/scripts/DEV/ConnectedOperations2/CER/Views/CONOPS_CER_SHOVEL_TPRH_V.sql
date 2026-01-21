CREATE VIEW [CER].[CONOPS_CER_SHOVEL_TPRH_V] AS
  
  
--select * from [cer].[CONOPS_CER_SHOVEL_TPRH_V] where shiftflag = 'curr'  
  
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_TPRH_V]  
AS  
  
  
WITH CTE AS(  
SELECT   
 site_code,  
 shiftindex,  
 excav,  
 COUNT(*) AS loadcount,  
 SUM(loadtons_us) AS loadtons,  
 SUM(EX_TMCAT01 + EX_TMCAT02) / 3600.00 AS ReadyHour  
FROM DBO.LH_LOAD (NOLOCK)  
WHERE site_code = 'CER'  
GROUP BY site_code,shiftindex,excav  
)  
  
SELECT   
 site_code,  
 shiftindex,  
 excav AS EQMT,  
 loadcount,  
 loadtons,  
 readyhour,  
 CASE WHEN readyhour = 0 OR readyhour IS NULL THEN 0 
 ELSE loadtons/readyhour END AS TPRH  
FROM CTE  
  
  
