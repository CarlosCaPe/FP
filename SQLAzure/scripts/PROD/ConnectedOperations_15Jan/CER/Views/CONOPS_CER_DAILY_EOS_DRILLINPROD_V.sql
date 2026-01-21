CREATE VIEW [CER].[CONOPS_CER_DAILY_EOS_DRILLINPROD_V] AS
  
  
  
--select * from [dbo].[CONOPS_CER_DAILY_EOS_DRILLINPROD_V] where shiftflag = 'prev'  
CREATE VIEW [cer].[CONOPS_CER_DAILY_EOS_DRILLINPROD_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
siteflag,  
shiftflag,  
shiftid,
COUNT(Drill_ID) TotalDrill  
FROM [cer].[CONOPS_CER_DAILY_DRILL_DETAIL_V]  
GROUP BY siteflag, shiftflag,shiftid)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
a.shiftid,
HOS,  
HR AS [Datetime],  
ROUND((TotalDrill * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS DrillInProd  
FROM [cer].[CONOPS_CER_DAILY_HOURLY_DRILL_ASSET_EFFICIENCY_V] a  
LEFT JOIN CTE b ON a.shiftid = b.shiftid  
WHERE HOS IS NOT NULL
GROUP BY a.siteflag, a.shiftflag, a.shiftid,HOS, HR,TotalDrill  
  
  
  
