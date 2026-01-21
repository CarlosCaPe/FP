
  
  
  
/******************************************************************    
* PROCEDURE : DBO.[UPSERT_CONOPS_LH_OPER_TOTAL_SUM]  
* PURPOSE : UPSERT [UPSERT_CONOPS_LH_OPER_TOTAL_SUM]  
* NOTES     :   
* CREATED : MFAHMI  
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_LH_OPER_TOTAL_SUM]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {01 DEC 2022}  {MFAHMI}   {INITIAL CREATED}    
*******************************************************************/    
CREATE  PROCEDURE [DBO].[UPSERT_CONOPS_LH_OPER_TOTAL_SUM]  
AS  
BEGIN  
  
DELETE FROM DBO.LH_OPER_TOTAL_SUM  
  
INSERT INTO DBO.LH_OPER_TOTAL_SUM  
SELECT   
  SHIFTINDEX  
  ,SHIFTDATE  
  ,SITE_CODE  
  ,CLIID  
  ,DDBKEY  
  ,EQMTID  
  ,EQMTID_ORIG  
  ,IDLETIME  
  ,LOADCNT  
  ,LOADTIME  
  ,LOCID  
  ,LOGINTIME  
  ,NAME  
  ,OPERID  
  ,PIT  
  ,SPOTTIME  
  ,TMCAT00  
  ,TMCAT01  
  ,TMCAT02  
  ,TMCAT03  
  ,TMCAT04  
  ,TMCAT05  
  ,TMCAT06  
  ,TMCAT07  
  ,TMCAT08  
  ,TMCAT09  
  ,TMCAT10  
  ,TMCAT11  
  ,TMCAT12  
  ,TMCAT13  
  ,TMCAT14  
  ,TMCAT15  
  ,TMCAT16  
  ,TMCAT17  
  ,TMCAT18  
  ,TMCAT19  
  ,TOTALLOADS  
  ,TOTALTIME  
  ,TOTALTONS  
  ,UNIT  
  ,UNIT_CODE  
  ,SYSTEM_VERSION  
  ,UTC_CREATED_DATE  
 FROM DBO.LH_OPER_TOTAL_SUM_STG  
   
END  
  
