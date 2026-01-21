CREATE VIEW [dbo].[CONOPS_LH_SP_DELTA_C_V] AS


CREATE VIEW [dbo].[CONOPS_LH_SP_DELTA_C_V]
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
FROM [mor].[CONOPS_MOR_SP_DELTA_C_V]
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
FROM [bag].[CONOPS_BAG_SP_DELTA_C_V]
WHERE siteflag = 'BAG'



