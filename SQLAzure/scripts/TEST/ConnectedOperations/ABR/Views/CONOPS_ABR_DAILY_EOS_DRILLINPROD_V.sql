CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_DRILLINPROD_V] AS



  
--select * from [abr].[CONOPS_ABR_DAILY_EOS_DRILLINPROD_V]   where shiftflag = 'prev'  
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_DRILLINPROD_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
siteflag,  
shiftflag,  
shiftid,
COUNT(Drill_ID) TotalDrill  
FROM [abr].[CONOPS_ABR_DAILY_DRILL_DETAIL_V]  
GROUP BY siteflag, shiftflag,shiftid)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
a.shiftid,
HOS,  
HR AS [Datetime],  
ROUND((TotalDrill * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS DrillInProd  
FROM [abr].[CONOPS_ABR_DAILY_HOURLY_DRILL_ASSET_EFFICIENCY_V] a  
LEFT JOIN CTE b ON a.shiftid = b.shiftid  
WHERE HOS IS NOT NULL
GROUP BY a.siteflag, a.shiftid,a.shiftflag, HOS, HR,TotalDrill  
  
  
  

