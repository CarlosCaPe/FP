CREATE VIEW [ABR].[CONOPS_ABR_DAILY_SP_SHOVEL_ASSET_EFFICIENCY_V] AS

  
  
  
--select * from [abr].[CONOPS_ABR_DAILY_SP_SHOVEL_ASSET_EFFICIENCY_V]   WITH (NOLOCK)  
CREATE VIEW [abr].[CONOPS_ABR_DAILY_SP_SHOVEL_ASSET_EFFICIENCY_V]  
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
FROM [abr].[CONOPS_ABR_DAILY_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN [abr].[CONOPS_ABR_DAILY_SHOVEL_INFO_V] b  
ON a.shiftid = b.shiftid AND a.Equipment = b.ShovelID  
WHERE [EqmtUnit] = 2  
GROUP BY a.[shiftflag], a.shiftid,a.[siteflag], [Hos], [Hr],equipment,eqmttype,statusname  
  
  
  
  
