    
    
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_SHIFT_DATE]    
* PURPOSE : UPSERT [UPSERT_CONOPS_SHIFT_DATE]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_SHIFT_DATE]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
*******************************************************************/      
CREATE  PROCEDURE [DBO].[UPSERT_CONOPS_SHIFT_DATE]    
AS    
BEGIN    
    
MERGE DBO.SHIFT_DATE AS T     
USING (SELECT     
  SHIFTINDEX    
 ,SHIFTDATE    
 ,SITE_CODE    
 ,CLIID    
 ,NAME    
 ,YEARS    
 ,MONTH_CODE    
 ,MONTHS    
 ,DAYS    
 ,SHIFT_CODE    
 ,SHIFT    
 ,DATES    
 ,STARTS    
 ,LEN    
 ,DISPTIME    
 ,UTC_CREATED_DATE     
 ,UTC_LOGICAL_DELETED_DATE    
 FROM DBO.SHIFT_DATE_STG) AS S     
 ON (T.SHIFTINDEX = S.SHIFTINDEX     
 AND T.SHIFTDATE = S.SHIFTDATE     
 AND T.SITE_CODE = S.SITE_CODE )     
    
 WHEN MATCHED     
 THEN UPDATE SET     
  T.CLIID = S.CLIID    
 ,T.NAME = S.NAME    
 ,T.YEARS = S.YEARS    
 ,T.MONTH_CODE = S.MONTH_CODE    
 ,T.MONTHS = S.MONTHS    
 ,T.DAYS = S.DAYS    
 ,T.SHIFT_CODE = S.SHIFT_CODE    
 ,T.SHIFT = S.SHIFT    
 ,T.DATES = S.DATES    
 ,T.STARTS = S.STARTS    
 ,T.LEN = S.LEN    
 ,T.DISPTIME = S.DISPTIME    
 ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE     
 ,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE    
 WHEN NOT MATCHED     
 THEN INSERT (     
 SHIFTINDEX    
 ,SHIFTDATE    
 ,SITE_CODE    
 ,CLIID    
 ,NAME    
 ,YEARS    
 ,MONTH_CODE    
 ,MONTHS    
 ,DAYS    
 ,SHIFT_CODE    
 ,SHIFT    
 ,DATES    
 ,STARTS    
 ,LEN    
 ,DISPTIME    
 ,UTC_CREATED_DATE     
 ,UTC_LOGICAL_DELETED_DATE    
  ) VALUES(     
  S.SHIFTINDEX    
 ,S.SHIFTDATE    
 ,S.SITE_CODE    
 ,S.CLIID    
 ,S.NAME    
 ,S.YEARS    
 ,S.MONTH_CODE    
 ,S.MONTHS    
 ,S.DAYS    
 ,S.SHIFT_CODE    
 ,S.SHIFT    
 ,S.DATES    
 ,S.STARTS    
 ,S.LEN    
 ,S.DISPTIME    
 ,S.UTC_CREATED_DATE     
 ,S.UTC_LOGICAL_DELETED_DATE    
 );     
     
  
     --REMOVE      
DELETE    
FROM  [DBO].[SHIFT_DATE]      
WHERE NOT EXISTS    
(SELECT 1    
FROM  DBO.[SHIFT_DATE_STG]  AS STG     
WHERE     
STG.SHIFTINDEX = [DBO].[SHIFT_DATE].SHIFTINDEX    
AND   
STG.SHIFTDATE = [DBO].[SHIFT_DATE].SHIFTDATE  
AND  
STG.SITE_CODE = [DBO].[SHIFT_DATE].SITE_CODE    
  
);     
  
END    
  
