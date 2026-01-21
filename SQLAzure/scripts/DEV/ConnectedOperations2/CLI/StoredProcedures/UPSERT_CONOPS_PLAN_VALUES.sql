



 
/******************************************************************    
* PROCEDURE : [CLI].[UPSERT_CONOPS_PLAN_VALUES]   
* PURPOSE : Upsert [UPSERT_CONOPS_PLAN_VALUES]  
* NOTES     :   
* CREATED : mfahmi  
* SAMPLE    : EXEC CLI.[UPSERT_CONOPS_PLAN_VALUES]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {01 DEC 2022}  {mfahmi}   {Initial Created}   
* {01 MAR 2023}  {MFAHMI}   {ADD COLUMN SITEFLAG}    
* {05 DEC 2023}  {GGOSAL1}  {Add: update table monitoring}
*******************************************************************/    
CREATE  PROCEDURE [cli].[UPSERT_CONOPS_PLAN_VALUES]  
AS  
BEGIN  
  
MERGE CLI.PLAN_VALUES AS T   
USING (SELECT 
'CMX' AS SITEFLAG, 
CONTENTTYPEID,
ShiftID,
COMPLIANCEASSETID,
PB,
Shovel,
HolesDrilled,
FeetDrilled,
TotalTonsMoved,
TotalTonsMined,
TotalMillOreMined,
MillOreTonsMoved,
TotalTonstoCrusher,
StockpileTons,
WasteTons,
EFH,
ID,
CONTENTTYPE,
MODIFIED,
CREATED,
CREATEDBYID,
MODIFIEDBYID,
OWSHIDDENVERSION,
VERSION,
PATH,
getutcdate() UTC_CREATED_DATE   
 FROM CLI.PLAN_VALUES_stg) AS S   
 ON (T.Id = S.Id AND T.SITEFLAG =  S.SITEFLAG)   
  
 WHEN MATCHED   
 THEN UPDATE SET  
 T.CONTENTTYPEID = S.CONTENTTYPEID
,T.ShiftID = S.ShiftID
,T.COMPLIANCEASSETID = S.COMPLIANCEASSETID
,T.PB = S.PB
,T.Shovel = S.Shovel
,T.HolesDrilled = S.HolesDrilled
,T.FeetDrilled = S.FeetDrilled
,T.TotalTonsMoved = S.TotalTonsMoved
,T.TotalTonsMined = S.TotalTonsMined
,T.TotalMillOreMined = S.TotalMillOreMined
,T.MillOreTonsMoved = S.MillOreTonsMoved
,T.TotalTonstoCrusher = S.TotalTonstoCrusher
,T.StockpileTons = S.StockpileTons
,T.WasteTons = S.WasteTons
,T.EFH = S.EFH
--,T.ID = S.ID
,T.CONTENTTYPE = S.CONTENTTYPE
,T.MODIFIED = S.MODIFIED
,T.CREATED = S.CREATED
,T.CREATEDBYID = S.CREATEDBYID
,T.MODIFIEDBYID = S.MODIFIEDBYID
,T.OWSHIDDENVERSION = S.OWSHIDDENVERSION
,T.VERSION = S.VERSION
,T.PATH = S.PATH
,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE
 
 WHEN NOT MATCHED   
 THEN INSERT ( 
 SITEFLAG,
 CONTENTTYPEID,
ShiftID,
COMPLIANCEASSETID,
PB,
Shovel,
HolesDrilled,
FeetDrilled,
TotalTonsMoved,
TotalTonsMined,
TotalMillOreMined,
MillOreTonsMoved,
TotalTonstoCrusher,
StockpileTons,
WasteTons,
EFH,
ID,
CONTENTTYPE,
MODIFIED,
CREATED,
CREATEDBYID,
MODIFIEDBYID,
OWSHIDDENVERSION,
VERSION,
PATH,
UTC_CREATED_DATE
  ) VALUES(  
  S.SITEFLAG, 
  S.CONTENTTYPEID,
S.ShiftID,
S.COMPLIANCEASSETID,
S.PB,
S.Shovel,
S.HolesDrilled,
S.FeetDrilled,
S.TotalTonsMoved,
S.TotalTonsMined,
S.TotalMillOreMined,
S.MillOreTonsMoved,
S.TotalTonstoCrusher,
S.StockpileTons,
S.WasteTons,
S.EFH,
S.ID,
S.CONTENTTYPE,
S.MODIFIED,
S.CREATED,
S.CREATEDBYID,
S.MODIFIEDBYID,
S.OWSHIDDENVERSION,
S.VERSION,
S.PATH,
S.UTC_CREATED_DATE
 ); 
 
 
  --remove    
DELETE  
FROM  CLI.PLAN_VALUES    
WHERE NOT EXISTS  
(SELECT 1  
FROM  CLI.PLAN_VALUES_STG  AS stg   
WHERE   
stg.Id = CLI.PLAN_VALUES.Id 
);   
  
--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'CLI_SP_To_SQLMI_PlanValues'

END  
  

