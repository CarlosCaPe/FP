  
  
  
/******************************************************************    
* PROCEDURE : dbo.[UPSERT_CONOPS_SHIFT_DATE]  
* PURPOSE : Upsert [UPSERT_CONOPS_SHIFT_DATE]  
* NOTES     :   
* CREATED : lwasini  
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_SHIFT_DATE]   
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {25 OCT 2022}  {lwasini}   {Initial Created}    
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_DATE]  
AS  
BEGIN  
  
MERGE dbo.SHIFT_DATE AS T   
USING (SELECT   
  shiftindex  
 ,shiftdate  
 ,site_code  
 ,cliid  
 ,name  
 ,years  
 ,month_code  
 ,months  
 ,days  
 ,shift_code  
 ,shift  
 ,dates  
 ,starts  
 ,len  
 ,disptime  
 ,UTC_CREATED_DATE   
 ,UTC_LOGICAL_DELETED_DATE  
 FROM dbo.SHIFT_DATE_stg) AS S   
 ON (T.shiftindex = S.shiftindex   
 AND T.shiftdate = S.shiftdate   
 AND T.site_code = S.site_code )   
  
 WHEN MATCHED   
 THEN UPDATE SET   
  T.cliid = S.cliid  
 ,T.name = S.name  
 ,T.years = S.years  
 ,T.month_code = S.month_code  
 ,T.months = S.months  
 ,T.days = S.days  
 ,T.shift_code = S.shift_code  
 ,T.shift = S.shift  
 ,T.dates = S.dates  
 ,T.starts = S.starts  
 ,T.len = S.len  
 ,T.disptime = S.disptime  
 ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE   
 ,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE  
 WHEN NOT MATCHED   
 THEN INSERT (   
 shiftindex  
 ,shiftdate  
 ,site_code  
 ,cliid  
 ,name  
 ,years  
 ,month_code  
 ,months  
 ,days  
 ,shift_code  
 ,shift  
 ,dates  
 ,starts  
 ,len  
 ,disptime  
 ,UTC_CREATED_DATE   
 ,UTC_LOGICAL_DELETED_DATE  
  ) VALUES(   
  S.shiftindex  
 ,S.shiftdate  
 ,S.site_code  
 ,S.cliid  
 ,S.name  
 ,S.years  
 ,S.month_code  
 ,S.months  
 ,S.days  
 ,S.shift_code  
 ,S.shift  
 ,S.dates  
 ,S.starts  
 ,S.len  
 ,S.disptime  
 ,S.UTC_CREATED_DATE   
 ,S.UTC_LOGICAL_DELETED_DATE  
 );   
   

     --remove    
DELETE  
FROM  [dbo].[SHIFT_DATE]    
WHERE NOT EXISTS  
(SELECT 1  
FROM  dbo.[SHIFT_DATE_stg]  AS stg   
WHERE   
stg.SHIFTINDEX = [dbo].[SHIFT_DATE].SHIFTINDEX  
AND 
stg.SHIFTDATE = [dbo].[SHIFT_DATE].SHIFTDATE
AND
stg.SITE_CODE = [dbo].[SHIFT_DATE].SITE_CODE  

);   

END  

