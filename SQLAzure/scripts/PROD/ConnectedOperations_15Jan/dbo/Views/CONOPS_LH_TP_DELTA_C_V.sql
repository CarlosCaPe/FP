CREATE VIEW [dbo].[CONOPS_LH_TP_DELTA_C_V] AS


CREATE VIEW [dbo].[CONOPS_LH_TP_DELTA_C_V]
AS

SELECT 
shiftflag,
siteflag,
shiftid,
truck,
toper,
OperatorImageURL,
AVG_Payload,
AVG_PayloadTarget,
deltac,
Delta_c_target,
EFH,
EFHtarget,
idletime,
idletimetarget,
spottime,
spottarget,
loadtime,
loadtarget,
DumpingTime,
dumpingtarget,
DumpingAtStockpile,
dumpingatStockpileTarget,
DumpingAtCrusher,
dumpingAtCrusherTarget,
useOfAvailability,
useOfAvailabilityTarget,
TotalMaterialDelivered,
TotalMaterialDeliveredTarget,
[destination],
Pit,
reasonidx,
reasons,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_TP_DELTA_C_V]
WHERE siteflag = 'MOR'


UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
truck,
toper,
OperatorImageURL,
AVG_Payload,
AVG_PayloadTarget,
deltac,
Delta_c_target,
EFH,
EFHtarget,
idletime,
idletimetarget,
spottime,
spottarget,
loadtime,
loadtarget,
DumpingTime,
dumpingtarget,
DumpingAtStockpile,
dumpingatStockpileTarget,
DumpingAtCrusher,
dumpingAtCrusherTarget,
useOfAvailability,
useOfAvailabilityTarget,
TotalMaterialDelivered,
TotalMaterialDeliveredTarget,
[destination],
Pit,
reasonidx,
reasons,
eqmtcurrstatus
FROM [bag].[CONOPS_BAG_TP_DELTA_C_V]
WHERE siteflag = 'BAG'



