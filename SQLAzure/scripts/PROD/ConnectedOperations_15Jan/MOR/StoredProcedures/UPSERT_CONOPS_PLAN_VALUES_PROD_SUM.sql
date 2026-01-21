




  
  
  
/******************************************************************    
* PROCEDURE : [mor].[UPSERT_CONOPS_PLAN_VALUES_PROD_SUM]   
* PURPOSE : Upsert [UPSERT_CONOPS_PLAN_VALUES_PROD_SUM]  
* NOTES     :   
* CREATED : mfahmi  
* SAMPLE    : EXEC mor.[UPSERT_CONOPS_PLAN_VALUES_PROD_SUM] 
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {01 DEC 2022}  {mfahmi}   {Initial Created}    
* {03 JAN 2023}  {mfahmi}   {Enhancement takeout script remove}  
* {01 MAR 2023}  {MFAHMI}   {ADD COLUMN SITEFLAG}   
* {24 MAR 2023}  {MFAHMI}   {Replaced PK ID to planname}   
* {27 JUL 2023}  {ggosal1}  {PitFBKtpd --> PitPONtpd}
* {05 DEC 2023}  {GGOSAL1}  {Add: update table monitoring}
*******************************************************************/    
CREATE  PROCEDURE [mor].[UPSERT_CONOPS_PLAN_VALUES_PROD_SUM]  
AS  
BEGIN  
  
MERGE mor.PLAN_VALUES_PROD_SUM AS T   
USING (SELECT   
'MOR' AS SITEFLAG, 
ContentTypeID,
PlanName,
ComplianceAssetId,
DateEffective,
TotalOretpd,
TotalAC23tpd,
TotalAC4tpd,
TotalEHtpd,
TotalHGtpd,
TotalLGtpd,
TotalOxidetpd,
TotalROMtpd,
TotalWastetpd,
TotalExPittpd,
TransferOreMFL,
TransferOreMill,
TotalInpitDump,
TotalMinedtpd,
TotalMovedtpd,
CrusherMFLtpd,
CrusherMilltpd,
[910tpd],
PitAMTtpd,
PitCORtpd,
PitPONtpd,
PitGARtpd,
PitLONtpd,
PitSHAtpd,
PitSUNtpd,
PitWCPtpd,
PitWCP14tpd,
PitWCP10tpd,
LoadingAvailability,
LoadingAssetEfficiency,
TruckAvailability,
TruckAssetEfficiency,
AvgCountReadyTrucks,
EquivalentFlatHaul,
EmptyEFH,
EmptyTravelMiles,
LoadedTravelMiles,
TotalCycleTime,
DeltaC,
ElecShovelLoadTonsOnReadyHour,
ElecShovelAvailability,
ElecShovelAssetEfficiency,
ElecShovelUseOfAvailability,
ElecShovelAvgReadyNumber,
HydShovelLoadTonsOnReadyHour,
HydShovelAvailability,
HydShovelAssetEfficiency,
HydShovelUseOfAvailability,
HydShovelAvgReadyNumber,
EmptyOneWayHaul,
EmptyLifts,
EmptyDrops,
Spoting,
Loading,
LoadedTravel,
DumpingAtCrusher,
DumpingatStockpile,
EmptyTravel,
EFH_GAR,
EFH_SUN,
EFH_WCP,
Crrrr,
TrkDumpTnReadyHr,
WCPDeltaC,
SUNDeltaC,
GARDeltaC,
TotalLoadTnsReadyHr,
TotalDumpTnsReadyHr,
TruckUtil,
FuelBurnGal,
FuelBurnHr,
TireMiles,
FrontTireRot,
RockCut_prctg,
Miles_32nd,
MTBME,
Haulage$_ton,
Fuel$_ton,
MTTR,
OverExpectedDeltaC_prctg,
Loaded_prctg,
Empty_prctg,
ReadyDrills,
DrillHolesperDay,
DeltaCLoadedTravel,
DeltaCEmptyTravel,
DeltaCDumpCr,
DeltaCDumpStk,
AMTTons,
P10Tons,
P14Tons,
CORTons,
Id,
ContentType,
Modified,
Created,
CreatedById,
ModifiedById,
Owshiddenversion,
Version,
Path,
getutcdate() UTC_CREATED_DATE   
 FROM mor.PLAN_VALUES_PROD_SUM_stg) AS S   
 ON (T.PlanName = S.PlanName AND T.SITEFLAG = S.SITEFLAG)   
  
 WHEN MATCHED   
 THEN UPDATE SET   
T.ContentTypeID = S.ContentTypeID
,T.Id = S.Id
,T.ComplianceAssetId = S.ComplianceAssetId
,T.DateEffective = S.DateEffective
,T.TotalOretpd = S.TotalOretpd
,T.TotalAC23tpd = S.TotalAC23tpd
,T.TotalAC4tpd = S.TotalAC4tpd
,T.TotalEHtpd = S.TotalEHtpd
,T.TotalHGtpd = S.TotalHGtpd
,T.TotalLGtpd = S.TotalLGtpd
,T.TotalOxidetpd = S.TotalOxidetpd
,T.TotalROMtpd = S.TotalROMtpd
,T.TotalWastetpd = S.TotalWastetpd
,T.TotalExPittpd = S.TotalExPittpd
,T.TransferOreMFL = S.TransferOreMFL
,T.TransferOreMill = S.TransferOreMill
,T.TotalInpitDump = S.TotalInpitDump
,T.TotalMinedtpd = S.TotalMinedtpd
,T.TotalMovedtpd = S.TotalMovedtpd
,T.CrusherMFLtpd = S.CrusherMFLtpd
,T.CrusherMilltpd = S.CrusherMilltpd
,T.[910tpd] = S.[910tpd]
,T.PitAMTtpd = S.PitAMTtpd
,T.PitCORtpd = S.PitCORtpd
,T.PitPONtpd = S.PitPONtpd
,T.PitGARtpd = S.PitGARtpd
,T.PitLONtpd = S.PitLONtpd
,T.PitSHAtpd = S.PitSHAtpd
,T.PitSUNtpd = S.PitSUNtpd
,T.PitWCPtpd = S.PitWCPtpd
,T.PitWCP14tpd = S.PitWCP14tpd
,T.PitWCP10tpd = S.PitWCP10tpd
,T.LoadingAvailability = S.LoadingAvailability
,T.LoadingAssetEfficiency = S.LoadingAssetEfficiency
,T.