CREATE VIEW [mor].[CONOPS_MOR_SP_TOTAL_MATERIAL_MINED_V] AS






--select * from [mor].[CONOPS_MOR_SP_TOTAL_MATERIAL_MINED_V] where shiftflag = 'prev' order by shovelid asc
CREATE VIEW [mor].[CONOPS_MOR_SP_TOTAL_MATERIAL_MINED_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
eqmttype,
Operator,
OperatorID,
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
TotalMaterialMoved,
TotalMaterialMovedTarget,
HangTime,
HangTimeTarget,
Availability,
AvailabilityTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SHOVEL_TO_WATCH_V]
WHERE siteflag = 'MOR'





