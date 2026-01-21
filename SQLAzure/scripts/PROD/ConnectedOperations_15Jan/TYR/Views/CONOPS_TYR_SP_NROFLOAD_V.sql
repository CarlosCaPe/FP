CREATE VIEW [TYR].[CONOPS_TYR_SP_NROFLOAD_V] AS



--SELECT * FROM [TYR].[CONOPS_TYR_SP_NROFLOAD_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [TYR].[CONOPS_TYR_SP_NROFLOAD_V]  
AS  
  
 
WITH STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [TYR].[asset_efficiency] (NOLOCK)  
where unittype = 'Shovel')
  
  
SELECT   
shiftflag,  
siteflag,  
pop.shiftid,  
shiftindex,  
ShovelID,  
eqmttype,  
Operator,  
OperatorID,  
OperatorImageURL,  
TotalMaterialMined,  
TotalMaterialMinedTarget,  
deltaC,  
DeltaCTarget,  
IdleTime,  
IdleTimeTarget,  
Spotting,  
SpottingTarget,  
Loading,  
LoadingTarget,  
Dumping,  
DumpingTarget,  
Payload,  
PayloadTarget,  
NumberOfLoads,  
NumberOfLoadsTarget,  
TonsPerReadyHour,  
TonsPerReadyHourTarget,  
AssetEfficiency,  
AssetEfficiencyTarget,  
TotalMaterialMoved,  
TotalMaterialMovedTarget,  
HangTime,  
HangTimeTarget,   
ReasonId AS ReasonIdx,  
ReasonDesc AS reasons,  
eqmtcurrstatus  
FROM [TYR].[CONOPS_TYR_SHOVEL_POPUP] pop WITH (NOLOCK) 
LEFT JOIN STAT ON stat.shiftid = pop.shiftid AND stat.eqmt = pop.ShovelID AND stat.num = 1  
WHERE siteflag = 'TYR'  
  
  
  
  
  
  
  


