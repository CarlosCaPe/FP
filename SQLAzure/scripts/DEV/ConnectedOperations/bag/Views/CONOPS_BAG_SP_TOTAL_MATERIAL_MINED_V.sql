CREATE VIEW [bag].[CONOPS_BAG_SP_TOTAL_MATERIAL_MINED_V] AS






--select * from [bag].[CONOPS_BAG_SP_TOTAL_MATERIAL_MINED_V] where shiftflag = 'prev' order by shovelid asc
CREATE VIEW [bag].[CONOPS_BAG_SP_TOTAL_MATERIAL_MINED_V]
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
FROM [bag].[CONOPS_BAG_SHOVEL_TO_WATCH_V]
WHERE siteflag = 'BAG'





