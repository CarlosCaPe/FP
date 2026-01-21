CREATE VIEW [sie].[CONOPS_SIE_DAILY_EOS_TRUCKINPROD_V] AS
  
    
    
    
--select * from [dbo].[CONOPS_SIE_DAILY_EOS_TRUCKINPROD_V] where shiftflag = 'prev'    
CREATE VIEW [sie].[CONOPS_SIE_DAILY_EOS_TRUCKINPROD_V]    
AS    
    
    
WITH CTE AS (    
SELECT     
siteflag,    
shiftflag,    
shiftid,
COUNT(Truckid) TotalTruck    
FROM [sie].[CONOPS_SIE_DAILY_TRUCK_DETAIL_V]    
GROUP BY siteflag, shiftflag,shiftid)    
    
SELECT     
a.siteflag,    
a.shiftflag,    
a.shiftid,
HOS,    
HR AS [Datetime],    
ROUND((TotalTruck * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS TruckInProd    
FROM [sie].[CONOPS_SIE_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V] a    
LEFT JOIN CTE b ON a.shiftid = b.shiftid   
GROUP BY   
a.siteflag,  
a.shiftflag,  
a.shiftid,
HOS,  
HR,  
TotalTruck  

    
    
  
