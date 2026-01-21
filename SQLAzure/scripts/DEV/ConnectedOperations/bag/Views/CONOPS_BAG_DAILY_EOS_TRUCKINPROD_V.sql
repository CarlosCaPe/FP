CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_TRUCKINPROD_V] AS

  
    
    
    
--select * from [dbo].[CONOPS_BAG_DAILY_EOS_TRUCKINPROD_V] where shiftflag = 'prev'    
CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_TRUCKINPROD_V]    
AS    
    
    
WITH CTE AS (    
SELECT     
siteflag,    
shiftflag,    
shiftid,
COUNT(Truckid) TotalTruck    
FROM [bag].[CONOPS_BAG_DAILY_TRUCK_DETAIL_V]    
GROUP BY siteflag, shiftflag,shiftid)    
    
SELECT     
a.siteflag,    
a.shiftflag,  
a.shiftid,
HOS,    
HR AS [Datetime],    
ROUND((TotalTruck * ((AVG(Avail)/100.00) * (AVG(UofA)/100.00))),0) AS TruckInProd    
FROM [bag].[CONOPS_BAG_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V] a    
LEFT JOIN CTE b ON a.shiftid = b.shiftid    
GROUP BY   
a.siteflag,  
a.shiftflag,  
a.shiftid,
HOS,  
HR,  
TotalTruck  
    
    
    
  

