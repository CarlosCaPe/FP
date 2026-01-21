CREATE VIEW [TYR].[CONOPS_TYR_SP_TOTAL_MATERIAL_MINED_V] AS


--select * from [tyr].[CONOPS_TYR_SP_TOTAL_MATERIAL_MINED_V] where shiftflag = 'prev' order by shovelid asc
CREATE VIEW [TYR].[CONOPS_TYR_SP_TOTAL_MATERIAL_MINED_V]
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
FROM [tyr].[CONOPS_TYR_SHOVEL_TO_WATCH_V]







