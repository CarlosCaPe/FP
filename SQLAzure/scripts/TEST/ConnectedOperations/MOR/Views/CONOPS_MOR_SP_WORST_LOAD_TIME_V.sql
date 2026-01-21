CREATE VIEW [MOR].[CONOPS_MOR_SP_WORST_LOAD_TIME_V] AS








--SELECT * FROM [mor].[CONOPS_MOR_SP_WORST_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [mor].[CONOPS_MOR_SP_WORST_LOAD_TIME_V]
AS


SELECT 
shiftflag,
siteflag,
shiftid,
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
EFH,
EFHTarget,
ReasonIdx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SP_DELTA_C_V] 
WHERE siteflag = 'MOR'
AND Loading > LoadingTarget





