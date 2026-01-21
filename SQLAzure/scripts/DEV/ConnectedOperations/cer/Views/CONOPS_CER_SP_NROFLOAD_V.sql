CREATE VIEW [cer].[CONOPS_CER_SP_NROFLOAD_V] AS
  
 
--SELECT * FROM [cer].[CONOPS_CER_SP_NROFLOAD_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_SP_NROFLOAD_V]  
AS  
  
WITH STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [CER].[asset_efficiency] (NOLOCK)  
where unittype = 'Pala')  
  
  
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
FROM [cer].[CONOPS_CER_SHOVEL_POPUP] a WITH (NOLOCK)
LEFT JOIN stat b ON a.shiftid = b.shiftid AND a.ShovelID = b.eqmt ANd b.num = 1  
  
  
  
  
  
  
  
  
