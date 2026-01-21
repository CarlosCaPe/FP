CREATE VIEW [dbo].[CONOPS_LH_SHOVEL_TO_WATCH_V] AS


CREATE VIEW [dbo].[CONOPS_LH_SHOVEL_TO_WATCH_V]
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
reasons
FROM [mor].[CONOPS_MOR_SHOVEL_TO_WATCH_V] (NOLOCK)
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
reasons
FROM [bag].[CONOPS_BAG_SHOVEL_TO_WATCH_V] (NOLOCK)
WHERE siteflag = 'BAG'

