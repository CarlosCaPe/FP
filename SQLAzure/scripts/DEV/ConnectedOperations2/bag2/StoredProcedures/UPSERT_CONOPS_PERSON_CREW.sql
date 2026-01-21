
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_PERSON_CREW]      
* PURPOSE : UPSERT [UPSERT_CONOPS_PERSON_CREW]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_PERSON_CREW] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_PERSON_CREW]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.PERSON_CREW AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,PERSON_OID'
+' ,CREW_OID'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_PERSON_CREW_ETL] '  
+' ) AS S '       
+' ON (T.PERSON_OID = S.PERSON_OID AND T.CREW_OID = S.CREW_OID AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '        
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,PERSON_OID'
+' ,CREW_OID'
+' ,UTC_CREATED_DATE'
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.PERSON_OID'
+' ,S.CREW_OID'
+' ,S.UTC_CREATED_DATE'

+' ); ' 

--Compare to stage
+'  DELETE    '
+' FROM  ' +@G_SITE+ '.[PERSON_CREW]    '  
+' WHERE NOT EXISTS    '
+' (SELECT 1    '
+' FROM  ' +@G_SITE+ '.[VIEW_PERSON_CREW_ETL]  AS stg     '
+' WHERE     '
+' stg.PERSON_OID = ' +@G_SITE+ '.[PERSON_CREW].PERSON_OID    '
+' AND stg.CREW_OID = ' +@G_SITE+ '.[PERSON_CREW].CREW_OID    '
+'); '    
   
 );      
END      
      
