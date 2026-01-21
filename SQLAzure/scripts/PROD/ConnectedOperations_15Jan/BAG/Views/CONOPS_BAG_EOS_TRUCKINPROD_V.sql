CREATE VIEW [BAG].[CONOPS_BAG_EOS_TRUCKINPROD_V] AS

  
  
  
--select * from [dbo].[CONOPS_BAG_EOS_TRUCKINPROD_V] where shiftflag = 'prev'  
CREATE VIEW [bag].[CONOPS_BAG_EOS_TRUCKINPROD_V]  
AS  
  
WITH CTE AS (  
SELECT   
siteflag,  
shiftflag,  
COUNT(Truckid) TotalTruck  
FROM [bag].[CONOPS_BAG_TRUCK_DETAIL_V]  
GROUP BY siteflag, shiftflag)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
HOS,  
HR AS [Datetime], 
ROUND((TotalTruck * ((AVG(Avail)/100.00) * (AVG(UofA)/100.00))),0) AS TruckInProd  
FROM [bag].[CONOPS_BAG_TP_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN CTE b ON a.shiftflag = b.shiftflag  
GROUP BY 
a.siteflag,
a.shiftflag,
HOS,
HR,
TotalTruck
  
  
  

