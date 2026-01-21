
  
  
/******************************************************************    
* PROCEDURE : dbo.[UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS]  
* PURPOSE : Upsert [UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS]  
* NOTES     :   
* CREATED : lwasini  
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS]   
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {25 OCT 2022}  {lwasini}   {Initial Created}    
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS]  
(  
@G_SITE VARCHAR(5)  
)  
AS  
BEGIN  
EXEC   
(  
' DELETE FROM ' +@G_SITE+ '.EQUIPMENT_HOURLY_STATUS'   
  
+' INSERT INTO ' +@G_SITE+ '.EQUIPMENT_HOURLY_STATUS'   
+' SELECT ' 
+'  SHIFTINDEX'
+' ,SHIFTDATE'
+' ,SHIFT_CODE'
+' ,SHIFT'
+' ,CREW'
+' ,SITE_CODE'
+' ,CLIID'
+' ,DDBKEY'
+' ,EQMT'
+' ,UNIT'
+' ,OPERID'
+' ,HOS'
+' ,START_TIME_TS'
+' ,STARTTIME'
+' ,END_TIME_TS'
+' ,ENDTTIME'
+' ,DURATION'
+' ,REASON'
+' ,STATUS'
+' ,CATEGORY'
+' ,COMMENTS'
+' ,VEVENT'
+' ,REASONLINK'
+' ,LOC'
+' ,REGION'
+' ,GPS_X'
+' ,GPS_Y'
+' ,GPS_STATE'
+' ,GPS_HEADING'
+' ,GPS_VELOCITY'
+' ,SYSTEM_VERSION' 
+' ,UTC_CREATED_DATE '   
+' FROM ' +@G_SITE+ '.EQUIPMENT_HOURLY_STATUS_STG'  
  
); 
  
END  
  
