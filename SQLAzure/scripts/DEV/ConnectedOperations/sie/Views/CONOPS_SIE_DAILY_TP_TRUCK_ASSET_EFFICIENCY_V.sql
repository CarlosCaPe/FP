CREATE VIEW [sie].[CONOPS_SIE_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V] AS
  
  
  
--select * from [sie].[CONOPS_SIE_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V] where shiftflag = 'prev'  
CREATE VIEW [sie].[CONOPS_SIE_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V]   
AS  
  
SELECT a.[shiftflag],  
    a.[siteflag],  
	a.shiftid,
    a.Equipment,  
    b.eqmttype,  
    b.StatusName,  
    [Hos],  
    [Hr],  
    AVG(AE) [AE],  
    AVG([Avail]) [Avail],  
    AVG([UofA]) [UofA]  
FROM [sie].[CONOPS_SIE_DAILY_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a   
LEFT JOIN [sie].CONOPS_SIE_DAILY_TRUCK_POPUP_V b  
ON a.shiftid = b.shiftid AND a.Equipment = b.TruckID  
WHERE [EqmtUnit] = 1  
GROUP BY a.[shiftflag], a.shiftid, a.[siteflag], [Hos], [Hr], a.Equipment,b.eqmttype,b.StatusName  

  
  
  
