CREATE VIEW [dbo].[CONOPS_LH_SP_TOTAL_MATERIAL_MINED_V] AS







--select * from [dbo].[CONOPS_LH_SP_TOTAL_MATERIAL_MINED_V] where shiftflag = 'prev' order by shovelid asc
CREATE VIEW [dbo].[CONOPS_LH_SP_TOTAL_MATERIAL_MINED_V]
AS

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
Operator,
OperatorImageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
OffTarget,
deltac,
DeltaCTarget,
idletime,
idletimetarget,
spotting,
SpottingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
payload,
payloadTarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SP_TOTAL_MATERIAL_MINED_V]
WHERE siteflag = 'MOR'


UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
Operator,
OperatorImageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
OffTarget,
deltac,
DeltaCTarget,
idletime,
idletimetarget,
spotting,
SpottingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
payload,
payloadTarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [bag].[CONOPS_BAG_SP_TOTAL_MATERIAL_MINED_V]
WHERE siteflag = 'BAG'

UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
Operator,
OperatorImageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
OffTarget,
deltac,
DeltaCTarget,
idletime,
idletimetarget,
spotting,
SpottingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
payload,
payloadTarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [saf].[CONOPS_SAF_SP_TOTAL_MATERIAL_MINED_V]
WHERE siteflag = 'SAF'


UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
Operator,
OperatorImageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
OffTarget,
deltac,
DeltaCTarget,
idletime,
idletimetarget,
spotting,
SpottingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
payload,
payloadTarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [sie].[CONOPS_SIE_SP_TOTAL_MATERIAL_MINED_V]
WHERE siteflag = 'SIE'


UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
Operator,
OperatorImageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
OffTarget,
deltac,
DeltaCTarget,
idletime,
idletimetarget,
spotting,
SpottingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
payload,
payloadTarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [cli].[CONOPS_CLI_SP_TOTAL_MATERIAL_MINED_V]
WHERE siteflag = 'CMX'

UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
Operator,
OperatorImageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
OffTarget,
deltac,
DeltaCTarget,
idletime,
idletimetarget,
spotting,
SpottingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
payload,
payloadTarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [chi].[CONOPS_CHI_SP_TOTAL_MATERIAL_MINED_V]
WHERE siteflag = 'CHI'


UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
Operator,
OperatorImageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
OffTarget,
deltac,
DeltaCTarget,
idletime,
idletimetarget,
spotting,
SpottingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
payload,
payloadTarget,
NumberOfLoads,
NumberOfLoadsTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
AssetEffi