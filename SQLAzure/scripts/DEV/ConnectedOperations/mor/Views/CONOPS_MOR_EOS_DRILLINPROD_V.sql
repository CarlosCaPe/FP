CREATE VIEW [mor].[CONOPS_MOR_EOS_DRILLINPROD_V] AS


--select * from [dbo].[CONOPS_MOR_EOS_DRILLINPROD_V] where shiftflag = 'prev'
CREATE VIEW [mor].[CONOPS_MOR_EOS_DRILLINPROD_V]
AS


WITH CTE AS (
SELECT 
siteflag,
shiftflag,
COUNT(Drill_ID) TotalDrill
FROM [mor].[CONOPS_MOR_DRILL_DETAIL_V]
GROUP BY siteflag, shiftflag)

SELECT 
a.siteflag,
a.shiftflag,
HOS,
HR AS [Datetime],
ROUND((TotalDrill * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS DrillInProd
FROM [mor].[CONOPS_MOR_HOURLY_DRILL_ASSET_EFFICIENCY_V] a
LEFT JOIN CTE b ON a.shiftflag = b.shiftflag
GROUP BY a.siteflag, a.shiftflag, HOS, HR,TotalDrill


