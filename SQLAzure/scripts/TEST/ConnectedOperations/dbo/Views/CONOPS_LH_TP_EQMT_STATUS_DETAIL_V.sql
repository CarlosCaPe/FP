CREATE VIEW [dbo].[CONOPS_LH_TP_EQMT_STATUS_DETAIL_V] AS








--select * from [dbo].[CONOPS_LH_TP_EQMT_STATUS_DETAIL_V] where shiftflag = 'prev' 
CREATE VIEW [dbo].[CONOPS_LH_TP_EQMT_STATUS_DETAIL_V]
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
reasonidx,
reasons,
eqmtcurrstatus
FROM [bag].[CONOPS_BAG_TP_DELTA_C_V]
WHERE siteflag = 'BAG'

UNION ALL

SELECT shiftflag,
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
       reasonidx,
       reasons,
       eqmtcurrstatus
FROM [saf].[CONOPS_SAF_TP_DELTA_C_V]
WHERE siteflag = 'SAF'



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
reasonidx,
reasons,
eqmtcurrstatus
FROM [sie].[CONOPS_SIE_TP_DELTA_C_V]
WHERE siteflag = 'SIE'


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
reasonidx,
reasons,
eqmtcurrstatus
FROM [cli].[CONOPS_CLI_TP_DELTA_C_V]
WHERE siteflag = 'CMX'

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
reasonidx,
reasons,
eqmtcurrstatus
FROM [chi].[CONOPS_CHI_TP_DELTA_C_V]
WHERE siteflag = 'CHI'


UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
truck,
toper,
OperatorImageURL,
AVG_Payload,