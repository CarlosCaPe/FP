 
/******************************************************************    
* PROCEDURE : dbo.[UPSERT_CONOPS_CR2_MILL_2]  
* PURPOSE : Upsert [UPSERT_CONOPS_CR2_MILL_2]  
* NOTES     :   
* CREATED : mfahmi  
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_CR2_MILL_2]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {22 JUN 2023}    {mfahmi}    {Initial Created}
* {17 Oct 2023}    {GGOSAL1}   {Add Hourly Data}
* {31 Jan 2024}    {GGOSAL1}   {Handling timezone}
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_CR2_MILL_2]  
AS  
BEGIN  

DECLARE @CER_tz INT
SELECT @CER_tz = CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) FROM sys.time_zone_info  WHERE name = 'SA Pacific Standard Time' 

DECLARE @CLI_CHI_TYR_tz INT
SELECT @CLI_CHI_TYR_tz = CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) FROM sys.time_zone_info  WHERE name = 'Mountain Standard Time'

DECLARE @BAG_MOR_SAF_SIE_tz INT
SELECT @BAG_MOR_SAF_SIE_tz = CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) FROM sys.time_zone_info  WHERE name = 'US Mountain Standard Time'

DECLARE @ABR_tz INT
SELECT @ABR_tz = CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) FROM sys.time_zone_info  WHERE name = 'Pacific SA Standard Time'

INSERT INTO dbo.CR2_MILL_2
SELECT
	SHIFTINDEX
	,SITEFLAG
	,COMPONENT
	,CASE WHEN SITEFLAG = 'CER' THEN DATEADD(HOUR, @CER_tz, UTC_CREATED_DATE)
		WHEN SITEFLAG IN ('CHI','CLI','TYR') THEN DATEADD(HOUR, @CLI_CHI_TYR_tz, UTC_CREATED_DATE)
		WHEN SITEFLAG IN ('ABR','ELA') THEN DATEADD(HOUR, @ABR_tz, UTC_CREATED_DATE)
		ELSE DATEADD(HOUR, @BAG_MOR_SAF_SIE_tz, UTC_CREATED_DATE) END AS VALUE_TS
	,SENSOR_VALUE
	,UTC_CREATED_DATE
FROM dbo.CR2_MILL_STG_2;

--Update Job Control
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_cr2_mill_2';

   
END  


