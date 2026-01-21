
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_CREW]      
* PURPOSE : UPSERT [UPSERT_CONOPS_CREW]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_CREW] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_CREW]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.CREW AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,OID'
+' ,NAME'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_CREW_ETL] '  
+' ) AS S '       
+' ON (T.OID = S.OID AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.NAME = S.NAME'
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '           
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,OID'
+' ,NAME'
+' ,UTC_CREATED_DATE'   
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.OID'
+' ,S.NAME'
+' ,S.UTC_CREATED_DATE'

+' ); '       
   
--Compare to stage
+'  DELETE    '
+' FROM  ' +@G_SITE+ '.[CREW]    '  
+' WHERE NOT EXISTS    '
+' (SELECT 1    '
+' FROM  ' +@G_SITE+ '.[VIEW_CREW_ETL]  AS stg     '
+' WHERE     '
+' stg.OID = ' +@G_SITE+ '.[CREW].OID    '
+'); ' 
   
 );      
END      
      
