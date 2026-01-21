
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_MATERIAL]      
* PURPOSE : UPSERT [UPSERT_CONOPS_MATERIAL]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_MATERIAL] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_MATERIAL]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.MATERIAL AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,MATERIAL_OID'
+' ,CODECAES'
+' ,COLOUR'
+' ,DESCRIPTION'
+' ,ID'
+' ,BANKDENSITY'
+' ,LOOSEDENSITY'
+' ,MATUNIT'
+' ,NAME'
+' ,IS_ACTIVE'
+' ,MATERIALGROUP'
+' ,EXTERNALREF'
+' ,EXTERNALDESC'
+' ,MODEL_UPDATE_VERSION'
+' ,LAYER_UPDATE_VERSION'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_MATERIAL_ETL] '  
+' ) AS S '       
+' ON (T.MATERIAL_OID = S.MATERIAL_OID AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.CODECAES = S.CODECAES'
+' ,T.COLOUR = S.COLOUR'
+' ,T.DESCRIPTION = S.DESCRIPTION'
+' ,T.ID = S.ID'
+' ,T.BANKDENSITY = S.BANKDENSITY'
+' ,T.LOOSEDENSITY = S.LOOSEDENSITY'
+' ,T.MATUNIT = S.MATUNIT'
+' ,T.NAME = S.NAME'
+' ,T.IS_ACTIVE = S.IS_ACTIVE'
+' ,T.MATERIALGROUP = S.MATERIALGROUP'
+' ,T.EXTERNALREF = S.EXTERNALREF'
+' ,T.EXTERNALDESC = S.EXTERNALDESC'
+' ,T.MODEL_UPDATE_VERSION = S.MODEL_UPDATE_VERSION'
+' ,T.LAYER_UPDATE_VERSION = S.LAYER_UPDATE_VERSION'
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '       
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,MATERIAL_OID'
+' ,CODECAES'
+' ,COLOUR'
+' ,DESCRIPTION'
+' ,ID'
+' ,BANKDENSITY'
+' ,LOOSEDENSITY'
+' ,MATUNIT'
+' ,NAME'
+' ,IS_ACTIVE'
+' ,MATERIALGROUP'
+' ,EXTERNALREF'
+' ,EXTERNALDESC'
+' ,MODEL_UPDATE_VERSION'
+' ,LAYER_UPDATE_VERSION'
+' ,UTC_CREATED_DATE'
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.MATERIAL_OID'
+' ,S.CODECAES'
+' ,S.COLOUR'
+' ,S.DESCRIPTION'
+' ,S.ID'
+' ,S.BANKDENSITY'
+' ,S.LOOSEDENSITY'
+' ,S.MATUNIT'
+' ,S.NAME'
+' ,S.IS_ACTIVE'
+' ,S.MATERIALGROUP'
+' ,S.EXTERNALREF'
+' ,S.EXTERNALDESC'
+' ,S.MODEL_UPDATE_VERSION'
+' ,S.LAYER_UPDATE_VERSION'
+' ,S.UTC_CREATED_DATE'

+' ); '       

--Compare to stage
+'  DELETE    '
+' FROM  ' +@G_SITE+ '.[MATERIAL]    '  
+' WHERE NOT EXISTS    '
+' (SELECT 1    '
+' FROM  ' +@G_SITE+ '.[VIEW_MATERIAL_ETL]  AS stg     '
+' WHERE     '
+' stg.MATERIAL_OID = ' +@G_SITE+ '.[MATERIAL].MATERIAL_OID    '
+'); ' 
   
 );      
END      
      
