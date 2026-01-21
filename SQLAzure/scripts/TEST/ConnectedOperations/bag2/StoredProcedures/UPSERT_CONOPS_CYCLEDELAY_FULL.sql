

  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_CYCLEDELAY_FULL]      
* PURPOSE : UPSERT [UPSERT_CONOPS_CYCLEDELAY_FULL]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : 
* 1. EXEC BAG2.[UPSERT_CONOPS_CYCLEDELAY_FULL] 'BAG2' ,'FULL', 0  
* 2. EXEC BAG2.[UPSERT_CONOPS_CYCLEDELAY_FULL] 'BAG2' ,'SHIFT', 1   
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_CYCLEDELAY_FULL]       
(          
@G_SITE VARCHAR(5),  
@G_ExtractMode VARCHAR(5),  
@G_LasfShift NUMERIC(10)   
  
)          
AS          
BEGIN     
  
DECLARE @G_SITE_ALIAS VARCHAR(5)      
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END      
  
IF @G_ExtractMode = 'FULL'   
  
BEGIN  
EXEC       
(      
'MERGE ' +@G_SITE+ '.CYCLEDELAY AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,OID'
+' ,START_TIME_UTC'
+' ,END_TIME_UTC'
+' ,DELAYOID'
+' ,DELAY_CLASS_OID'
+' ,DELAY_CLASS_NAME'
+' ,DELAY_CLASS_DESC'
+' ,DELAY_CATEGORY'
+' ,ESTIMATED_DURATION_MAGNITUDE'
+' ,ESTIMATED_FUEL_USED'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[CYCLEDELAY_STAGE_FULL] '  
+' ) AS S '       
+' ON (T.OID = S.OID AND T.SITEFLAG = S.SITEFLAG AND T.START_TIME_UTC = S.START_TIME_UTC) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.END_TIME_UTC = S.END_TIME_UTC'
+' ,T.DELAYOID = S.DELAYOID'
+' ,T.DELAY_CLASS_OID = S.DELAY_CLASS_OID'
+' ,T.DELAY_CLASS_NAME = S.DELAY_CLASS_NAME'
+' ,T.DELAY_CLASS_DESC = S.DELAY_CLASS_DESC'
+' ,T.DELAY_CATEGORY = S.DELAY_CATEGORY'
+' ,T.ESTIMATED_DURATION_MAGNITUDE = S.ESTIMATED_DURATION_MAGNITUDE'
+' ,T.ESTIMATED_FUEL_USED = S.ESTIMATED_FUEL_USED'
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '            
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,OID'
+' ,START_TIME_UTC'
+' ,END_TIME_UTC'
+' ,DELAYOID'
+' ,DELAY_CLASS_OID'
+' ,DELAY_CLASS_NAME'
+' ,DELAY_CLASS_DESC'
+' ,DELAY_CATEGORY'
+' ,ESTIMATED_DURATION_MAGNITUDE'
+' ,ESTIMATED_FUEL_USED'
+' ,UTC_CREATED_DATE'   
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.OID'
+' ,S.START_TIME_UTC'
+' ,S.END_TIME_UTC'
+' ,S.DELAYOID'
+' ,S.DELAY_CLASS_OID'
+' ,S.DELAY_CLASS_NAME'
+' ,S.DELAY_CLASS_DESC'
+' ,S.DELAY_CATEGORY'
+' ,S.ESTIMATED_DURATION_MAGNITUDE'
+' ,S.ESTIMATED_FUEL_USED'
+' ,S.UTC_CREATED_DATE'   
+' ); '          
 --full compare        
+'  DELETE    '  
+' FROM  ' +@G_SITE+ '.[CYCLEDELAY]    '    
+' WHERE NOT EXISTS    '  
+' (SELECT 1    '  
+' FROM  ' +@G_SITE+ '.[CYCLEDELAY_STAGE_FULL]  AS stg     '  
+' WHERE     '  
+' stg.OID = ' +@G_SITE+ '.[CYCLEDELAY].OID    '  
+' AND   '  
+' stg.START_TIME_UTC = ' +@G_SITE+ '.[CYCLEDELAY].START_TIME_UTC  '  
+'); '  
     
 )  
  
 END  
  
ELSE IF @G_ExtractMode='SHIFT'     
  
BEGIN  
  
EXEC           
(    
  --cleanup before load data by shift        
'  DELETE    '  
+' FROM  ' +@G_SITE+ '.[CYCLEDELAY]    '    
+' WHERE START_TIME_UTC >= (SELECT DATEADD(HOUR,-12 * (' +@G_LasfShift+ '-1),MAX(STARTTIME_UTC)) FROM ' +@G_SITE+ '.SHIFT    '  
+'); '  

+'MERGE ' +@G_SITE+ '.CYCLEDELAY AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,OID'
+' ,START_TIME_UTC'
+' ,END_TIME_UTC'
+' ,DELAYOID'
+' ,DELAY_CLASS_OID'
+' ,DELAY_CLASS_NAME'
+' ,DELAY_CLASS_DESC'
+' ,DELAY_CATEGORY'
+' ,ESTIMATED_DURATION_MAGNITUDE'
+' ,ESTIMATED_FUEL_USED'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[CYCLEDELAY_STAGE_FULL] '  
+' ) AS S '       
+' ON (T.OID = S.OID AND T.SITEFLAG = S.SITEFLAG AND T.START_T