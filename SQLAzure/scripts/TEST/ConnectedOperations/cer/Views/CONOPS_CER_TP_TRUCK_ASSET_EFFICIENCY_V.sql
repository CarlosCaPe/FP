CREATE VIEW [cer].[CONOPS_CER_TP_TRUCK_ASSET_EFFICIENCY_V] AS
  
  
  
--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'  
CREATE VIEW [cer].[CONOPS_CER_TP_TRUCK_ASSET_EFFICIENCY_V]   
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
FROM [cer].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN [cer].CONOPS_CER_TRUCK_POPUP b WITH (NOLOCK) 
ON a.shiftflag = b.shiftflag AND a.Equipment = b.TruckID  
WHERE [EqmtUnit] = 1  
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr], Equipment,eqmttype,StatusName  
  
  
  
  
