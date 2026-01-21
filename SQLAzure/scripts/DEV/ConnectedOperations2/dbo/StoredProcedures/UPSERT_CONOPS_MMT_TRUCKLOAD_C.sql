

    
    
    
    
/******************************************************************      
* PROCEDURE : dbo.[UPSERT_CONOPS_MMT_TRUCKLOAD_C]    
* PURPOSE : Upsert [UPSERT_CONOPS_MMT_TRUCKLOAD_C]    
* NOTES     :     
* CREATED : mfahmi    
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_MMT_TRUCKLOAD_C]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {05 JUN 2023}  {mfahmi}		{Initial Created}      
* {31 OCT 2023}  {ggosal1}		{Add new column OXIDE_SULFIDE_RATIO, FE_PCT, PB_PCT} 
*******************************************************************/      
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_MMT_TRUCKLOAD_C]    
AS    
BEGIN    
    
DELETE FROM dbo.MMT_TRUCKLOAD_C    
    
INSERT INTO dbo.MMT_TRUCKLOAD_C    
 SELECT     
 LOAD_SHIFTINDEX  
,SITE_CODE  
,LOAD_EXCAV  
,LOAD_TRUCK  
,LOAD_LOC  
,DUMP_LOC  
,TCU_PCT  
,TMO_PCT  
,TCLAY_PCT  
,XCU_PCT  
,KAOLINITE_PCT  
,ASCU_PCT  
,SWELLING_CLAY_PCT  
,SDR_P80  
,DUMPTONS
,OXIDE_SULFIDE_RATIO
,FE_PCT
,PB_PCT
,TIMELOAD_TS
,TIMEDUMP_TS
,UTC_CREATED_DATE    
 FROM dbo.MMT_TRUCKLOAD_C_STG      
     
END    
    
    

