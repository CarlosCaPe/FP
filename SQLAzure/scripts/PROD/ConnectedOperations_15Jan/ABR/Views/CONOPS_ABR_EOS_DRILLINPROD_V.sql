CREATE VIEW [ABR].[CONOPS_ABR_EOS_DRILLINPROD_V] AS





--select * from [abr].[CONOPS_ABR_EOS_DRILLINPROD_V] where shiftflag = 'prev'
CREATE VIEW [ABR].[CONOPS_ABR_EOS_DRILLINPROD_V]
AS


WITH CTE AS (
SELECT 
siteflag,
shiftflag,
COUNT(Drill_ID) TotalDrill
FROM [abr].[CONOPS_ABR_DRILL_DETAIL_V]
GROUP BY siteflag, shiftflag)

SELECT 
a.siteflag,
a.shiftflag,
HOS,
HR AS [Datetime],
ROUND((TotalDrill * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS DrillInProd
FROM [abr].[CONOPS_ABR_HOURLY_DRILL_ASSET_EFFICIENCY_V] a
LEFT JOIN CTE b ON a.shiftflag = b.shiftflag
GROUP BY a.siteflag, a.shiftflag, HOS, HR,TotalDrill



