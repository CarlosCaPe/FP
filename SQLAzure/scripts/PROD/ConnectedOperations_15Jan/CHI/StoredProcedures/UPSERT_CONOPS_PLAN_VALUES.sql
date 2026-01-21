





/****************************************************************** 
* PROCEDURE : [CHI].[UPSERT_CONOPS_PLAN_VALUES]
* PURPOSE : Upsert [UPSERT_CONOPS_PLAN_VALUES]    
* NOTES:
* CREATED : mfahmi    
* SAMPLE    : EXEC CHI.[UPSERT_CONOPS_PLAN_VALUES]    
* MODIFIED DATE  AUTHOR    DESCRIPTION 
*------------------------------------------------------------------ 
* {01 DEC 2022}  {mfahmi}   {Initial Created} 
* {01 MAR 2023}  {MFAHMI}   {ADD COLUMN SITEFLAG}
* {06 JUN 2023}  {ggosal1}  {Change Structure} 
* {05 DEC 2023}  {GGOSAL1}  {Add: update table monitoring}
* {15 OCT 2024}  {GGOSAL1}  {Adjust new sharepoint format}
*******************************************************************/ 
CREATE  PROCEDURE [chi].[UPSERT_CONOPS_PLAN_VALUES]    
AS    
BEGIN    
    
MERGE CHI.PLAN_VALUES AS T
USING (SELECT   
'CHI' AS SITEFLAG,   
PlanName,
DateEffective,
OreTPD,
ROMTPD,
WasteTPD,
TotalExPitTPD,
TotalMaterialToCrusher,
OreRehandleToCrusherTpd,
EstrellaTPD,
HanoverTPD,
SouthPitTPD,
C_35TPD,
C_12TPD,
C_44TPD,
C_46TPD,
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
PlannedEmptyTravelTimeMin,
PlannedLoadedTravelTimeMin,
PlannedDumpTimeMin,
PlannedWaitTimeMin,
PlannedLoadTimePH2800Min,
PlannedLoadTimePH4100Min,
PlannedSpotTimeMin,
AveragePayload,
TotalCycleTimeMin,
AvgReadyElecShovels,
FeetDrilledDay,
ContentTypeID,
ComplianceAssetId,
ColorTag,
HolesDrilledDay,
DrillAvailability,
DrillUtilization,
DrillAssetEfficiency,
AvgReadyDrills,
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
 FROM CHI.PLAN_VALUES_stg) AS S
 ON (T.Id = S.Id AND T.SITEFLAG = S.SITEFLAG)
    
 WHEN MATCHED
 THEN UPDATE SET
T.PlanName = S.PlanName
,T.DateEffective = S.DateEffective
,T.OreTPD = S.OreTPD
,T.ROMTPD = S.ROMTPD
,T.WasteTPD = S.WasteTPD
,T.TotalExPitTPD = S.TotalExPitTPD
,T.TotalMaterialToCrusher = S.TotalMaterialToCrusher
,T.OreRehandleToCrusherTpd = S.OreRehandleToCrusherTpd
,T.EstrellaTPD = S.EstrellaTPD
,T.HanoverTPD = S.HanoverTPD
,T.SouthPitTPD = S.SouthPitTPD
,T.C_35TPD = S.C_35TPD
,T.C_12TPD = S.C_12TPD
,T.C_44TPD = S.C_44TPD
,T.C_46TPD = S.C_46TPD
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
,T.PlannedEmptyTravelTimeMin = S.PlannedEmptyTravelTimeMin
,T.PlannedLoadedTravelTimeMin = S.PlannedLoadedTravelTimeMin
,T.PlannedDumpTimeMin = S.PlannedDumpTimeMin
,T.PlannedWaitTimeMin = S.PlannedWaitTimeMin
,T.PlannedLoadTimePH2800Min = S.PlannedLoadTimePH2800Min
,T.PlannedLoadTimePH4100Min = S.PlannedLoadTimePH4100Min
,T.PlannedSpotTimeMin = S.PlannedSpotTimeMin
,T.AveragePayload = S.AveragePayload
,T.TotalCycleTimeMin = S.TotalCycleTimeMin
,T.AvgReadyElecShovels = S.AvgReadyElecShovels
,T.FeetDrilledDay = S.FeetDrilledDay
,T.ContentTypeID = S.ContentTypeID
,T.ComplianceAssetId = S.ComplianceAssetId
,T.ColorTag = S.ColorTag
,T.HolesDrilledDay = S.HolesDrilledDay
,T.DrillAvailability = S.DrillAvailability
,T.DrillUtilization = S.DrillUtilization
,T.DrillAssetEfficiency = S.DrillAssetEfficiency
,T.AvgReadyDrills = S.AvgReadyDrills
--,T.Id = S.Id
,T.ContentType = S.ContentType
,T.Modified = S.Modified
,T.Created = S.Created
,T.CreatedById = S.CreatedById
,T.ModifiedById = S.ModifiedById
,T.Owshiddenversion = S.Owshiddenversion
,T.Version = S.Version
,T.Path = S.Path
,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE  
   
 WHEN NOT MATCHED
 THEN INSERT (   
