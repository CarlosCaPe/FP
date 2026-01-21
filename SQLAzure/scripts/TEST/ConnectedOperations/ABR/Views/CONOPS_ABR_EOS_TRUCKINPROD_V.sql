CREATE VIEW [ABR].[CONOPS_ABR_EOS_TRUCKINPROD_V] AS


--select * from [abr].[CONOPS_ABR_EOS_TRUCKINPROD_V] where shiftflag = 'prev'  
CREATE VIEW [ABR].[CONOPS_ABR_EOS_TRUCKINPROD_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
siteflag,  
shiftflag,  
COUNT(Truckid) TotalTruck  
FROM [abr].[CONOPS_ABR_TRUCK_DETAIL_V]  
GROUP BY siteflag, shiftflag)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
HOS,  
HR AS [Datetime],  
ROUND((TotalTruck * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS TruckInProd  
FROM [abr].[CONOPS_ABR_TP_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN CTE b ON a.shiftflag = b.shiftflag 
GROUP BY 
a.siteflag,
a.shiftflag,
HOS,
HR,
TotalTruck
  
  
  
