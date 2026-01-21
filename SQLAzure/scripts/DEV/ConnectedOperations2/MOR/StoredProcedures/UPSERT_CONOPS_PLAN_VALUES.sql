





  
  
/******************************************************************    
* PROCEDURE : [mor].[UPSERT_CONOPS_PLAN_VALUES]   
* PURPOSE : Upsert [UPSERT_CONOPS_PLAN_VALUES]  
* NOTES     :   
* CREATED : mfahmi  
* SAMPLE    : EXEC mor.[UPSERT_CONOPS_PLAN_VALUES]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {01 DEC 2022}  {mfahmi}   {Initial Created}   
* {01 MAR 2023}  {MFAHMI}   {ADD COLUMN SITEFLAG}   
* {03 MAY 2023}  {ggosal1}  {Remove Level, DTCU, Mo, EFH column}
* {05 DEC 2023}  {GGOSAL1}  {Add: update table monitoring}
*******************************************************************/    
CREATE  PROCEDURE [mor].[UPSERT_CONOPS_PLAN_VALUES]  
AS  
BEGIN  
  
MERGE mor.PLAN_VALUES AS T   
USING (SELECT 
'MOR' AS SITEFLAG, 
case when right(shiftid,1) = 1 THEN concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'001')
ELSE concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'002')
END AS Formatshiftid,  
ContentTypeID,
ShiftID,
ComplianceAssetId,
Shovel,
PB,
Destination,
MaterialType,
Tons,
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
 FROM mor.PLAN_VALUES_stg) AS S   
 ON (T.Id = S.Id AND T.SITEFLAG = S.SITEFLAG)   
  
 WHEN MATCHED   
 THEN UPDATE SET  
 T.Formatshiftid = S.Formatshiftid 
,T.ContentTypeID = S.ContentTypeID
,T.ShiftID = S.ShiftID
,T.ComplianceAssetId = S.ComplianceAssetId
,T.Shovel = S.Shovel
,T.PB = S.PB
,T.Destination = S.Destination
,T.MaterialType = S.MaterialType
,T.Tons = S.Tons
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
 Formatshiftid,  
 ContentTypeID,
ShiftID,
ComplianceAssetId,
Shovel,
PB,
Destination,
MaterialType,
Tons,
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
  S.Formatshiftid,
  S.ContentTypeID,
S.ShiftID,
S.ComplianceAssetId,
S.Shovel,
S.PB,
S.Destination,
S.MaterialType,
S.Tons,
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
FROM  mor.PLAN_VALUES    
WHERE NOT EXISTS  
(SELECT 1  
FROM  mor.PLAN_VALUES_STG  AS stg   
WHERE   
stg.Id = mor.PLAN_VALUES.Id 
);   
   
--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'MOR_SP_To_SQLMI_PlanValues'  
   
END  
  



