CREATE VIEW [sie].[CONOPS_SIE_DAILY_SP_SHOVEL_ASSET_EFFICIENCY_V] AS
  
  
  
--select * from [sie].[CONOPS_SIE_DAILY_SP_SHOVEL_ASSET_EFFICIENCY_V] where shiftflag = 'prev'  
CREATE VIEW [sie].[CONOPS_SIE_DAILY_SP_SHOVEL_ASSET_EFFICIENCY_V]   
AS  
  
SELECT a.[shiftflag],  
    a.[siteflag], 
	a.shiftid,
    equipment,  
    eqmttype,  
    statusname,  
    [Hos],  
    [Hr],  
    AVG(AE) [AE],  
    AVG([Avail]) [Avail],  
    AVG([UofA]) [UofA]  
FROM [sie].[CONOPS_SIE_DAILY_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN [sie].[CONOPS_SIE_DAILY_SHOVEL_INFO_V] b  
ON a.shiftid = b.shiftid AND a.Equipment = b.ShovelID  
WHERE [EqmtUnit] = 2  
GROUP BY a.[shiftflag], a.shiftid,a.[siteflag], [Hos], [Hr], equipment, eqmttype, statusname  
  
  
  
