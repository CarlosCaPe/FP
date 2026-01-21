CREATE VIEW [CLI].[CONOPS_CLI_SHOVEL_TPRH_V] AS
  
  
--select * from [cli].[CONOPS_CLI_SHOVEL_TPRH_V] where shiftflag = 'curr'  
  
CREATE VIEW [cli].[CONOPS_CLI_SHOVEL_TPRH_V] 
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
WHERE site_code = 'CLI'  
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
  
  
  
  
