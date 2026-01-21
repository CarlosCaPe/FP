CREATE VIEW [cer].[CONOPS_CER_SP_WORST_LOAD_TIME_V] AS







--SELECT * FROM [cer].[CONOPS_CER_SP_WORST_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [cer].[CONOPS_CER_SP_WORST_LOAD_TIME_V]
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
FROM [cer].[CONOPS_CER_SP_DELTA_C_V]
WHERE siteflag = 'CER'
    AND Loading > LoadingTarget
	AND shovelid NOT LIKE 'CF%'




