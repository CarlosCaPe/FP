


/******************************************************************      
* PROCEDURE : [CHI].[UPSERT_CONOPS_PLAN_VALUES]     
* PURPOSE : Upsert [UPSERT_CONOPS_PLAN_VALUES]    
* NOTES     :     
* CREATED : mfahmi    
* SAMPLE    : EXEC CHI.[UPSERT_CONOPS_PLAN_VALUES]    
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {01 DEC 2022}  {mfahmi}   {Initial Created}      
* {01 MAR 2023}  {MFAHMI}   {ADD COLUMN SITEFLAG}     
*******************************************************************/      
CREATE  PROCEDURE [chi].[UPSERT_CONOPS_PLAN_VALUES_OLD]    
AS    
BEGIN    
    
MERGE CHI.PLAN_VALUES AS T     
USING (SELECT   
'CHI' AS SITEFLAG,   
CONTENTTYPEID,  
ID,  
COMPLIANCEASSETID,  
PlanName,  
DateEffective,  
OreTPD,  
LTMillSTKTPD,  
HGLeachTPD,  
LGLeachTPD,  
ROM_OXTPD,  
WasteTPD,  
TotalExPitTPD,  
TotalInPitTPD,  
TotalMaterialtoCrusher,  
OreRehandletoCrusherTPD,  
RehandleWasteTPD,  
RehandleOxideTPD,  
LeeHillTPD,  
EstrellaTPD,  
HanoverTPD,  
SouthPitTPD,  
[994LDRTPD],  
[35TPD],  
[43TPD],  
[44TPD],  
[45TPD],  
[46TPD],  
ElectricShovelTonsReadyHour,  
ElectricShovelAvailability,  
ElectricShovelUofA,  
ElectricShovelAssetEfficiency,  
TruckAvailability,  
TruckUofA,  
TruckAssetEfficiency,  
AvgReadyTrucks,  
PlannedTruckFleet,  
DeltaC,  
EFH,  
PlannedEmptyTravelTime,  
PlannedLoadedTravelTime,  
PlannedDumpTimeSEC,  
PlannedWaitTimeSEC,  
PlannedLoadTimePH2800MIN,  
PlannedLoadTimePH4100MIN,  
PlannedSpotTimeSEC,  
PlannedAvgShiftchangeTrucks,  
PlannedAvgOpDelayTrucks,  
PlannedAvgSchDownTrucks,  
OreEFH,  
ROMEFH,  
LGLEFH,  
ROM_OXEFH,  
WasteEFH,  
[793TonnageFactor],  
TotalCycleTimeMIN,  
AvgReadyElecShovels,  
FeetDrilledDay,  
HolesDrilledDay,  
DrillAvailability,  
DrillUtilization,  
DrillAssetEfficiency,  
AvgReadyDrills,  
CONTENTTYPE,  
MODIFIED,  
CREATED,  
CREATEDBYID,  
MODIFIEDBYID,  
OWSHIDDENVERSION,  
VERSION,  
PATH,  
getutcdate() UTC_CREATED_DATE     
 FROM CHI.PLAN_VALUES_stg) AS S     
 ON (T.Id = S.Id AND T.SITEFLAG = S.SITEFLAG)     
    
 WHEN MATCHED     
 THEN UPDATE SET    
T.CONTENTTYPEID = S.CONTENTTYPEID  
--,T.ID = S.ID  
,T.COMPLIANCEASSETID = S.COMPLIANCEASSETID  
,T.PlanName = S.PlanName  
,T.DateEffective = S.DateEffective  
,T.OreTPD = S.OreTPD  
,T.LTMillSTKTPD = S.LTMillSTKTPD  
,T.HGLeachTPD = S.HGLeachTPD  
,T.LGLeachTPD = S.LGLeachTPD  
,T.ROM_OXTPD = S.ROM_OXTPD  
,T.WasteTPD = S.WasteTPD  
,T.TotalExPitTPD = S.TotalExPitTPD  
,T.TotalInPitTPD = S.TotalInPitTPD  
,T.TotalMaterialtoCrusher = S.TotalMaterialtoCrusher  
,T.OreRehandletoCrusherTPD = S.OreRehandletoCrusherTPD  
,T.RehandleWasteTPD = S.RehandleWasteTPD  
,T.RehandleOxideTPD = S.RehandleOxideTPD  
,T.LeeHillTPD = S.LeeHillTPD  
,T.EstrellaTPD = S.EstrellaTPD  
,T.HanoverTPD = S.HanoverTPD  
,T.SouthPitTPD = S.SouthPitTPD  
,T.[994LDRTPD] = S.[994LDRTPD]  
,T.[35TPD] = S.[35TPD]  
,T.[43TPD] = S.[43TPD]  
,T.[44TPD] = S.[44TPD]  
,T.[45TPD] = S.[45TPD]  
,T.[46TPD] = S.[46TPD]  
,T.ElectricShovelTonsReadyHour = S.ElectricShovelTonsReadyHour  
,T.ElectricShovelAvailability = S.ElectricShovelAvailability  
,T.ElectricShovelUofA = S.ElectricShovelUofA  
,T.ElectricShovelAssetEfficiency = S.ElectricShovelAssetEfficiency  
,T.TruckAvailability = S.TruckAvailability  
,T.TruckUofA = S.TruckUofA  
,T.TruckAssetEfficiency = S.TruckAssetEfficiency  
,T.AvgReadyTrucks = S.AvgReadyTrucks  
,T.PlannedTruckFleet = S.PlannedTruckFleet  
,T.DeltaC = S.DeltaC  
,T.EFH = S.EFH  
,T.PlannedEmptyTravelTime = S.PlannedEmptyTravelTime  
,T.PlannedLoadedTravelTime = S.PlannedLoadedTravelTime  
,T.PlannedDumpTimeSEC = S.PlannedDumpTimeSEC  
,T.PlannedWaitTimeSEC = S.PlannedWaitTimeSEC  
,T.PlannedLoadTimePH2800MIN = S.PlannedLoadTimePH2800MIN  
,T.PlannedLoadTimePH4100MIN = S.PlannedLoadTimePH4100MIN  
