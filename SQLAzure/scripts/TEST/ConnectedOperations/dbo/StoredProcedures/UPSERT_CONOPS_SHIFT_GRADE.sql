
  
    
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_SHIFT_GRADE]    
* PURPOSE : UPSERT [UPSERT_CONOPS_SHIFT_GRADE]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_SHIFT_GRADE] 'BAG'     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {08 FEB 2023}  {MFAHMI}   {INITIAL CREATED}      
* {22 FEB 2023}  {MFAHMI}   {Enhancement the logic to add delete of records}
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}  
*******************************************************************/      

CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_GRADE]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN 
DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END
EXEC     
(    
'MERGE ' + @G_SITE+ '.SHIFT_GRADE AS T '    
+' USING (SELECT '    
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG' 
+' ,DBPREVIOUS'   
+'  ,DbNext '  
+'  ,DbVersion '  
+'  ,ShiftId '  
+'  ,Id '  
+'  ,DbName '  
+'  ,DbKey '  
+'  ,FieldId '  
+'  ,FieldLoc '  
+'  ,FieldDump '  
+'  ,FieldInv '  
+'  ,FieldSpgr '  
+'  ,FieldLoad '  
+'  ,FieldBlend '  
+'  ,FieldDensity '  
+'  ,FieldThickness '  
+'  ,FieldShot '  
+'  ,FieldProperty '  
+'  ,UTC_CREATED_DATE '    
+'  ,UTC_LOGICAL_DELETED_DATE'    
+'  FROM ' + @G_SITE + '.SHIFT_GRADE_STG'    
+'  WHERE CHANGE_TYPE IN (''U'',''I'')) AS S '    
+'  ON (T.ID = S.ID AND T.SITEFLAG = S.SITEFLAG ) '    
+'  WHEN MATCHED '    
+'  THEN UPDATE SET T.DbPrevious = S.DbPrevious '  
+'  ,T.DbNext = S.DbNext '  
+'  ,T.DbVersion = S.DbVersion '  
+'  ,T.ShiftId = S.ShiftId '  
--+'  ,T.Id = S.Id '  
+'  ,T.DbName = S.DbName '  
+'  ,T.DbKey = S.DbKey '  
+'  ,T.FieldId = S.FieldId '  
+'  ,T.FieldLoc = S.FieldLoc '  
+'  ,T.FieldDump = S.FieldDump '  
+'  ,T.FieldInv = S.FieldInv '  
+'  ,T.FieldSpgr = S.FieldSpgr '  
+'  ,T.FieldLoad = S.FieldLoad '  
+'  ,T.FieldBlend = S.FieldBlend '  
+'  ,T.FieldDensity = S.FieldDensity '  
+'  ,T.FieldThickness = S.FieldThickness '  
+'  ,T.FieldShot = S.FieldShot '  
+'  ,T.FieldProperty = S.FieldProperty '  
+'  ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '    
+'  ,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE '    
+'  WHEN NOT MATCHED '    
+'  THEN INSERT ( '    
+'  SITEFLAG' 
+'  ,DbPrevious'   
+'  ,DbNext '  
+'  ,DbVersion '  
+'  ,ShiftId '  
+'  ,Id '  
+'  ,DbName '  
+'  ,DbKey '  
+'  ,FieldId '  
+'  ,FieldLoc '  
+'  ,FieldDump '  
+'  ,FieldInv '  
+'  ,FieldSpgr '  
+'  ,FieldLoad '  
+'  ,FieldBlend '  
+'  ,FieldDensity '  
+'  ,FieldThickness '  
+'  ,FieldShot '  
+'  ,FieldProperty '  
+'  ,UTC_CREATED_DATE '    
+'  ,UTC_LOGICAL_DELETED_DATE '    
+'   ) VALUES( '    
+'   S.SITEFLAG' 
+'  ,S.DbPrevious'  
+'  ,S.DbNext '  
+'  ,S.DbVersion '  
+'  ,S.ShiftId '  
+'  ,S.Id '  
+'  ,S.DbName '  
+'  ,S.DbKey '  
+'  ,S.FieldId '  
+'  ,S.FieldLoc '  
+'  ,S.FieldDump '  
+'  ,S.FieldInv '  
+'  ,S.FieldSpgr '  
+'  ,S.FieldLoad '  
+'  ,S.FieldBlend '  
+'  ,S.FieldDensity '  
+'  ,S.FieldThickness '  
+'  ,S.FieldShot '  
+'  ,S.FieldProperty '  
+'  ,S.UTC_CREATED_DATE '    
+'  ,S.UTC_LOGICAL_DELETED_DATE '    
+'  ); '    
+'   UPDATE T '    
+'  SET '    
+'  T.UTC_LOGICAL_DELETED_DATE = GETUTCDATE() '    
+'  FROM ' + @G_SITE + '.SHIFT_GRADE AS T '    
 +' LEFT JOIN ' + @G_SITE + '.SHIFT_GRADE_STG AS S '    
+'  ON ( '    
+'  T.ID = S.ID) '    
+'  WHERE S.CHANGE_TYPE IN (''D''); '    

+' DELETE FROM ' + @G_SITE + '.SHIFT_GRADE '  
+' WHERE UTC_LOGICAL_DELETED_DATE IS NOT NULL ; '  
 );    
END    
