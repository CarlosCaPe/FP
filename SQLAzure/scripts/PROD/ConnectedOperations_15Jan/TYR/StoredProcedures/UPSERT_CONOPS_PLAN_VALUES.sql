



  
/******************************************************************    
* PROCEDURE : [TYR].[UPSERT_CONOPS_PLAN_VALUES]   
* PURPOSE : Upsert [UPSERT_CONOPS_PLAN_VALUES]  
* NOTES     :   
* Created : ggosal1  
* SAMPLE    : EXEC TYR.[UPSERT_CONOPS_PLAN_VALUES]  
* Modified DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {30 MAY 2024}  {ggosal1}  {Initial Created}    
*******************************************************************/    
CREATE  PROCEDURE [TYR].[UPSERT_CONOPS_PLAN_VALUES]  
AS  
BEGIN  
  
MERGE TYR.PLAN_VALUES AS T   
USING (SELECT 
'TYR' AS SITEFLAG,
CASE WHEN Shift = 1 
THEN CONCAT(FORMAT(CONVERT(DATETIME,(LEFT(Title, CHARINDEX(' ', Title) - 1))),'yyMMdd'), '001')
ELSE CONCAT(FORMAT(CONVERT(DATETIME,(LEFT(Title, CHARINDEX(' ', Title) - 1))),'yyMMdd'), '002')
END AS FormatShiftId,
ContentTypeID,
Title,
ColorTag,
ComplianceAssetID,
Date,
Shift,
MiningRateWaste,
MiningRateROM,
TruckPayloadTons,
LoadingUnit,
DeltaCMins,
IdleTimeMin,
SpotTimeMin,
LoadTimeMin,
DumpTimeMin,
OutTravelMins,
InTravelMins,
EFH,
Id,
ContentType,
Modified,
Created,
CreatedById,
ModifiedById,
OwshiddenVersion,
Version,
Path,
getutcdate() UTC_CREATED_DATE   
 FROM TYR.PLAN_VALUES_stg) AS S   
 ON (T.Id = S.Id AND T.SITEFLAG = S.SITEFLAG)   
  
 WHEN MATCHED   
 THEN UPDATE SET  
 T.FormatShiftId = S.FormatShiftId
,T.ContentTypeID = S.ContentTypeID
,T.Title = S.Title
,T.ColorTag = S.ColorTag
,T.ComplianceAssetID = S.ComplianceAssetID
,T.Date = S.Date
,T.Shift = S.Shift
,T.MiningRateWaste = S.MiningRateWaste
,T.MiningRateROM = S.MiningRateROM
,T.TruckPayloadTons = S.TruckPayloadTons
,T.LoadingUnit = S.LoadingUnit
,T.DeltaCMins = S.DeltaCMins
,T.IdleTimeMin = S.IdleTimeMin
,T.SpotTimeMin = S.SpotTimeMin
,T.LoadTimeMin = S.LoadTimeMin
,T.DumpTimeMin = S.DumpTimeMin
,T.OutTravelMins = S.OutTravelMins
,T.InTravelMins = S.InTravelMins
,T.EFH = S.EFH
--,T.ID = S.ID
,T.ContentType = S.ContentType
,T.Modified = S.Modified
,T.Created = S.Created
,T.CreatedById = S.CreatedById
,T.ModifiedById = S.ModifiedById
,T.OwshiddenVersion = S.OwshiddenVersion
,T.Version = S.Version
,T.Path = S.Path
,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE
 
 WHEN NOT MATCHED   
 THEN INSERT ( 
SITEFLAG,
FormatShiftId,
ContentTypeID,
Title,
ColorTag,
ComplianceAssetID,
Date,
Shift,
MiningRateWaste,
MiningRateROM,
TruckPayloadTons,
LoadingUnit,
DeltaCMins,
IdleTimeMin,
SpotTimeMin,
LoadTimeMin,
DumpTimeMin,
OutTravelMins,
InTravelMins,
EFH,
ID,
ContentType,
Modified,
Created,
CreatedById,
ModifiedById,
OwshiddenVersion,
Version,
Path,
UTC_CREATED_DATE
  ) VALUES( 
S.SITEFLAG,  
S.FormatShiftId,
S.ContentTypeID,
S.Title,
S.ColorTag,
S.ComplianceAssetID,
S.Date,
S.Shift,
S.MiningRateWaste,
S.MiningRateROM,
S.TruckPayloadTons,
S.LoadingUnit,
S.DeltaCMins,
S.IdleTimeMin,
S.SpotTimeMin,
S.LoadTimeMin,
S.DumpTimeMin,
S.OutTravelMins,
S.InTravelMins,
S.EFH,
S.ID,
S.ContentType,
S.Modified,
S.Created,
S.CreatedById,
S.ModifiedById,
S.OwshiddenVersion,
S.Version,
S.Path,
S.UTC_CREATED_DATE
 ); 
 
 
  --remove    
DELETE  
FROM  TYR.PLAN_VALUES    
WHERE NOT EXISTS  
(SELECT 1  
FROM  TYR.PLAN_VALUES_STG  AS stg   
WHERE   
stg.Id = TYR.PLAN_VALUES.Id 

);   

--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'TYR_SP_To_SQLMI_PlanValues'
   
END  
  


