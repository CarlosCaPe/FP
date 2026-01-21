CREATE VIEW [MOR].[CONOPS_MOR_TP_TRUCK_ASSET_EFFICIENCY_V] AS
  
  
  
--select * from [dbo].[CONOPS_LH_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)  
CREATE VIEW [mor].[CONOPS_MOR_TP_TRUCK_ASSET_EFFICIENCY_V]   
AS  
  
SELECT a.[shiftflag],  
    a.[siteflag],  
    Equipment,  
    eqmttype,  
    StatusName,  
    [Hos],  
    [Hr],  
    AVG(AE) [AE],  
    AVG([Avail]) [Avail],  
    AVG([UofA]) [UofA]  
FROM [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN [mor].CONOPS_MOR_TRUCK_POPUP b WITH (NOLOCK) 
ON a.shiftflag = b.shiftflag AND a.Equipment = b.TruckID  
WHERE [EqmtUnit] = 1  
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr], Equipment,eqmttype,StatusName  
  
  
  
