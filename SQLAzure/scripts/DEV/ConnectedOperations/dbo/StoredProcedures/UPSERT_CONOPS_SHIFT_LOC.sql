
  
  
  
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_SHIFT_LOC]    
* PURPOSE : UPSERT [UPSERT_CONOPS_SHIFT_LOC]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_SHIFT_LOC]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
* {22 FEB 2023}  {MFAHMI}   {Enhancement the logic to add delete of records}   
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}
*******************************************************************/      
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_LOC]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN 
DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END
EXEC     
(    
'MERGE ' +@G_SITE+ '.SHIFT_LOC AS T '    
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
+' ,FIELDPIT'     
+' ,FIELDREGION'     
+' ,FIELDELEV'     
+' ,FIELDUNIT'     
+' ,FIELDSTATUS'     
+' ,FIELDREASON'     
+' ,FIELDREASONREC'     
+' ,FIELDAUDIT'     
+' ,FIELDMETADATA'     
+' ,FIELDX'     
+' ,FIELDY'     
+' ,UTC_CREATED_DATE '     
+' ,UTC_LOGICAL_DELETED_DATE'     
+' FROM ' +@G_SITE+ '.SHIFT_LOC_STG'    
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
+' ,T.FIELDPIT = S.FIELDPIT'     
+' ,T.FIELDREGION = S.FIELDREGION'     
+' ,T.FIELDELEV = S.FIELDELEV'     
+' ,T.FIELDUNIT = S.FIELDUNIT'     
+' ,T.FIELDSTATUS = S.FIELDSTATUS'     
+' ,T.FIELDREASON = S.FIELDREASON'     
+' ,T.FIELDREASONREC = S.FIELDREASONREC'     
+' ,T.FIELDAUDIT = S.FIELDAUDIT'     
+' ,T.FIELDMETADATA = S.FIELDMETADATA'     
+' ,T.FIELDX = S.FIELDX'     
+' ,T.FIELDY = S.FIELDY'     
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '     
+' ,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE '     
+' WHEN NOT MATCHED '     
+' THEN INSERT ( '     
+'  SITEFLAG' 
+' ,DBPREVIOUS'  
+' ,DBNEXT'     
+' ,DBVERSION'     
+' ,SHIFTID'     
+' ,ID'     
+' ,DBNAME'     
+' ,DBKEY'     
+' ,FIELDID'     
+' ,FIELDPIT'     
+' ,FIELDREGION'     
+' ,FIELDELEV'     
+' ,FIELDUNIT'     
+' ,FIELDSTATUS'     
+' ,FIELDREASON'     
+' ,FIELDREASONREC'     
+' ,FIELDAUDIT'     
+' ,FIELDMETADATA'     
+' ,FIELDX'     
+' ,FIELDY'     
+' ,UTC_CREATED_DATE '     
+' ,UTC_LOGICAL_DELETED_DATE '     
+'  ) VALUES( '     
+' S.SITEFLAG' 
+' ,S.DBPREVIOUS'     
+' ,S.DBNEXT'     
+' ,S.DBVERSION'     
+' ,S.SHIFTID'     
+' ,S.ID'     
+' ,S.DBNAME'     
+' ,S.DBKEY'     
+' ,S.FIELDID'     
+' ,S.FIELDPIT'     
+' ,S.FIELDREGION'     
+' ,S.FIELDELEV'     
+' ,S.FIELDUNIT'     
+' ,S.FIELDSTATUS'     
+' ,S.FIELDREASON'     
+' ,S.FIELDREASONREC'     
+' ,S.FIELDAUDIT'     
+' ,S.FIELDMETADATA'     
+' ,S.FIELDX'     
+' ,S.FIELDY'     
+' ,S.UTC_CREATED_DATE '     
+' ,S.UTC_LOGICAL_DELETED_DATE '     
+' ); '     
+'  UPDATE T '     
+' SET '     
+' T.UTC_LOGICAL_DELETED_DATE = GETUTCDATE() '     
+' FROM ' +@G_SITE+ '.SHIFT_LOC AS T '    
+' LEFT JOIN ' +@G_SITE+ '.SHIFT_LOC_STG AS S '    
+' ON ( T.ID = S.ID)'    
+' WHERE S.CHANGE_TYPE IN (''D''); '   

+' DELETE FROM ' + @G_SITE + '.SHIFT_LOC '  
+' WHERE UTC_LOGICAL_DELETED_DATE IS NOT NULL ; '  
 
 );    
END    
    
