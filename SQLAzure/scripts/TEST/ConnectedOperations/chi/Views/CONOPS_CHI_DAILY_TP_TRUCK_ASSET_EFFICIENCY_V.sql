CREATE VIEW [chi].[CONOPS_CHI_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V] AS
  
  
  
  
--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'  
CREATE VIEW [chi].[CONOPS_CHI_DAILY_TP_TRUCK_ASSET_EFFICIENCY_V]   
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
FROM [chi].[CONOPS_CHI_DAILY_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN [chi].CONOPS_CHI_DAILY_TRUCK_POPUP_V b  
ON a.shiftid = b.shiftid AND a.Equipment = b.TruckID  
WHERE [EqmtUnit] = 1  
AND Equipment NOT IN ('897','898')  
GROUP BY a.[shiftflag], a.shiftid, a.[siteflag], [Hos], [Hr], Equipment,eqmttype,StatusName  
  
  
  
