CREATE VIEW [chi].[CONOPS_CHI_SP_NROFLOAD_V] AS
  
 
--SELECT * FROM [chi].[CONOPS_CHI_SP_NROFLOAD_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [chi].[CONOPS_CHI_SP_NROFLOAD_V]  
AS  
  
WITH STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [CHI].[asset_efficiency] (NOLOCK)  
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
FROM [chi].[CONOPS_CHI_SHOVEL_POPUP] a WITH (NOLOCK)
LEFT JOIN STAT b on a.shiftid = b.shiftid AND a.ShovelID = b.eqmt AND b.num = 1  
  
  
  
  
  
  
  
  
