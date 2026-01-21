
  
    
    
    
/******************************************************************        
* PROCEDURE : BAG2.[UPSERT_CONOPS_SHIFT]      
* PURPOSE : UPSERT [UPSERT_CONOPS_SHIFT]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC BAG2.[UPSERT_CONOPS_SHIFT] 'BAG2'       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 SEP 2024}  {MFAHMI}   {INITIAL CREATED}        
*******************************************************************/        
CREATE  PROCEDURE [bag2].[UPSERT_CONOPS_SHIFT]       
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)  
  
SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' WHEN @G_SITE ='BAG2' THEN 'BAG' ELSE @G_SITE END  
EXEC       
(      
'MERGE ' +@G_SITE+ '.SHIFT AS T '      
+' USING (SELECT '       
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG'   
+' ,OID'
+' ,VERSION'
+' ,STARTTIME_UTC'
+' ,ENDTIME_UTC'
+' ,SHIFTTYPE'
+' ,CREW'
+' ,NAME'
+' ,DAY'
+' ,WEEK'
+' ,MONTH'
+' ,QUARTER'
+' ,HALF'
+' ,YEAR'
+' ,REPORTING_DATE'
+' ,GETUTCDATE() AS UTC_CREATED_DATE'
+' FROM ' +@G_SITE+ '.[VIEW_SHIFT_ETL] '  
+' ) AS S '       
+' ON (T.OID = S.OID AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET ' 
+' T.VERSION = S.VERSION'
+' ,T.STARTTIME_UTC = S.STARTTIME_UTC'
+' ,T.ENDTIME_UTC = S.ENDTIME_UTC'
+' ,T.SHIFTTYPE = S.SHIFTTYPE'
+' ,T.CREW = S.CREW'
+' ,T.NAME = S.NAME'
+' ,T.DAY = S.DAY'
+' ,T.WEEK = S.WEEK'
+' ,T.MONTH = S.MONTH'
+' ,T.QUARTER = S.QUARTER'
+' ,T.HALF = S.HALF'
+' ,T.YEAR = S.YEAR'
+' ,T.REPORTING_DATE = S.REPORTING_DATE'
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '        
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '       
+' SITEFLAG'
+' ,OID'
+' ,VERSION'
+' ,STARTTIME_UTC'
+' ,ENDTIME_UTC'
+' ,SHIFTTYPE'
+' ,CREW'
+' ,NAME'
+' ,DAY'
+' ,WEEK'
+' ,MONTH'
+' ,QUARTER'
+' ,HALF'
+' ,YEAR'
+' ,REPORTING_DATE'
+' ,UTC_CREATED_DATE'
+'  ) VALUES( '       
+' S.SITEFLAG'
+' ,S.OID'
+' ,S.VERSION'
+' ,S.STARTTIME_UTC'
+' ,S.ENDTIME_UTC'
+' ,S.SHIFTTYPE'
+' ,S.CREW'
+' ,S.NAME'
+' ,S.DAY'
+' ,S.WEEK'
+' ,S.MONTH'
+' ,S.QUARTER'
+' ,S.HALF'
+' ,S.YEAR'
+' ,S.REPORTING_DATE'
+' ,S.UTC_CREATED_DATE'

+' ); '       

--Compare to stage
+'  DELETE    '
+' FROM  ' +@G_SITE+ '.[SHIFT]    '  
+' WHERE NOT EXISTS    '
+' (SELECT 1    '
+' FROM  ' +@G_SITE+ '.[VIEW_SHIFT_ETL]  AS stg     '
+' WHERE     '
+' stg.OID = ' +@G_SITE+ '.[SHIFT].OID    '
+'); '      
   
 );      
END      
      
