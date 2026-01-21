CREATE VIEW [bag].[CONOPS_BAG_SP_WORST_LOAD_TIME_V] AS




--SELECT * FROM [bag].[CONOPS_BAG_SP_WORST_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_SP_WORST_LOAD_TIME_V]
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
FROM [bag].[CONOPS_BAG_SP_DELTA_C_V] 
WHERE siteflag = 'BAG'
AND Loading > LoadingTarget




