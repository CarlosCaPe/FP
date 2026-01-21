CREATE VIEW [ABR].[CONOPS_ABR_OEE_V] AS


  
  
  
  
--select * from [abr].[CONOPS_ABR_OEE_V]  
  
CREATE VIEW [ABR].[CONOPS_ABR_OEE_V]  
AS  
  
SELECT   
[shift].shiftflag,  
[shift].siteflag,  
[shift].shiftid,  
shiftoee.OEE  
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] [shift] (NOLOCK)  
LEFT JOIN (  
  
SELECT  
a.shiftid,  
a.SITE_CODE,  
a.AssetEfficiency * ((a.CycleTimeWeighted - a.DeltaCWeighted) / a.CycleTimeWeighted) * a.PayLoadActual / a.PayLoadOptimal AS OEE  
FROM  
(  
SELECT  
oee.SHIFTID,  
oee.SITE_CODE,  
SUM(oee.ReadyTime)/SUM(oee.TotalTime) AS AssetEfficiency,  
SUM(oee.DeltaC * oee.CycleCount) / SUM(oee.CycleCount) AS DeltaCWeighted,  
SUM(oee.TotalCycleTime * oee.CycleCount) / SUM(oee.CycleCount) AS CycleTimeWeighted,  
SUM(oee.ShovelLoadCount * 267) + SUM(oee.LoaderLoadCount * 240) AS PayLoadActual,  
SUM(oee.ShovelLoadCount + oee.LoaderLoadCount) * 260 AS PayLoadOptimal  
FROM (  
SELECT  
SITE_CODE,  
SHIFTINDEX,  
concat(concat(right(replace(SHIFTDATE,'-',''),6),'00'),[SHIFT]) as SHIFTID,  
READYTIME,  
TOTALTIME,  
SHOVELLOADCOUNT,  
LOADERLOADCOUNT,  
TOTALCYCLETIME,  
DELTAC,  
EQMT,  
HOS,  
CYCLECOUNT  
FROM dbo.oee (nolock)  
WHERE SITE_CODE = 'ELA') oee  
GROUP BY oee.SHIFTID,oee.SITE_CODE) a) shiftoee  
ON [shift].shiftid = shiftoee.shiftid  
AND [shift].siteflag = shiftoee.SITE_CODE  
  

  
  
  

