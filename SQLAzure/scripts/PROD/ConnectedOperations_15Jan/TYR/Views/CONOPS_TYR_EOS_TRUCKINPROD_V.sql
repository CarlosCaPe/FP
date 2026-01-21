CREATE VIEW [TYR].[CONOPS_TYR_EOS_TRUCKINPROD_V] AS



--select * from [dbo].[CONOPS_TYR_EOS_TRUCKINPROD_V] where shiftflag = 'prev'  
CREATE VIEW [TYR].[CONOPS_TYR_EOS_TRUCKINPROD_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
siteflag,  
shiftflag,  
COUNT(Truckid) TotalTruck  
FROM [tyr].[CONOPS_TYR_TRUCK_DETAIL_V]  
GROUP BY siteflag, shiftflag)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
HOS,  
HR AS [Datetime],  
ROUND((TotalTruck * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS TruckInProd  
FROM [tyr].[CONOPS_TYR_TP_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN CTE b ON a.shiftflag = b.shiftflag 
GROUP BY 
a.siteflag,
a.shiftflag,
HOS,
HR,
TotalTruck
  
  
  

