CREATE VIEW [dbo].[CONOPS_EQMT_SHOVEL_V] AS





-- SELECT * FROM [DBO].[CONOPS_EQMT_SHOVEL_V]
CREATE VIEW [DBO].[CONOPS_EQMT_SHOVEL_V]
AS

SELECT
shiftflag,
siteflag,
shovelid,
[location],
statusname,
reasonid,
reasondesc,
Crew,
TimeInState,
operator,
operatorimageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
payload,
PayloadTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
NumberOfLoads,
Spotting,
SpottingTarget,
Loading,
LoadingTarget,
IdleTime,
IdleTimeTarget,
[Availability],
UseOfAvailability,
AssetEfficiency,
UnderLoaded,
BelowTarget,
OnTarget,
AboveTarget,
OverLoaded,
InvalidPayload
FROM [bag].[CONOPS_BAG_EQMT_SHOVEL_V]
WHERE siteflag = 'BAG'


UNION ALL


SELECT
shiftflag,
siteflag,
shovelid,
[location],
statusname,
reasonid,
reasondesc,
Crew,
TimeInState,
operator,
operatorimageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
payload,
PayloadTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
NumberOfLoads,
Spotting,
SpottingTarget,
Loading,
LoadingTarget,
IdleTime,
IdleTimeTarget,
[Availability],
UseOfAvailability,
AssetEfficiency,
UnderLoaded,
BelowTarget,
OnTarget,
AboveTarget,
OverLoaded,
InvalidPayload
FROM [mor].[CONOPS_MOR_EQMT_SHOVEL_V]
WHERE siteflag = 'MOR'


UNION ALL


SELECT
shiftflag,
siteflag,
shovelid,
[location],
statusname,
reasonid,
reasondesc,
Crew,
TimeInState,
operator,
operatorimageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
payload,
PayloadTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
NumberOfLoads,
Spotting,
SpottingTarget,
Loading,
LoadingTarget,
IdleTime,
IdleTimeTarget,
[Availability],
UseOfAvailability,
AssetEfficiency,
UnderLoaded,
BelowTarget,
OnTarget,
AboveTarget,
OverLoaded,
InvalidPayload
FROM [cli].[CONOPS_CLI_EQMT_SHOVEL_V]
WHERE siteflag = 'CMX'


UNION ALL


SELECT
shiftflag,
siteflag,
shovelid,
[location],
statusname,
reasonid,
reasondesc,
Crew,
TimeInState,
operator,
operatorimageURL,
TotalMaterialMined,
TotalMaterialMinedTarget,
payload,
PayloadTarget,
TonsPerReadyHour,
TonsPerReadyHourTarget,
NumberOfLoads,
Spotting,
SpottingTarget,
Loading,
LoadingTarget,
IdleTime,
IdleTimeTarget,
[Availability],
UseOfAvailability,
AssetEfficiency,
UnderLoaded,
BelowTarget,
OnTarget,
AboveTarget,
OverLoaded,
InvalidPayload
FROM [sie].[CONOPS_SIE_EQMT_SHOVEL_V]
WHERE siteflag = 'SIE'


