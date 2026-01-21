CREATE VIEW [CLI].[CONOPS_CLI_SP_NROFLOAD_V] AS
  
  
  
--SELECT * FROM [cli].[CONOPS_CLI_SP_NROFLOAD_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cli].[CONOPS_CLI_SP_NROFLOAD_V]  
AS  
  
  
WITH STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [CLI].[asset_efficiency] (NOLOCK)  
where unittype = 'shovel')  
  
  
SELECT   
shiftflag,  
siteflag,  
a.shiftid,  
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
ReasonIdx,  
reasons,  
eqmtcurrstatus  
FROM [cli].[CONOPS_CLI_SHOVEL_POPUP] a WITH (NOLOCK)
LEFT JOIN STAT b ON a.shiftid = b.shiftid AND a.ShovelID = b.eqmt ANd b.num = 1  
  
WHERE a.shiftflag is not null  
  
  
  
  
  
  
  
