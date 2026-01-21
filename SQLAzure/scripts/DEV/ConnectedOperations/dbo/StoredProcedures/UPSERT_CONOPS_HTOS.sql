
  
  
  
/******************************************************************    
* PROCEDURE : dbo.[UPSERT_CONOPS_HTOS]  
* PURPOSE : Upsert [UPSERT_CONOPS_HTOS]  
* NOTES     :   
* CREATED : mfahmi  
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_HTOS]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {14 APR 2023}  {mfahmi}   {Initial Created}    
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_HTOS]  
AS  
BEGIN  

DELETE FROM dbo.HTOS          
 WHERE SHIFTINDEX IN (SELECT SHIFTINDEX          
 FROM [DBO].[SHIFT_INFO_V]        
 WHERE --SITEFLAG = [dbo].[HTOS].SITE_CODE AND 
 SHIFTFLAG IN ('CURR','PREV') )  
  
INSERT INTO dbo.HTOS
SELECT B.SHIFTID, 
B.SHIFTINDEX, 
A.SITE_CODE,
A.OPERATOR_ID,
A.CREW,
A.HTOSDATE,
A.Travel_Loaded_Score,
A.Travel_Empty_Score,
A.Shovel_Score,
A.Dump_Score,
A.Total_Score,
A.UTC_CREATED_DATE
FROM (
SELECT 
'PREV' AS SHIFTFLAG, * from dbo.htos_stg
UNION ALL
SELECT 
'CURR' AS SHIFTFLAG, * from dbo.htos_stg
) A LEFT JOIN dbo.shift_info_v B 
ON A.SITE_CODE = B.SITEFLAG
AND A.SHIFTFLAG = B.SHIFTFLAG



 
 

   
   
END  
  

