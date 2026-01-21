CREATE VIEW [SIE].[CONOPS_SIE_GPS_ELEVATION_V] AS


  
--select * from [sie].[CONOPS_SIE_GPS_ELEVATION_V] WITH (NOLOCK)  
CREATE VIEW [sie].[CONOPS_SIE_GPS_ELEVATION_V]  
AS  
  

WITH CTE AS (
SELECT
ShiftIndex,
EXCAV_NAME AS ShovelId,
ROUND(shovel_dig_point_z,0) as ShovelElevation
FROM [dbo].[shovel_elevation] WITH (NOLOCK)
WHERE site_code = 'SIE')

SELECT
ShiftFlag,
ShovelId,
ShovelElevation
FROM [SIE].[CONOPS_SIE_SHIFT_INFO_V] a 
LEFT JOIN CTE b ON a.SHIFTINDEX = b.SHIFTINDEX



