CREATE VIEW [sie].[CONOPS_SIE_TP_TRUCK_ASSET_EFFICIENCY_V] AS
  
  
  
--select * from [sie].[CONOPS_SIE_TP_TRUCK_ASSET_EFFICIENCY_V] where shiftflag = 'prev'  
CREATE VIEW [sie].[CONOPS_SIE_TP_TRUCK_ASSET_EFFICIENCY_V]   
AS  
  
SELECT a.[shiftflag],  
    a.[siteflag],  
    a.Equipment,  
    b.eqmttype,  
    b.StatusName,  
    [Hos],  
    [Hr],  
    AVG(AE) [AE],  
    AVG([Avail]) [Avail],  
    AVG([UofA]) [UofA]  
FROM [sie].[CONOPS_SIE_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a   
LEFT JOIN [sie].CONOPS_SIE_TRUCK_POPUP b WITH (NOLOCK) 
ON a.shiftflag = b.shiftflag AND a.Equipment = b.TruckID  
WHERE [EqmtUnit] = 1  
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr], a.Equipment,b.eqmttype,b.StatusName  
  
  
  
  
