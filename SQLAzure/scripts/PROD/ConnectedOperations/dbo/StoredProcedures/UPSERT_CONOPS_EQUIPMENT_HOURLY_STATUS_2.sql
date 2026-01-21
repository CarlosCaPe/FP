
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

'MERGE ' + @G_SITE + '.EQUIPMENT_HOURLY_STATUS_2 AS T ' +
'USING ( ' +
'    SELECT SHIFTINDEX, SHIFTDATE, SHIFT_CODE, SHIFT, CREW, SITE_CODE, CLIID, DDBKEY, EQMT, UNIT, ' +
'           OPERID, HOS, START_TIME_TS, STARTTIME, END_TIME_TS, ENDTTIME, DURATION, REASON, STATUS, ' +
'           CATEGORY, COMMENTS, VEVENT, REASONLINK, LOC, REGION, GPS_X, GPS_Y, GPS_STATE, ' +
'           GPS_HEADING, GPS_VELOCITY, SYSTEM_VERSION, UTC_CREATED_DATE ' +
'    FROM ' + @G_SITE + '.EQUIPMENT_HOURLY_STATUS_STG_2 ' +
') AS S ' +
'ON ( ' +
'    T.SITE_CODE = S.SITE_CODE AND ' +
'    T.SHIFTINDEX = S.SHIFTINDEX AND ' +
'    T.EQMT = S.EQMT AND ' +
'    T.START_TIME_TS = S.START_TIME_TS ' +
') ' +
'WHEN MATCHED THEN ' +
'    UPDATE SET ' +
'        T.SHIFTDATE = S.SHIFTDATE, ' +
'        T.SHIFT_CODE = S.SHIFT_CODE, ' +
'        T.SHIFT = S.SHIFT, ' +
'        T.CREW = S.CREW, ' +
'        T.CLIID = S.CLIID, ' +
'        T.DDBKEY = S.DDBKEY, ' +
'        T.UNIT = S.UNIT, ' +
'        T.OPERID = S.OPERID, ' +
'        T.HOS = S.HOS, ' +
'        T.STARTTIME = S.STARTTIME, ' +
'        T.END_TIME_TS = S.END_TIME_TS, ' +
'        T.ENDTTIME = S.ENDTTIME, ' +
'        T.DURATION = S.DURATION, ' +
'        T.REASON = S.REASON, ' +
'        T.STATUS = S.STATUS, ' +
'        T.CATEGORY = S.CATEGORY, ' +
'        T.COMMENTS = S.COMMENTS, ' +
'        T.VEVENT = S.VEVENT, ' +
'        T.REASONLINK = S.REASONLINK, ' +
'        T.LOC = S.LOC, ' +
'        T.REGION = S.REGION, ' +
'        T.GPS_X = S.GPS_X, ' +
'        T.GPS_Y = S.GPS_Y, ' +
'        T.GPS_STATE = S.GPS_STATE, ' +
'        T.GPS_HEADING = S.GPS_HEADING, ' +
'        T.GPS_VELOCITY = S.GPS_VELOCITY, ' +
'        T.SYSTEM_VERSION = S.SYSTEM_VERSION, ' +
'        T.UTC_CREATED_DATE = S.UTC_CREATED_DATE ' +
'WHEN NOT MATCHED THEN ' +
'    INSERT (SHIFTINDEX, SHIFTDATE, SHIFT_CODE, SHIFT, CREW, SITE_CODE, CLIID, DDBKEY, EQMT, UNIT, ' +
'            OPERID, HOS, START_TIME_TS, STARTTIME, END_TIME_TS, ENDTTIME, DURATION, REASON, STATUS, ' +
'            CATEGORY, COMMENTS, VEVENT, REASONLINK, LOC, REGION, GPS_X, GPS_Y, GPS_STATE, ' +
'            GPS_HEADING, GPS_VELOCITY, SYSTEM_VERSION, UTC_CREATED_DATE) ' +
'    VALUES (S.SHIFTINDEX, S.SHIFTDATE, S.SHIFT_CODE, S.SHIFT, S.CREW, S.SITE_CODE, S.CLIID, S.DDBKEY, S.EQMT, S.UNIT, ' +
'            S.OPERID, S.HOS, S.START_TIME_TS, S.STARTTIME, S.END_TIME_TS, S.ENDTTIME, S.DURATION, S.REASON, S.STATUS, ' +
'            S.CATEGORY, S.COMMENTS, S.VEVENT, S.REASONLINK, S.LOC, S.REGION, S.GPS_X, S.GPS_Y, S.GPS_STATE, ' +
'            S.GPS_HEADING, S.GPS_VELOCITY, S.SYSTEM_VERSION, S.UTC_CREATED_DATE) ' +
'WHEN NOT MATCHED BY SOURCE THEN ' +
'    DELETE;'

+' UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE] '
+' SET dw_load_ts = GETUTCDATE() '
+' WHERE job_name = ''job_conops_equipment_hourly_status_' +@G_SITE+ '_2''' 
); 
  
END  
  

