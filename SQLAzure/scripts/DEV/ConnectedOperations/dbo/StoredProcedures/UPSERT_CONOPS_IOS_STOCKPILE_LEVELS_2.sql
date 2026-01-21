

/******************************************************************    
* PROCEDURE : DBO.[UPSERT_CONOPS_IOS_STOCKPILE_LEVELS_2]  
* PURPOSE	: UPSERT [UPSERT_CONOPS_IOS_STOCKPILE_LEVELS_2]  
* NOTES     :   
* CREATED	: GGOSAL1  
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_IOS_STOCKPILE_LEVELS_2]  
* MODIFIED DATE		AUTHOR		DESCRIPTION    
*------------------------------------------------------------------    
* {25 May 2023}    {GGOSAL1}   {INITIAL CREATED}    
* {17 Oct 2023}    {GGOSAL1}   {Add Hourly Data} 
* {31 Jan 2024}    {GGOSAL1}   {Handling timezone} 
*******************************************************************/    
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_IOS_STOCKPILE_LEVELS_2]  
 
AS  
BEGIN

DECLARE @CER_tz INT
SELECT @CER_tz = CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) FROM sys.time_zone_info  WHERE name = 'SA Pacific Standard Time' 

DECLARE @CLI_CHI_TYR_tz INT
SELECT @CLI_CHI_TYR_tz = CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) FROM sys.time_zone_info  WHERE name = 'Mountain Standard Time'

DECLARE @BAG_MOR_SAF_SIE_tz INT
SELECT @BAG_MOR_SAF_SIE_tz = CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) FROM sys.time_zone_info  WHERE name = 'US Mountain Standard Time'

DECLARE @ABR_tz INT
SELECT @ABR_tz = CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) FROM sys.time_zone_info  WHERE name = 'Pacific SA Standard Time';


--TRUNCATE TABLE dbo.IOS_STOCKPILE_LEVELS_2 ;--WHY adding truncate here? It should not be.

INSERT INTO dbo.IOS_STOCKPILE_LEVELS_2(
	SHIFTINDEX
	,SITEFLAG
	,CRUSHERLOC
	,COMPONENT
	,VALUE_TS
	,SENSORVALUE
	,UTC_CREATED_DATE
)
SELECT
	SHIFTINDEX
	,SITEFLAG
	,CRUSHERLOC
	,COMPONENT
	,CASE WHEN SITEFLAG = 'CER' THEN DATEADD(HOUR, @CER_tz, UTC_CREATED_DATE)
		WHEN SITEFLAG IN ('CHI','CLI','TYR') THEN DATEADD(HOUR, @CLI_CHI_TYR_tz, UTC_CREATED_DATE)
		WHEN SITEFLAG IN ('ABR','ELA') THEN DATEADD(HOUR, @ABR_tz, UTC_CREATED_DATE)
		ELSE DATEADD(HOUR, @BAG_MOR_SAF_SIE_tz, UTC_CREATED_DATE) END AS VALUE_TS
	,SENSOR_VALUE
	,UTC_CREATED_DATE
FROM dbo.IOS_STOCKPILE_LEVELS_STG_2


END  
  


