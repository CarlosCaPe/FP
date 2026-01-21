CREATE VIEW [Arch].[CONOPS_LH_SP_TOTAL_MATERIAL_MINED_V] AS
CREATE   VIEW [Arch].[CONOPS_LH_SP_TOTAL_MATERIAL_MINED_V]
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
FROM [Arch].[CONOPS_ARCH_SP_TOTAL_MATERIAL_MINED_V]
