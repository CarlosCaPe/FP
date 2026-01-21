CREATE VIEW [CLI].[CONOPS_CLI_DAILY_SP_SHOVEL_ASSET_EFFICIENCY_V] AS
  
  
  
--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'  
CREATE VIEW [cli].[CONOPS_CLI_DAILY_SP_SHOVEL_ASSET_EFFICIENCY_V]   
AS  
  
SELECT a.[shiftflag],  
    a.[siteflag],  
	a.shiftid,
    equipment,  
    EQMTTYPE,  
    StatusName,  
    [Hos],  
    [Hr],  
    AVG(AE) [AE],  
    AVG([Avail]) [Avail],  
    AVG([UofA]) [UofA]  
FROM [cli].[CONOPS_CLI_DAILY_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a  
LEFT JOIN [cli].[CONOPS_CLI_DAILY_SHOVEL_INFO_V] b  
ON a.shiftid = b.shiftid AND a.Equipment = b.ShovelID  
WHERE [EqmtUnit] = 2  
GROUP BY a.[shiftflag], a.shiftid,a.[siteflag], [Hos], [Hr], equipment,EQMTTYPE,StatusName  
  
  
  
