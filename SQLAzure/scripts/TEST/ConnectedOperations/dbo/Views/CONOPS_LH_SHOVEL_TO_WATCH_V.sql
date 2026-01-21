CREATE VIEW [dbo].[CONOPS_LH_SHOVEL_TO_WATCH_V] AS





--select * from [dbo].[CONOPS_LH_SHOVEL_TO_WATCH_V] where shiftflag = 'curr'
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
FROM [saf].[CONOPS_SAF_SHOVEL_TO_WATCH_V] (NOLOCK)
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
reasons
FROM [cli].[CONOPS_CLI_SHOVEL_TO_WATCH_V] (NOLOCK)
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
reasons
FROM [chi].[CONOPS_CHI_SHOVEL_TO_WATCH_V] (NOLOCK)
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
AssetEfficiency,
AssetEfficiencyTarget,
reasonidx,
reasons
FROM [cer].[CONOPS_CER_SHOVEL_TO_WATCH_V] (NOLOCK)
WHERE siteflag = 'CER'


