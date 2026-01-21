
  
  
  
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_SHIFT_ROOT_SHIFT_DATE]    
* PURPOSE : UPSERT [UPSERT_CONOPS_SHIFT_ROOT_SHIFT_DATE]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_SHIFT_ROOT_SHIFT_DATE]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
* {22 FEB 2023}  {MFAHMI}   {Enhancement the logic to add delete of records}   
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}
*******************************************************************/      
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_ROOT_SHIFT_DATE]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN 

DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END

EXEC     
(    
'MERGE ' + @G_SITE+ '.SHIFT_ROOT_SHIFT_DATE AS T '    
+' USING (SELECT '    
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG' 
+'  ,ID '    
+'  ,FIELDSTART'    
+'  ,FIELDTIME'    
+'  ,FIELDYEAR'    
+'  ,FIELDMONTH'    
+'  ,FIELDDAY'    
+'  ,FIELDSHIFT'    
+'  ,FIELDCREW'    
+'  ,FIELDHOLIDAY'    
+'  ,FIELDUTCSTART'    
+'  ,FIELDUTCEND'    
+'  ,FIELDDSTSTATE'    
+'  ,UTC_CREATED_DATE '    
+'  ,UTC_LOGICAL_DELETED_DATE'    
+'  FROM ' + @G_SITE + '.SHIFT_ROOT_SHIFT_DATE_STG'    
+'  WHERE CHANGE_TYPE IN (''U'',''I'')) AS S '    
+'  ON (T.ID = S.ID AND T.SITEFLAG = S.SITEFLAG) '    
+'  WHEN MATCHED '    
+'  THEN UPDATE SET T.FIELDSTART = S.FIELDSTART '    
+'  ,T.FIELDTIME = S.FIELDTIME '    
+'  ,T.FIELDYEAR = S.FIELDYEAR '    
+'  ,T.FIELDMONTH = S.FIELDMONTH '    
+'  ,T.FIELDDAY = S.FIELDDAY  '    
+'  ,T.FIELDSHIFT = S.FIELDSHIFT  '    
+'  ,T.FIELDCREW = S.FIELDCREW  '    
+'  ,T.FIELDHOLIDAY = S.FIELDHOLIDAY  '    
+'  ,T.FIELDUTCSTART = S.FIELDUTCSTART  '    
+'  ,T.FIELDUTCEND = S.FIELDUTCEND  '    
+'  ,T.FIELDDSTSTATE = S.FIELDDSTSTATE  '    
+'  ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '    
+'  ,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE '    
+'  WHEN NOT MATCHED '    
+'  THEN INSERT ( '   
+'  SITEFLAG' 
+'  ,ID '    
+'  ,FIELDSTART'    
+'  ,FIELDTIME'    
+'  ,FIELDYEAR'    
+'  ,FIELDMONTH'    
+'  ,FIELDDAY'    
+'  ,FIELDSHIFT'    
+'  ,FIELDCREW'    
+'  ,FIELDHOLIDAY'    
+'  ,FIELDUTCSTART'    
+'  ,FIELDUTCEND'    
+'  ,FIELDDSTSTATE'    
+'  ,UTC_CREATED_DATE '    
+'  ,UTC_LOGICAL_DELETED_DATE '    
+'   ) VALUES( '    
+'  S.SITEFLAG' 
+'  ,S.ID '    
+'  ,S.FIELDSTART'    
+'  ,S.FIELDTIME'    
+'  ,S.FIELDYEAR'    
+'  ,S.FIELDMONTH'    
+'  ,S.FIELDDAY'    
+'  ,S.FIELDSHIFT'    
+'  ,S.FIELDCREW'    
+'  ,S.FIELDHOLIDAY'    
+'  ,S.FIELDUTCSTART'    
+'  ,S.FIELDUTCEND'    
+'  ,S.FIELDDSTSTATE'    
+'  ,S.UTC_CREATED_DATE '    
+'  ,S.UTC_LOGICAL_DELETED_DATE '    
+'  ); '    
+'   UPDATE T '    
+'  SET '    
+'  T.UTC_LOGICAL_DELETED_DATE = GETUTCDATE() '    
+'  FROM ' + @G_SITE + '.SHIFT_ROOT_SHIFT_DATE AS T '    
 +' LEFT JOIN ' + @G_SITE + '.SHIFT_ROOT_SHIFT_DATE_STG AS S '    
+'  ON ( '    
+'  T.ID = S.ID) '    
+'  WHERE S.CHANGE_TYPE IN (''D''); '   

+' DELETE FROM ' + @G_SITE + '.SHIFT_ROOT_SHIFT_DATE '  
+' WHERE UTC_LOGICAL_DELETED_DATE IS NOT NULL ; '  
 
 );    
END    
    
