CREATE VIEW [dbo].[CONOPS_LH_SP_AVG_LOAD_TIME_V] AS





--SELECT * FROM [dbo].[CONOPS_LH_SP_AVG_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'
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
FROM [saf].[CONOPS_SAF_SP_AVG_LOAD_TIME_V]
WHERE siteflag = 'SAF'


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
FROM [sie].[CONOPS_SIE_SP_AVG_LOAD_TIME_V]
WHERE siteflag = 'SIE'


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
FROM [cli].[CONOPS_CLI_SP_AVG_LOAD_TIME_V]
WHERE siteflag = 'CMX'

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
FROM [chi].[CONOPS_CHI_SP_AVG_LOAD_TIME_V]
WHERE siteflag = 'CHI'


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
r