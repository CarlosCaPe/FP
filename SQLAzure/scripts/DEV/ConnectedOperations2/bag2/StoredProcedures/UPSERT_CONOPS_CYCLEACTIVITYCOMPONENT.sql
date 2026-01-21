
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_CYCLEACTIVITYCOMPONENT]      
* PURPOSE : UPSERT [UPSERT_CONOPS_CYCLEACTIVITYCOMPONENT]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_CYCLEACTIVITYCOMPONENT] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_CYCLEACTIVITYCOMPONENT]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.CYCLEACTIVITYCOMPONENT AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,OID'
+' ,NAME'
+' ,START_TIME_UTC'
+' ,END_TIME_UTC'
+' ,ESTIMATED_FUEL_USED'
+' ,CREATED_DATE_UTC'
+' ,LAST_MODIFIED_UTC'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_CYCLEACTIVITYCOMPONENT_ETL] '  
+' ) AS S '       
+' ON (T.OID = S.OID AND T.SITEFLAG = S.SITEFLAG AND T.START_TIME_UTC = S.START_TIME_UTC) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.NAME = S.NAME'
+' ,T.END_TIME_UTC = S.END_TIME_UTC'
+' ,T.ESTIMATED_FUEL_USED = S.ESTIMATED_FUEL_USED'
+' ,T.CREATED_DATE_UTC = S.CREATED_DATE_UTC'
+' ,T.LAST_MODIFIED_UTC = S.LAST_MODIFIED_UTC'
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '            
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,OID'
+' ,NAME'
+' ,START_TIME_UTC'
+' ,END_TIME_UTC'
+' ,ESTIMATED_FUEL_USED'
+' ,CREATED_DATE_UTC'
+' ,LAST_MODIFIED_UTC'
+' ,UTC_CREATED_DATE'      
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.OID'
+' ,S.NAME'
+' ,S.START_TIME_UTC'
+' ,S.END_TIME_UTC'
+' ,S.ESTIMATED_FUEL_USED'
+' ,S.CREATED_DATE_UTC'
+' ,S.LAST_MODIFIED_UTC'
+' ,S.UTC_CREATED_DATE'  
+' ); '       
   
 );      
END      
      
