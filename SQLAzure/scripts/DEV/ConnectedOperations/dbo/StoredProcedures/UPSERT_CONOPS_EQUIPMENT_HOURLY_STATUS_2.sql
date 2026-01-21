
/******************************************************************    
* PROCEDURE : dbo.[UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS_2]  
* PURPOSE : Upsert [UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS_2]  
* NOTES     :   
* CREATED : lwasini  
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS_2] 'MOR'
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {25 OCT 2022}  {lwasini}   {Initial Created}  
* {25 SEP 2025}  {ggosal1}   {Add Site Code Change for El Abra} 
*******************************************************************/    
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS_2]  
(  
@G_SITE VARCHAR(5)  
)  
AS  
BEGIN  

IF @G_SITE = 'ELA'
BEGIN
	SET @G_SITE = 'ABR'
END

EXEC   
(  
' DELETE FROM ' +@G_SITE+ '.EQUIPMENT_HOURLY_STATUS_2;'   
  
+' INSERT INTO ' +@G_SITE+ '.EQUIPMENT_HOURLY_STATUS_2'   
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
+' FROM ' +@G_SITE+ '.EQUIPMENT_HOURLY_STATUS_STG_2'  
  
); 
  
END  
  

