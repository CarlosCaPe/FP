
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_VIRTUALBEACON]      
* PURPOSE : UPSERT [UPSERT_CONOPS_VIRTUALBEACON]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_VIRTUALBEACON] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_VIRTUALBEACON]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.VIRTUALBEACON AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,VIRTUALBEACON_OID'
+' ,IS_ACTIVE'
+' ,NAME'
+' ,DESCRIPTION'
+' ,COLOUR'
+' ,DATE_LAST_MODIFIED_UTC'
+' ,FLAGS'
+' ,HEIGHT'
+' ,ID'
+' ,LOADERID'
+' ,RADIUS'
+' ,REASSIGNMT'
+' ,REASSIGNFULL'
+' ,TYPE'
+' ,VERSION'
+' ,ZORDER'
+' ,MISSED_COUNT'
+' ,ROUTE_POINT_X'
+' ,ROUTE_POINT_Y'
+' ,ROUTE_POINT_Z'
+' ,EXTERNALREF'
+' ,EXTERNALDESC'
+' ,MODEL_UPDATE_VERSION'
+' ,LAYER_UPDATE_VERSION'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_VIRTUALBEACON_ETL] '  
+' ) AS S '       
+' ON (T.VIRTUALBEACON_OID = S.VIRTUALBEACON_OID AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET ' 
+' T.IS_ACTIVE = S.IS_ACTIVE'
+' ,T.NAME = S.NAME'
+' ,T.DESCRIPTION = S.DESCRIPTION'
+' ,T.COLOUR = S.COLOUR'
+' ,T.DATE_LAST_MODIFIED_UTC = S.DATE_LAST_MODIFIED_UTC'
+' ,T.FLAGS = S.FLAGS'
+' ,T.HEIGHT = S.HEIGHT'
+' ,T.ID = S.ID'
+' ,T.LOADERID = S.LOADERID'
+' ,T.RADIUS = S.RADIUS'
+' ,T.REASSIGNMT = S.REASSIGNMT'
+' ,T.REASSIGNFULL = S.REASSIGNFULL'
+' ,T.TYPE = S.TYPE'
+' ,T.VERSION = S.VERSION'
+' ,T.ZORDER = S.ZORDER'
+' ,T.MISSED_COUNT = S.MISSED_COUNT'
+' ,T.ROUTE_POINT_X = S.ROUTE_POINT_X'
+' ,T.ROUTE_POINT_Y = S.ROUTE_POINT_Y'
+' ,T.ROUTE_POINT_Z = S.ROUTE_POINT_Z'
+' ,T.EXTERNALREF = S.EXTERNALREF'
+' ,T.EXTERNALDESC = S.EXTERNALDESC'
+' ,T.MODEL_UPDATE_VERSION = S.MODEL_UPDATE_VERSION'
+' ,T.LAYER_UPDATE_VERSION = S.LAYER_UPDATE_VERSION'
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '       
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,VIRTUALBEACON_OID'
+' ,IS_ACTIVE'
+' ,NAME'
+' ,DESCRIPTION'
+' ,COLOUR'
+' ,DATE_LAST_MODIFIED_UTC'
+' ,FLAGS'
+' ,HEIGHT'
+' ,ID'
+' ,LOADERID'
+' ,RADIUS'
+' ,REASSIGNMT'
+' ,REASSIGNFULL'
+' ,TYPE'
+' ,VERSION'
+' ,ZORDER'
+' ,MISSED_COUNT'
+' ,ROUTE_POINT_X'
+' ,ROUTE_POINT_Y'
+' ,ROUTE_POINT_Z'
+' ,EXTERNALREF'
+' ,EXTERNALDESC'
+' ,MODEL_UPDATE_VERSION'
+' ,LAYER_UPDATE_VERSION'
+' ,UTC_CREATED_DATE'
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.VIRTUALBEACON_OID'
+' ,S.IS_ACTIVE'
+' ,S.NAME'
+' ,S.DESCRIPTION'
+' ,S.COLOUR'
+' ,S.DATE_LAST_MODIFIED_UTC'
+' ,S.FLAGS'
+' ,S.HEIGHT'
+' ,S.ID'
+' ,S.LOADERID'
+' ,S.RADIUS'
+' ,S.REASSIGNMT'
+' ,S.REASSIGNFULL'
+' ,S.TYPE'
+' ,S.VERSION'
+' ,S.ZORDER'
+' ,S.MISSED_COUNT'
+' ,S.ROUTE_POINT_X'
+' ,S.ROUTE_POINT_Y'
+' ,S.ROUTE_POINT_Z'
+' ,S.EXTERNALREF'
+' ,S.EXTERNALDESC'
+' ,S.MODEL_UPDATE_VERSION'
+' ,S.LAYER_UPDATE_VERSION'
+' ,S.UTC_CREATED_DATE'

+' ); '       

--Compare to stage
+'  DELETE    '
+' FROM  ' +@G_SITE+ '.[VIRTUALBEACON]    '  
+' WHERE NOT EXISTS    '
+' (SELECT 1    '
+' FROM  ' +@G_SITE+ '.[VIEW_VIRTUALBEACON_ETL]  AS stg     '
+' WHERE     '
+' stg.VIRTUALBEACON_OID = ' +@G_SITE+ '.[VIRTUALBEACON].VIRTUALBEACON_OID    '
+'); '      
   
 );      
END      
      
