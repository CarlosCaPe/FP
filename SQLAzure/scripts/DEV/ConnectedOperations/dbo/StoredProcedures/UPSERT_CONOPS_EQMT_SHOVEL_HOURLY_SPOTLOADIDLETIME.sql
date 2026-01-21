



/******************************************************************    
* PROCEDURE : DBO.[UPSERT_CONOPS_EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME]  
* PURPOSE	: UPSERT [UPSERT_CONOPS_EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME]  
* NOTES     :   
* CREATED	: ggosal1
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME]   
* MODIFIED DATE		AUTHOR		  DESCRIPTION    
*------------------------------------------------------------------    
* {05 JAN 2023}	   {ggosal1}   {INITIAL CREATED}    
*******************************************************************/    
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME]  
 
AS  
BEGIN  
EXEC   
(  
'MERGE DBO.EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME AS T '  
+' USING (SELECT '  
+'  site_code'  
+'  ,shiftindex'    
+'  ,Equipment'  
+'  ,idletime'  
+'  ,spottime'  
+'  ,loadtime'  
+'  ,UTC_CREATED_DATE'  
+'  FROM DBO.EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME_STG) AS S '  
+'  ON  (T.site_code = S.site_code ) '  
+'  AND (T.shiftindex = S.shiftindex ) '  
+'  AND (T.Equipment = S.Equipment ) '  
+'  WHEN MATCHED '  
+'  THEN UPDATE SET T.idletime = S.idletime '  
+'  ,T.spottime = S.spottime '  
+'  ,T.loadtime = S.loadtime '   
+'  ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '   
+'  WHEN NOT MATCHED '  
+'  THEN INSERT ( '  
+'  site_code'  
+'  ,shiftindex'  
+'  ,Equipment' 
+'  ,idletime'  
+'  ,spottime'   
+'  ,loadtime'   
+'  ,UTC_CREATED_DATE'  
+'   ) VALUES( '  
+'  S.site_code'  
+'  ,S.shiftindex' 
+'  ,S.Equipment'  
+'  ,S.idletime'  
+'  ,S.spottime'  
+'  ,S.loadtime'   
+'  ,S.UTC_CREATED_DATE'    
+'  ); '  
  
 );  
END  
  
