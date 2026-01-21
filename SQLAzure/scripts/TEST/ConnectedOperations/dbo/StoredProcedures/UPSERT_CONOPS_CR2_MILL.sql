




  
  
  
/******************************************************************    
* PROCEDURE : dbo.[UPSERT_CONOPS_CR2_MILL]  
* PURPOSE : Upsert [UPSERT_CONOPS_CR2_MILL]  
* NOTES     :   
* CREATED : mfahmi  
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_CR2_MILL]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {22 JUN 2023}    {mfahmi}    {Initial Created}
* {17 Oct 2023}    {GGOSAL1}   {Add Hourly Data}
* {31 Jan 2024}    {GGOSAL1}   {Handling timezone}
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_CR2_MILL]  
AS  
BEGIN  

DECLARE @CER_tz INT
SELECT @CER_tz = current_utc_offset FROM [CER].[CONOPS_CER_SHIFT_INFO_V] WHERE SHIFTFLAG = 'CURR'

DECLARE @CLI_CHI_TYR_tz INT
SELECT @CLI_CHI_TYR_tz = current_utc_offset FROM [CLI].[CONOPS_CLI_SHIFT_INFO_V] WHERE SHIFTFLAG = 'CURR'

DECLARE @BAG_MOR_SAF_SIE_tz INT
SELECT @BAG_MOR_SAF_SIE_tz = current_utc_offset FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] WHERE SHIFTFLAG = 'CURR'

--DECLARE @ABR_tz INT
--SELECT @ABR_tz = current_utc_offset FROM [ABR].[CONOPS_ABR_SHIFT_INFO_V] WHERE SHIFTFLAG = 'CURR'

INSERT INTO dbo.CR2_MILL
SELECT
	SHIFTINDEX
	,SITEFLAG
	,COMPONENT
	,CASE WHEN SITEFLAG = 'CER' THEN DATEADD(HOUR, @CER_tz, UTC_CREATED_DATE)
		WHEN SITEFLAG IN ('CHI','CLI','TYR') THEN DATEADD(HOUR, @CLI_CHI_TYR_tz, UTC_CREATED_DATE)
		--WHEN SITEFLAG IN ('ABR','ELA') THEN DATEADD(HOUR, @ABR_tz, UTC_CREATED_DATE)
		ELSE DATEADD(HOUR, @BAG_MOR_SAF_SIE_tz, UTC_CREATED_DATE) END AS VALUE_TS
	,SENSOR_VALUE
	,UTC_CREATED_DATE
FROM dbo.CR2_MILL_STG

   
END  
  



