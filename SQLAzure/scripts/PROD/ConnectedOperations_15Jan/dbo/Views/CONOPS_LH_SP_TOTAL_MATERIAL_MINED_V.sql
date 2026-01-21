CREATE VIEW [dbo].[CONOPS_LH_SP_TOTAL_MATERIAL_MINED_V] AS


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



