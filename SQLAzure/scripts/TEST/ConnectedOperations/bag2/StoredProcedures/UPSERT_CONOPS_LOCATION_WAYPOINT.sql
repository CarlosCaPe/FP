
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_LOCATION_WAYPOINT]      
* PURPOSE : UPSERT [UPSERT_CONOPS_LOCATION_WAYPOINT]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_LOCATION_WAYPOINT] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_LOCATION_WAYPOINT]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.LOCATION_WAYPOINT AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,OID'
+' ,WAYPOINT_OID'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_LOCATION_WAYPOINT_ETL] '  
+' ) AS S '       
+' ON (T.OID = S.OID AND T.WAYPOINT_OID = S.WAYPOINT_OID AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '           
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,OID'
+' ,WAYPOINT_OID'
+' ,UTC_CREATED_DATE'    
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.OID'
+' ,S.WAYPOINT_OID'
+' ,S.UTC_CREATED_DATE'  

+' ); '  

--Compare to stage
+'  DELETE    '
+' FROM  ' +@G_SITE+ '.[LOCATION_WAYPOINT]    '  
+' WHERE NOT EXISTS    '
+' (SELECT 1    '
+' FROM  ' +@G_SITE+ '.[VIEW_LOCATION_WAYPOINT_ETL]  AS stg     '
+' WHERE     '
+' stg.OID = ' +@G_SITE+ '.[LOCATION_WAYPOINT].OID    '
+' AND stg.WAYPOINT_OID = ' +@G_SITE+ '.[LOCATION_WAYPOINT].WAYPOINT_OID    '
+'); '     
   
 );      
END      
      
