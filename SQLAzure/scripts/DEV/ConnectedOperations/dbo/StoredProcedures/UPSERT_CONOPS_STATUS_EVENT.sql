  
  
  
/******************************************************************    
* PROCEDURE : dbo.[UPSERT_CONOPS_STATUS_EVENT]  
* PURPOSE : Upsert [UPSERT_CONOPS_STATUS_EVENT]  
* NOTES     :   
* CREATED : lwasini  
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_STATUS_EVENT]   
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {25 OCT 2022}  {lwasini}   {Initial Created}    
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_STATUS_EVENT]  
AS  
BEGIN  
  
MERGE dbo.STATUS_EVENT AS T   
USING (SELECT   
  shiftindex  
 ,shiftdate  
 ,site_code  
 ,cliid  
 ,ddbkey  
 ,eqmt  
 ,unit  
 ,operid  
 ,starttime  
 ,endtime  
 ,duration  
 ,reason  
 ,status  
 ,category  
 ,comments  
 ,vevent  
 ,reasonlink  
 ,work_order_number  
 ,district_code  
 ,eqmtid_orig  
 ,loc  
 ,region  
 ,system_version  
 ,dw_modify_ts  
 ,dw_load_ts  
 ,UTC_CREATED_DATE   
 FROM dbo.STATUS_EVENT_stg) AS S   
 ON (T.shiftindex = S.shiftindex   
 AND T.shiftdate = S.shiftdate   
 AND T.site_code = S.site_code   
 AND T.ddbkey = S.ddbkey  
 AND T.starttime = S.starttime  
 AND T.category = S.category )   
  
 WHEN MATCHED   
 THEN UPDATE SET   
  T.cliid = S.cliid  
 ,T.eqmt = S.eqmt  
 ,T.unit = S.unit  
 ,T.operid = S.operid  
 ,T.endtime = S.endtime  
 ,T.duration = S.duration  
 ,T.reason = S.reason  
 ,T.status = S.status  
 ,T.comments = S.comments  
 ,T.vevent = S.vevent  
 ,T.reasonlink = S.reasonlink  
 ,T.work_order_number = S.work_order_number  
 ,T.district_code = S.district_code  
 ,T.eqmtid_orig = S.eqmtid_orig  
 ,T.loc = S.loc  
 ,T.region = S.region  
 ,T.system_version = S.system_version  
 ,T.dw_modify_ts = S.dw_modify_ts  
 ,T.dw_load_ts = S.dw_load_ts  
 ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE    
 WHEN NOT MATCHED   
 THEN INSERT (   
 shiftindex  
 ,shiftdate  
 ,site_code  
 ,cliid  
 ,ddbkey  
 ,eqmt  
 ,unit  
 ,operid  
 ,starttime  
 ,endtime  
 ,duration  
 ,reason  
 ,status  
 ,category  
 ,comments  
 ,vevent  
 ,reasonlink  
 ,work_order_number  
 ,district_code  
 ,eqmtid_orig  
 ,loc  
 ,region  
 ,system_version  
 ,dw_modify_ts  
 ,dw_load_ts   
 ,UTC_CREATED_DATE  
  ) VALUES(   
  S.shiftindex  
 ,S.shiftdate  
 ,S.site_code  
 ,S.cliid  
 ,S.ddbkey  
 ,S.eqmt  
 ,S.unit  
 ,S.operid  
 ,S.starttime  
 ,S.endtime  
 ,S.duration  
 ,S.reason  
 ,S.status  
 ,S.category  
 ,S.comments  
 ,S.vevent  
 ,S.reasonlink  
 ,S.work_order_number  
 ,S.district_code  
 ,S.eqmtid_orig  
 ,S.loc  
 ,S.region  
 ,S.system_version  
 ,S.dw_modify_ts  
 ,S.dw_load_ts  
 ,S.UTC_CREATED_DATE  
 );   
   
  --remove    
DELETE  
FROM  [dbo].[STATUS_EVENT]    
WHERE NOT EXISTS  
(SELECT 1  
FROM  dbo.[STATUS_EVENT_stg]  AS stg   
WHERE   
stg.SHIFTINDEX = [dbo].[STATUS_EVENT].SHIFTINDEX  
AND 
stg.SHIFTDATE = [dbo].[STATUS_EVENT].SHIFTDATE
AND
stg.SITE_CODE = [dbo].[STATUS_EVENT].SITE_CODE  
AND 
stg.starttime = [dbo].[STATUS_EVENT].starttime
AND
stg.DDBKEY = [dbo].[STATUS_EVENT].DDBKEY
AND
stg.CATEGORY = [dbo].[STATUS_EVENT].CATEGORY

);   
   
   
   
END  
  
