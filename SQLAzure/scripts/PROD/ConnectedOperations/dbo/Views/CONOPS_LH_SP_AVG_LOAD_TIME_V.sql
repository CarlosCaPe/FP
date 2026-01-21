CREATE VIEW [dbo].[CONOPS_LH_SP_AVG_LOAD_TIME_V] AS



CREATE VIEW [dbo].[CONOPS_LH_SP_AVG_LOAD_TIME_V]
AS

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
excav,
payload,
payloadTarget,
LoadTime,
LoadTimeTarget,
LoadTimeShiftTarget,
operatorname,
operatorid,
shovelactual,
shoveltarget,
delta_c,
deltac_target,
idletime,
idletimetarget,
spotting,
SpotingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
EFH,
EFHtarget,
NrofLoad,
ShovelNrofLoadTarget,
AssetEfficiency,
AssetEfficiencyTarget,
TPRH,
TPRHTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SP_AVG_LOAD_TIME_V]
WHERE siteflag = 'MOR'


UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
excav,
payload,
payloadTarget,
LoadTime,
LoadTimeTarget,
LoadTimeShiftTarget,
operatorname,
operatorid,
shovelactual,
shoveltarget,
delta_c,
deltac_target,
idletime,
idletimetarget,
spotting,
SpotingTarget,
loading,
LoadingTarget,
dumping,
dumpingtarget,
EFH,
EFHtarget,
NrofLoad,
ShovelNrofLoadTarget,
AssetEfficiency,
AssetEfficiencyTarget,
TPRH,
TPRHTarget,
reasonidx,
reasons,
eqmtcurrstatus
FROM [bag].[CONOPS_BAG_SP_AVG_LOAD_TIME_V]
WHERE siteflag = 'BAG'


