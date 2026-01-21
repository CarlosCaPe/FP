CREATE VIEW [cli].[CONOPS_CLI_GPS_ELEVATION_EXT_V] AS
  
  
  
  
--select * from [cli].[CONOPS_CLI_GPS_ELEVATION_EXT_V] WITH (NOLOCK)  
CREATE VIEW [cli].[CONOPS_CLI_GPS_ELEVATION_EXT_V]  
 AS  
 


WITH CTE AS (  
SELECT
 siteflag,
 shiftid,
 sensor_id,
 shovelId,
 sensor_value,
 value_utc_ts, 
 UTC_CREATED_DATE, 
 ROW_NUMBER() OVER (PARTITION BY sensor_id ORDER BY value_utc_ts DESC) num 
 from [dbo].[shovel_elevation_ext]  
 ),  
  
FINAL AS (  
SELECT   
 siteflag,
 shiftid,
 CASE WHEN num = 1 THEN 'CURR' ELSE 'PREV' END AS shiftflag,
 sensor_id,
 shovelId,
 sensor_value,
 value_utc_ts 
FROM CTE    
WHERE siteflag = 'CLI' AND num IN ('1','2') )

SELECT  
 siteflag,
 shiftflag,
 sensor_id,
 shovelId,
 sensor_value,
 value_utc_ts 
FROM Final  