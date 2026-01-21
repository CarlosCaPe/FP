CREATE VIEW [TYR].[CONOPS_TYR_DAILY_EOS_TRUCKINPROD_V] AS

  
    
    
    
--select * from [dbo].[CONOPS_TYR_DAILY_EOS_TRUCKINPROD_V] where shiftflag = 'prev'    
CREATE VIEW [tyr].[CONOPS_TYR_DAILY_EOS_TRUCKINPROD_V]    
AS    
    
    
WITH CTE AS (    
SELECT     
siteflag,    
shiftflag, 
shiftid,
COUNT(Truckid) TotalTruck    
FROM [tyr].[CONOPS_TYR_DAILY_TRUCK_DETAIL_V]    
GROUP BY siteflag, shiftflag,shiftid)    
    
SELECT     
a.siteflag,    
a.shiftflag,  
a.shiftid,
HOS,    
HR AS [Datetime],    
ROUND((TotalTruck * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS TruckInProd    
FROM [tyr].[CONOPS_TYR_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V] a    
LEFT JOIN CTE b ON a.shiftid = b.shiftid   
GROUP BY   
a.siteflag,  
a.shiftflag,  
a.shiftid,
HOS,  
HR,  
TotalTruck  
    
    
    
  
