
  
  
  
    
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_SHIFT_LOAD]    
* PURPOSE : UPSERT [UPSERT_CONOPS_SHIFT_LOAD]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_SHIFT_LOAD]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
* {22 FEB 2023}  {MFAHMI}   {Enhancement the logic to add delete of records}   
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}
*******************************************************************/      
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_LOAD]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN  
DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END
EXEC     
(    
'MERGE ' +@G_SITE+ '.SHIFT_LOAD AS T '    
+' USING (SELECT '  
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG' 
+' ,DBPREVIOUS'     
+' ,DBNEXT'     
+' ,DBVERSION'     
+' ,SHIFTID'     
+' ,ID'     
+' ,DBNAME'     
+' ,DBKEY'     
+' ,FIELDID'     
+' ,FIELDTRUCK'     
+' ,FIELDEXCAV'     
+' ,FIELDGRADE'     
+' ,FIELDLOC'     
+' ,FIELDDUMPREC'     
+' ,FIELDTONS'     
+' ,FIELDTIMEARRIVE'     
+' ,FIELDTIMELOAD'     
+' ,FIELDTIMEFULL'     
+' ,FIELDCALCTRAVTIME'     
+' ,FIELDLOAD'     
+' ,FIELDEXTRALOAD'     
+' ,FIELDLOADTYPE'     
+' ,FIELDDIST'     
+' ,FIELDEFH'     
+' ,FIELDTOPER'     
+' ,FIELDEOPER'     
+' ,FIELDORIGASN'     
+' ,FIELDREASNBY'     
+' ,FIELDPATHTRAVTIME'     
+' ,FIELDEXPTRAVELTIME'     
+' ,FIELDEXPTRAVELDIST'     
+' ,FIELDGPSTRAVELDIST'     
+' ,FIELDLOCACTLC'     
+' ,FIELDLOCACTTP'     
+' ,FIELDLOCACTRL'     
+' ,FIELDFIRSTDIPPER'     
+' ,FIELDLASTDIPPER'     
+' ,FIELDBKTCNT'     
+' ,FIELDPANDHBUCKETLOADS'     
+' ,FIELDAUDIT'     
+' ,FIELDWEIGHTST'     
+' ,FIELDWEIGHTMEAS'     
+' ,FIELDMEASURETIME'     
+' ,FIELDGPSXTKL'     
+' ,FIELDGPSYTKL'     
+' ,FIELDGPSXEX'     
+' ,FIELDGPSYEX'     
+' ,FIELDGPSSTATEX'     
+' ,FIELDGPSSTATTK'     
+' ,FIELDGPSHEADTK'     
+' ,FIELDGPSVELTK'     
+' ,FIELDPVS3ID'     
+' ,FIELDBKTSUM'     
+' ,FIELDDUMPASN'     
+' ,FIELDLSIZETONS'     
+' ,FIELDLSIZEID'     
+' ,FIELDLSIZEVERSION'     
+' ,FIELDLSIZEDB'     
+' ,FIELDFUELREMAIN'     
+' ,FIELDFACTAPPLY'     
+' ,FIELDDLOCK'     
+' ,FIELDELOCK'     
+' ,FIELDEDLOCK'     
+' ,FIELDRLOCK'     
+' ,FIELDRECONSTAT'     
+' ,FIELDTIMEARRIVEMOBILE'     
+' ,FIELDTIMELOADMOBILE'     
+' ,FIELDTIMEFULLMOBILE'     
+' ,FIELDSHVBKTCNT'     
+' ,FIELDSHVFIRSTBKT'     
+' ,FIELDSHVLASTBKT'     
+' ,UTC_CREATED_DATE '     
+' ,UTC_LOGICAL_DELETED_DATE'     
+' FROM ' +@G_SITE+ '.SHIFT_LOAD_STG'    
+' WHERE CHANGE_TYPE IN (''U'',''I'')) AS S '    
 +' ON (T.ID = S.ID AND T.SITEFLAG = S.SITEFLAG) '     
+' WHEN MATCHED '     
+' THEN UPDATE SET '     
+' T.DBPREVIOUS = S.DBPREVIOUS'     
+' ,T.DBNEXT = S.DBNEXT'     
+' ,T.DBVERSION = S.DBVERSION'     
+' ,T.SHIFTID = S.SHIFTID'     
+' ,T.DBNAME = S.DBNAME'     
+' ,T.DBKEY = S.DBKEY'     
+' ,T.FIELDID = S.FIELDID'     
+' ,T.FIELDTRUCK = S.FIELDTRUCK'     
+' ,T.FIELDEXCAV = S.FIELDEXCAV'     
+' ,T.FIELDGRADE = S.FIELDGRADE'     
+' ,T.FIELDLOC = S.FIELDLOC'     
+' ,T.FIELDDUMPREC = S.FIELDDUMPREC'     
+' ,T.FIELDTONS = S.FIELDTONS'     
+' ,T.FIELDTIMEARRIVE = S.FIELDTIMEARRIVE'     
+' ,T.FIELDTIMELOAD = S.FIELDTIMELOAD'     
+' ,T.FIELDTIMEFULL = S.FIELDTIMEFULL'     
+' ,T.FIELDCALCTRAVTIME = S.FIELDCALCTRAVTIME'     
+' ,T.FIELDLOAD = S.FIELDLOAD'     
+' ,T.FIELDEXTRALOAD = S.FIELDEXTRALOAD'     
+' ,T.FIELDLOADTYPE = S.FIELDLOADTYPE'     
+' ,T.FIELDDIST = S.FIELDDIST'     
+' ,T.FIELDEFH = S.FIELDEFH'     
+' ,T.FIELDTOPER = S.FIELDTOPER'     
+' ,T.FIELDEOPER = S.FIELDEOPER'     
+' ,T.FIELDORIGASN = S.FIELDORIGASN'     
+' ,T.FIELDREASN