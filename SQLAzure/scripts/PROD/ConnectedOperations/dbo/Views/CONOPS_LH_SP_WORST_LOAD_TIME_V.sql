CREATE VIEW [dbo].[CONOPS_LH_SP_WORST_LOAD_TIME_V] AS


CREATE VIEW [dbo].[CONOPS_LH_SP_WORST_LOAD_TIME_V]
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
EFH,
EFHTarget,
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SP_WORST_LOAD_TIME_V]
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
EFH,
EFHTarget,
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [bag].[CONOPS_BAG_SP_WORST_LOAD_TIME_V]
WHERE siteflag = 'BAG'



