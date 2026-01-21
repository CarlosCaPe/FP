CREATE VIEW [dbo].[CONOPS_LH_SP_NROFLOAD_V] AS








--SELECT * FROM [dbo].[CONOPS_LH_SP_NROFLOAD_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [dbo].[CONOPS_LH_SP_NROFLOAD_V]
AS

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShovelID,
Operator,
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
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SP_NROFLOAD_V]
WHERE siteflag = 'MOR'

UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShovelID,
Operator,
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
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [bag].[CONOPS_BAG_SP_NROFLOAD_V]
WHERE siteflag = 'BAG'

UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShovelID,
Operator,
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
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [saf].[CONOPS_SAF_SP_NROFLOAD_V]
WHERE siteflag = 'SAF'


UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShovelID,
Operator,
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
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [sie].[CONOPS_SIE_SP_NROFLOAD_V]
WHERE siteflag = 'SIE'


UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShovelID,
Operator,
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
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [cli].[CONOPS_CLI_SP_NROFLOAD_V]
WHERE siteflag = 'CMX'

UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShovelID,
Operator,
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
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [chi].[CONOPS_CHI_SP_NROFLOAD_V]
WHERE siteflag = 'CHI'


UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
ShovelID,
Operator,
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
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [cer].[CONOPS_CER_SP_NROFLOAD_V]
WHERE siteflag = 'CER'

