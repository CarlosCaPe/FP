CREATE VIEW [Arch].[CONOPS_ARCH_SP_WORST_LOAD_TIME_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_SP_WORST_LOAD_TIME_V]
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
FROM [Arch].[CONOPS_ARCH_SP_DELTA_C_V] 
WHERE siteflag = '<SITECODE>'
AND Loading > LoadingTarget


