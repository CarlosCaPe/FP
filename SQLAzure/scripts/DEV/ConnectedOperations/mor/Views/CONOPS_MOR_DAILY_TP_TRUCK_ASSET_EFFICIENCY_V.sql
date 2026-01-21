CREATE VIEW [mor].[CONOPS_MOR_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V] AS
  
  
  
--select * from [dbo].[CONOPS_LH_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)  
CREATE VIEW [mor].[CONOPS_MOR_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V]   
AS  
  
SELECT a.[shiftflag],  
    a.[siteflag],  
	a.shiftid,
    Equipment,  
    eqmttype,  
    StatusName,  
    [Hos],  
    [Hr],  
    AVG(AE) [AE],  
    AVG([Avail]) [Avail],  
    AVG([UofA]) [UofA]  
FROM [mor].[CONOPS_MOR_DAILY_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN [mor].CONOPS_MOR_DAILY_TRUCK_POPUP_V b  
ON a.shiftid = b.shiftid AND a.Equipment = b.TruckID  
WHERE [EqmtUnit] = 1  
GROUP BY a.[shiftflag], a.shiftid, a.[siteflag], [Hos], [Hr], Equipment,eqmttype,StatusName  
  
  
  
