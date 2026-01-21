




/******************************************************************    
* PROCEDURE		: dbo.[UPSERT_CONOPS_SHOVEL_ELEVATION]  
* PURPOSE		: Upsert [UPSERT_CONOPS_SHOVEL_ELEVATION]  
* NOTES			:   
* CREATED		: mfahmi  
* SAMPLE		: EXEC dbo.[UPSERT_CONOPS_SHOVEL_ELEVATION]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {19 MAY 2023}  {mfahmi}   {Initial Created}   
* {19 MAY 2023}  {ggosal1}  {Update the job}   
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_SHOVEL_ELEVATION]  
AS  
BEGIN  
  
MERGE dbo.SHOVEL_ELEVATION AS T   
USING (SELECT   
SITE_CODE
,SHIFTINDEX
,EXCAV_NAME
,SHOVEL_DIG_POINT_Z
,TIME_END_LOCAL_TS
,UTC_CREATED_DATE
FROM dbo.SHOVEL_ELEVATION_STG) AS S   
ON (T.SITE_CODE = S.SITE_CODE   
AND T.SHIFTINDEX = S.SHIFTINDEX
AND T.EXCAV_NAME = S.EXCAV_NAME)   
  
WHEN MATCHED   
THEN UPDATE SET   

T.SHOVEL_DIG_POINT_Z = S.SHOVEL_DIG_POINT_Z
,T.TIME_END_LOCAL_TS = S.TIME_END_LOCAL_TS
,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE
WHEN NOT MATCHED   
THEN INSERT (   
SITE_CODE
,SHIFTINDEX
,EXCAV_NAME
,SHOVEL_DIG_POINT_Z
,TIME_END_LOCAL_TS
,UTC_CREATED_DATE
 
) VALUES(   
S.SITE_CODE
,S.SHIFTINDEX
,S.EXCAV_NAME
,S.SHOVEL_DIG_POINT_Z
,S.TIME_END_LOCAL_TS
,S.UTC_CREATED_DATE

 ); 

 
END  
  

