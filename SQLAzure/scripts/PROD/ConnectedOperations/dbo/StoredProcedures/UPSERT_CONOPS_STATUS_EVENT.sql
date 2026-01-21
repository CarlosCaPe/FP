
    
    
    
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_STATUS_EVENT]    
* PURPOSE : UPSERT [UPSERT_CONOPS_STATUS_EVENT]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_STATUS_EVENT]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
*******************************************************************/      
CREATE  PROCEDURE [DBO].[UPSERT_CONOPS_STATUS_EVENT]    
AS    
BEGIN    
    
MERGE DBO.STATUS_EVENT AS T     
USING (SELECT     
  SHIFTINDEX    
 ,SHIFTDATE    
 ,SITE_CODE    
 ,CLIID    
 ,DDBKEY    
 ,EQMT    
 ,UNIT    
 ,OPERID    
 ,STARTTIME    
 ,ENDTIME    
 ,DURATION    
 ,REASON    
 ,STATUS    
 ,CATEGORY    
 ,COMMENTS    
 ,VEVENT    
 ,REASONLINK    
 ,WORK_ORDER_NUMBER    
 ,DISTRICT_CODE    
 ,EQMTID_ORIG    
 ,LOC    
 ,REGION    
 ,SYSTEM_VERSION    
 ,DW_MODIFY_TS    
 ,DW_LOAD_TS    
 ,UTC_CREATED_DATE     
 FROM DBO.STATUS_EVENT_STG) AS S     
 ON (T.SHIFTINDEX = S.SHIFTINDEX     
 AND T.SHIFTDATE = S.SHIFTDATE     
 AND T.SITE_CODE = S.SITE_CODE     
 AND T.DDBKEY = S.DDBKEY    
 AND T.STARTTIME = S.STARTTIME    
 AND T.CATEGORY = S.CATEGORY )     
    
 WHEN MATCHED     
 THEN UPDATE SET     
  T.CLIID = S.CLIID    
 ,T.EQMT = S.EQMT    
 ,T.UNIT = S.UNIT    
 ,T.OPERID = S.OPERID    
 ,T.ENDTIME = S.ENDTIME    
 ,T.DURATION = S.DURATION    
 ,T.REASON = S.REASON    
 ,T.STATUS = S.STATUS    
 ,T.COMMENTS = S.COMMENTS    
 ,T.VEVENT = S.VEVENT    
 ,T.REASONLINK = S.REASONLINK    
 ,T.WORK_ORDER_NUMBER = S.WORK_ORDER_NUMBER    
 ,T.DISTRICT_CODE = S.DISTRICT_CODE    
 ,T.EQMTID_ORIG = S.EQMTID_ORIG    
 ,T.LOC = S.LOC    
 ,T.REGION = S.REGION    
 ,T.SYSTEM_VERSION = S.SYSTEM_VERSION    
 ,T.DW_MODIFY_TS = S.DW_MODIFY_TS    
 ,T.DW_LOAD_TS = S.DW_LOAD_TS    
 ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE      
 WHEN NOT MATCHED     
 THEN INSERT (     
 SHIFTINDEX    
 ,SHIFTDATE    
 ,SITE_CODE    
 ,CLIID    
 ,DDBKEY    
 ,EQMT    
 ,UNIT    
 ,OPERID    
 ,STARTTIME    
 ,ENDTIME    
 ,DURATION    
 ,REASON    
 ,STATUS    
 ,CATEGORY    
 ,COMMENTS    
 ,VEVENT    
 ,REASONLINK    
 ,WORK_ORDER_NUMBER    
 ,DISTRICT_CODE    
 ,EQMTID_ORIG    
 ,LOC    
 ,REGION    
 ,SYSTEM_VERSION    
 ,DW_MODIFY_TS    
 ,DW_LOAD_TS     
 ,UTC_CREATED_DATE    
  ) VALUES(     
  S.SHIFTINDEX    
 ,S.SHIFTDATE    
 ,S.SITE_CODE    
 ,S.CLIID    
 ,S.DDBKEY    
 ,S.EQMT    
 ,S.UNIT    
 ,S.OPERID    
 ,S.STARTTIME    
 ,S.ENDTIME    
 ,S.DURATION    
 ,S.REASON    
 ,S.STATUS    
 ,S.CATEGORY    
 ,S.COMMENTS    
 ,S.VEVENT    
 ,S.REASONLINK    
 ,S.WORK_ORDER_NUMBER    
 ,S.DISTRICT_CODE    
 ,S.EQMTID_ORIG    
 ,S.LOC    
 ,S.REGION    
 ,S.SYSTEM_VERSION    
 ,S.DW_MODIFY_TS    
 ,S.DW_LOAD_TS    
 ,S.UTC_CREATED_DATE    
 );     
     
  --REMOVE      
DELETE    
FROM  [DBO].[STATUS_EVENT]      
WHERE NOT EXISTS    
(SELECT 1    
FROM  DBO.[STATUS_EVENT_STG]  AS STG     
WHERE     
STG.SHIFTINDEX = [DBO].[STATUS_EVENT].SHIFTINDEX    
AND   
STG.SHIFTDATE = [DBO].[STATUS_EVENT].SHIFTDATE  
AND  
STG.SITE_CODE = [DBO].[STATUS_EVENT].SITE_CODE    
AND   
STG.STARTTIME = [DBO].[STATUS_EVENT].STARTTIME  
AND  
STG.DDBKEY = [DBO].[STATUS_EVENT].DDBKEY  
AND  
STG.CATEGORY = [DBO].[STATUS_EVENT].CATEGORY  
  
);     
     
     
     
END    
    
