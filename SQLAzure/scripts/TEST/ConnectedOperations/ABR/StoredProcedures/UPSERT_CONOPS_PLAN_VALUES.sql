


  
/******************************************************************    
* PROCEDURE : [ABR].[UPSERT_CONOPS_PLAN_VALUES]   
* PURPOSE : Upsert [UPSERT_CONOPS_PLAN_VALUES]  
* NOTES     :   
* Created : ggosal1  
* SAMPLE    : EXEC ABR.[UPSERT_CONOPS_PLAN_VALUES]  
* Modified DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {18 APR 2024}  {ggosal1}  {Initial Created}    
*******************************************************************/    
CREATE  PROCEDURE [ABR].[UPSERT_CONOPS_PLAN_VALUES]  
AS  
BEGIN  
  
MERGE ABR.PLAN_VALUES AS T   
USING (SELECT 
'ABR' AS SITEFLAG,
CASE WHEN RIGHT(ShiftID,1) = 1 
THEN CONCAT(RIGHT(REPLACE(CAST(LEFT(ShiftID, LEN(ShiftID) - CHARINDEX('-', REVERSE(ShiftID))) AS DATE),'-',''),6),'001')
ELSE CONCAT(RIGHT(REPLACE(CAST(LEFT(ShiftID, LEN(ShiftID) - CHARINDEX('-', REVERSE(ShiftID))) AS DATE),'-',''),6),'002')
END AS FormatShiftId,
ContentTypeID,
ColorTag,
ShiftID,
ComplianceAssetID,
Pala,
Destino,
Tons,
CuT,
QLT,
CuRC,
CuRR,
SCKM,
SClay,
Trucks,
Trucks_Hours,
DFS,
UDF,
AEF,
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
 FROM ABR.PLAN_VALUES_stg) AS S   
 ON (T.Id = S.Id AND T.SITEFLAG = S.SITEFLAG)   
  
 WHEN MATCHED   
 THEN UPDATE SET  
 T.FormatShiftId = S.FormatShiftId
,T.ContentTypeID = S.ContentTypeID
,T.ColorTag = S.ColorTag
,T.ShiftID = S.ShiftID
,T.ComplianceAssetID = S.ComplianceAssetID
,T.Pala = S.Pala
,T.Destino = S.Destino
,T.Tons = S.Tons
,T.CuT = S.CuT
,T.QLT = S.QLT
,T.CuRC = S.CuRC
,T.CuRR = S.CuRR
,T.SCKM = S.SCKM
,T.SClay = S.SClay
,T.Trucks = S.Trucks
,T.Trucks_Hours = S.Trucks_Hours
,T.DFS = S.DFS
,T.UDF = S.UDF
,T.AEF = S.AEF
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
ColorTag,
ShiftID,
ComplianceAssetID,
Pala,
Destino,
Tons,
CuT,
QLT,
CuRC,
CuRR,
SCKM,
SClay,
Trucks,
Trucks_Hours,
DFS,
UDF,
AEF,
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
S.ColorTag,
S.ShiftID,
S.ComplianceAssetID,
S.Pala,
S.Destino,
S.Tons,
S.CuT,
S.QLT,
S.CuRC,
S.CuRR,
S.SCKM,
S.SClay,
S.Trucks,
S.Trucks_Hours,
S.DFS,
S.UDF,
S.AEF,
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
FROM  ABR.PLAN_VALUES    
WHERE NOT EXISTS  
(SELECT 1  
FROM  ABR.PLAN_VALUES_STG  AS stg   
WHERE   
stg.Id = ABR.PLAN_VALUES.Id 

);   

--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'ABR_SP_To_SQLMI_PlanValues'
   
END  
  



