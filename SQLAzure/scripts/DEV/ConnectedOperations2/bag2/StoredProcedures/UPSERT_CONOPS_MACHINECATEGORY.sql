
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_MACHINECATEGORY]      
* PURPOSE : UPSERT [UPSERT_CONOPS_MACHINECATEGORY]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_MACHINECATEGORY] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_MACHINECATEGORY]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.MACHINECATEGORY AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,MACHINECATEGORY_OID'
+' ,ECF_CLASS_ID'
+' ,IS_ACTIVE'
+' ,NAME'
+' ,DESCRIPTION'
+' ,ICONURL'
+' ,STATESET'
+' ,CYCLEENGINE'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_MACHINECATEGORY_ETL] '  
+' ) AS S '       
+' ON (T.MACHINECATEGORY_OID = S.MACHINECATEGORY_OID AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.ECF_CLASS_ID = S.ECF_CLASS_ID'
+' ,T.IS_ACTIVE = S.IS_ACTIVE'
+' ,T.NAME = S.NAME'
+' ,T.DESCRIPTION = S.DESCRIPTION'
+' ,T.ICONURL = S.ICONURL'
+' ,T.STATESET = S.STATESET'
+' ,T.CYCLEENGINE = S.CYCLEENGINE'
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '           
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,MACHINECATEGORY_OID'
+' ,ECF_CLASS_ID'
+' ,IS_ACTIVE'
+' ,NAME'
+' ,DESCRIPTION'
+' ,ICONURL'
+' ,STATESET'
+' ,CYCLEENGINE'
+' ,UTC_CREATED_DATE'
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.MACHINECATEGORY_OID'
+' ,S.ECF_CLASS_ID'
+' ,S.IS_ACTIVE'
+' ,S.NAME'
+' ,S.DESCRIPTION'
+' ,S.ICONURL'
+' ,S.STATESET'
+' ,S.CYCLEENGINE'
+' ,S.UTC_CREATED_DATE'

+' ); '       

--Compare to stage
+'  DELETE    '
+' FROM  ' +@G_SITE+ '.[MACHINECATEGORY]    '  
+' WHERE NOT EXISTS    '
+' (SELECT 1    '
+' FROM  ' +@G_SITE+ '.[VIEW_MACHINECATEGORY_ETL]  AS stg     '
+' WHERE     '
+' stg.MACHINECATEGORY_OID = ' +@G_SITE+ '.[MACHINECATEGORY].MACHINECATEGORY_OID    '
+'); '   
   
 );      
END      
      
