
  
    
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_ENUM]    
* PURPOSE : UPSERT [UPSERT_CONOPS_ENUM]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_ENUM]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
* {22 FEB 2023}  {MFAHMI}   {Enhancement the logic to add delete of records}   
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}  
*******************************************************************/      
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_ENUM]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END

EXEC     
(    
'MERGE ' + @G_SITE+ '.ENUM AS T '    
+' USING (SELECT '  
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG' 
+'  ,ID '    
+'  ,ENUMTYPEID'    
+'  ,IDX'    
+'  ,[DESCRIPTION]'    
+'  ,ABBREVIATION'    
+'  ,FLAGS'    
+'  ,UTC_CREATED_DATE '    
+'  ,UTC_LOGICAL_DELETED_DATE'    
+'  FROM ' + @G_SITE + '.ENUM_STG'    
+'  WHERE CHANGE_TYPE IN (''U'',''I'')) AS S '    
+'  ON (T.ID = S.ID AND T.SITEFLAG = S.SITEFLAG ) '    
+'  WHEN MATCHED '    
+'  THEN UPDATE SET T.ENUMTYPEID = S.ENUMTYPEID '    
+'  ,T.IDX = S.IDX '    
+'  ,T.[DESCRIPTION] = S.[DESCRIPTION] '    
+'  ,T.ABBREVIATION = S.ABBREVIATION '    
+'  ,T.FLAGS = S.FLAGS  '    
+'  ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '    
+'  ,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE '    
+'  WHEN NOT MATCHED '    
+'  THEN INSERT ( ' 
+'  SITEFLAG' 
+'  ,ID '    
+'  ,ENUMTYPEID '    
+'  ,IDX '    
+'  ,[DESCRIPTION] '    
+'  ,FLAGS '    
+'  ,UTC_CREATED_DATE '    
+'  ,UTC_LOGICAL_DELETED_DATE '    
+'   ) VALUES( '
+'  S.SITEFLAG' 
+'  ,S.ID '    
+'  ,S.ENUMTYPEID '    
+'  ,S.IDX '    
+'  ,S.[DESCRIPTION] '    
+'  ,S.FLAGS '    
+'  ,S.UTC_CREATED_DATE '    
+'  ,S.UTC_LOGICAL_DELETED_DATE '    
+'  ); '    
+'   UPDATE T '    
+'  SET '    
+'  T.UTC_LOGICAL_DELETED_DATE = GETUTCDATE() '    
+'  FROM ' + @G_SITE + '.ENUM AS T '    
 +' LEFT JOIN ' + @G_SITE + '.ENUM_STG AS S '    
+'  ON ( '    
+'  T.ID = S.ID) '    
+'  WHERE S.CHANGE_TYPE IN (''D''); '    

+' DELETE FROM ' + @G_SITE + '.ENUM '  
+' WHERE UTC_LOGICAL_DELETED_DATE IS NOT NULL ; '  

 );    
END    
