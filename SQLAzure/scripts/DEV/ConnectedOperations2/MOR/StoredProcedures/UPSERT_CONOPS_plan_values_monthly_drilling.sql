

  
  
  
    
    
/******************************************************************      
* PROCEDURE : [mor].[UPSERT_CONOPS_plan_values_monthly_drilling]     
* PURPOSE : Upsert [UPSERT_CONOPS_plan_values_monthly_drilling]    
* NOTES     :     
* CREATED : mfahmi    
* SAMPLE    : EXEC mor.[UPSERT_CONOPS_plan_values_monthly_drilling]    
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {03 MAR 2023}  {mfahmi}   {Initial Created}
* {05 DEC 2023}  {GGOSAL1}  {Add: update table monitoring}
*******************************************************************/      
CREATE  PROCEDURE [mor].[UPSERT_CONOPS_plan_values_monthly_drilling]    
AS    
BEGIN    
    
MERGE mor.plan_values_monthly_drilling AS T     
USING (SELECT   
'MOR' AS SITEFLAG,    
ContentTypeID,  
Title,  
ComplianceAssetId,  
EffectiveDate,
PlannedHoles,
PenRate,  
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
 FROM mor.plan_values_monthly_drilling_stg) AS S     
 ON (T.Id = S.Id AND T.SITEFLAG = S.SITEFLAG)     
    
 WHEN MATCHED     
 THEN UPDATE SET     
 T.ContentTypeID = S.ContentTypeID  
,T.Title = S.Title  
,T.ComplianceAssetId = S.ComplianceAssetId  
,T.EffectiveDate = S.EffectiveDate  
,T.PlannedHoles = S.PlannedHoles  
,T.PenRate = S.PenRate 
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
 SITEFLAG,  
 ContentTypeID,  
Title,  
ComplianceAssetId,  
EffectiveDate,  
PlannedHoles,  
PenRate,   
Id,  
ContentType,  
Modified,  
Created,  
CreatedById,  
ModifiedById,  
Owshiddenversion,  
Version,  
Path,   
UTC_CREATED_DATE  
  ) VALUES(     
  S.SITEFLAG,  
  S.ContentTypeID,  
S.Title,  
S.ComplianceAssetId,  
S.EffectiveDate,  
S.PlannedHoles,  
S.PenRate,  
S.Id,  
S.ContentType,  
S.Modified,  
S.Created,  
S.CreatedById,  
S.ModifiedById,  
S.Owshiddenversion,  
S.Version,  
S.Path,   
S.UTC_CREATED_DATE    
 );   
   
   
  --remove      
DELETE    
FROM  mor.plan_values_monthly_drilling      
WHERE NOT EXISTS    
(SELECT 1    
FROM  mor.plan_values_monthly_drilling_STG  AS stg     
WHERE     
stg.Id = mor.plan_values_monthly_drilling.Id   
);     
     
--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'MOR_SP_To_SQLMI_PlanValuesDrill'     
     
END    
    
  
  

