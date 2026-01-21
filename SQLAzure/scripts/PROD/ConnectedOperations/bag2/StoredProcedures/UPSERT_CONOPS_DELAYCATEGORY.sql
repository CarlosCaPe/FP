
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_DELAYCATEGORY]      
* PURPOSE : UPSERT [UPSERT_CONOPS_DELAYCATEGORY]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_DELAYCATEGORY] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_DELAYCATEGORY]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.DELAYCATEGORY AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,DELAYCATEGORY_OID'
+' ,NAME'
+' ,COLOUR'
+' ,BOLD'
+' ,ITALIC'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_DELAYCATEGORY_ETL] '  
+' ) AS S '       
+' ON (T.DELAYCATEGORY_OID = S.DELAYCATEGORY_OID AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.NAME = S.NAME'
+' ,T.COLOUR = S.COLOUR'
+' ,T.BOLD = S.BOLD'
+' ,T.ITALIC = S.ITALIC'
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '        
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,DELAYCATEGORY_OID'
+' ,NAME'
+' ,COLOUR'
+' ,BOLD'
+' ,ITALIC'
+' ,UTC_CREATED_DATE'   
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.DELAYCATEGORY_OID'
+' ,S.NAME'
+' ,S.COLOUR'
+' ,S.BOLD'
+' ,S.ITALIC'
+' ,S.UTC_CREATED_DATE' 
+' ); '       

--Compare to stage
+'  DELETE    '
+' FROM  ' +@G_SITE+ '.[DELAYCATEGORY]    '  
+' WHERE NOT EXISTS    '
+' (SELECT 1    '
+' FROM  ' +@G_SITE+ '.[VIEW_DELAYCATEGORY_ETL]  AS stg     '
+' WHERE     '
+' stg.DELAYCATEGORY_OID = ' +@G_SITE+ '.[DELAYCATEGORY].DELAYCATEGORY_OID    '
+'); ' 
      
   
 );      
END      
      
