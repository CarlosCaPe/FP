

  
  
  
/******************************************************************    
* PROCEDURE : dbo.[UPSERT_CONOPS_LH_REASON]  
* PURPOSE : Upsert [UPSERT_CONOPS_LH_REASON]  
* NOTES     :   
* CREATED : mfahmi  
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_LH_REASON]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {01 DEC 2022}  {mfahmi}    {Initial Created}    
* {19 MAY 2023}  {ggosal1}   {Add PK 'Reason'}    
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_LH_REASON]  
AS  
BEGIN  
  
MERGE dbo.LH_REASON AS T   
USING (SELECT   
  SHIFTINDEX  
 ,SHIFTDATE  
 ,SITE_CODE  
 ,CLIID  
 ,DDBKEY  
 ,NAME  
 ,REASON  
 ,STATUS  
 ,DELAYTIME  
 ,CATEGORY  
 ,MAINTTIME  
 ,SYSTEM_VERSION  
 ,UTC_CREATED_DATE   
 FROM dbo.LH_REASON_stg) AS S   
 ON (T.shiftindex = S.shiftindex   
 AND T.shiftdate = S.shiftdate   
 AND T.site_code = S.site_code   
 AND T.ddbkey = S.ddbkey  
 AND T.CLIID = S.CLIID
 AND T.Reason = S.Reason)   
  
 WHEN MATCHED   
 THEN UPDATE SET   
 T.NAME = S.NAME   
 ,T.STATUS = S.STATUS  
 ,T.DELAYTIME = S.DELAYTIME  
 ,T.CATEGORY = S.CATEGORY  
 ,T.MAINTTIME = S.MAINTTIME  
 ,T.SYSTEM_VERSION = S.SYSTEM_VERSION  
 ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE    
 WHEN NOT MATCHED   
 THEN INSERT (   
 SHIFTINDEX  
 ,SHIFTDATE  
 ,SITE_CODE  
 ,CLIID  
 ,DDBKEY  
 ,NAME  
 ,REASON  
 ,STATUS  
 ,DELAYTIME  
 ,CATEGORY  
 ,MAINTTIME  
 ,SYSTEM_VERSION  
 ,UTC_CREATED_DATE  
  ) VALUES(   
  S.SHIFTINDEX  
 ,S.SHIFTDATE  
 ,S.SITE_CODE  
 ,S.CLIID  
 ,S.DDBKEY  
 ,S.NAME  
 ,S.REASON  
 ,S.STATUS  
 ,S.DELAYTIME  
 ,S.CATEGORY  
 ,S.MAINTTIME  
 ,S.SYSTEM_VERSION  
 ,S.UTC_CREATED_DATE  
 );   
   
 
  --remove    
DELETE  
FROM  [dbo].[lh_reason]    
WHERE NOT EXISTS  
(SELECT 1  
FROM  dbo.[lh_reason_stg]  AS stg   
WHERE   
stg.SHIFTINDEX = [dbo].[lh_reason].SHIFTINDEX  
AND 
stg.SHIFTDATE = [dbo].[lh_reason].SHIFTDATE
AND
stg.SITE_CODE = [dbo].[lh_reason].SITE_CODE  
AND 
stg.CLIID = [dbo].[lh_reason].CLIID
AND
stg.DDBKEY = [dbo].[lh_reason].DDBKEY
AND 
stg.REASON = [dbo].[lh_reason].REASON
);   
   
   
   
END  
  
