CREATE VIEW [TYR].[CONOPS_TYR_DAILY_EOS_DRILLINPROD_V] AS

  
  
  
--select * from [dbo].[CONOPS_TYR_DAILY_EOS_DRILLINPROD_V] where shiftflag = 'prev'  
CREATE VIEW [tyr].[CONOPS_TYR_DAILY_EOS_DRILLINPROD_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
siteflag,  
shiftflag,  
shiftid,
COUNT(Drill_ID) TotalDrill  
FROM [tyr].[CONOPS_TYR_DAILY_DRILL_DETAIL_V]  
GROUP BY siteflag, shiftflag,shiftid)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
a.shiftid,
HOS,  
HR AS [Datetime],  
ROUND((TotalDrill * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS DrillInProd  
FROM [tyr].[CONOPS_TYR_DAILY_HOURLY_DRILL_ASSET_EFFICIENCY_V] a  
LEFT JOIN CTE b ON a.shiftid = b.shiftid  
WHERE HOS IS NOT NULL
GROUP BY a.siteflag, a.shiftid,a.shiftflag, HOS, HR,TotalDrill  
  
  
  
