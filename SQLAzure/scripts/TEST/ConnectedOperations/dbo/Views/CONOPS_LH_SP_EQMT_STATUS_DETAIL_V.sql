CREATE VIEW [dbo].[CONOPS_LH_SP_EQMT_STATUS_DETAIL_V] AS




--SELECT * from [dbo].[CONOPS_LH_SP_EQMT_STATUS_DETAIL_V]

CREATE VIEW [dbo].[CONOPS_LH_SP_EQMT_STATUS_DETAIL_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
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
EFH,
EFHtarget,
payload,
payloadtarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SP_DELTA_C_V]
WHERE siteflag = 'MOR'


UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
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
EFH,
EFHtarget,
payload,
payloadtarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [bag].[CONOPS_BAG_SP_DELTA_C_V]
WHERE siteflag = 'BAG'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
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
EFH,
EFHtarget,
payload,
payloadtarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [saf].[CONOPS_SAF_SP_DELTA_C_V]
WHERE siteflag = 'SAF'



UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
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
EFH,
EFHtarget,
payload,
payloadtarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [sie].[CONOPS_SIE_SP_DELTA_C_V]
WHERE siteflag = 'SIE'


UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
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
EFH,
EFHtarget,
payload,
payloadtarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [cli].[CONOPS_CLI_SP_DELTA_C_V]
WHERE siteflag = 'CMX'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
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
EFH,
EFHtarget,
payload,
payloadtarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [chi].[CONOPS_CHI_SP_DELTA_C_V]
WHERE siteflag = 'CHI'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
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
EFH,
EFHtarget,
payload,
payloadtarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [cer].[CONOPS_CER_SP_DELTA_C_V]
WHERE siteflag = 'CER'
