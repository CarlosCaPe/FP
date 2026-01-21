CREATE VIEW [bag].[CONOPS_BAG_GPS_ELEVATION_V] AS

  
--select * from [bag].[CONOPS_BAG_GPS_ELEVATION_V] WITH (NOLOCK)  
CREATE VIEW [bag].[CONOPS_BAG_GPS_ELEVATION_V]  
AS  
  

WITH CTE AS (
SELECT
ShiftIndex,
EXCAV_NAME AS ShovelId,
ROUND(shovel_dig_point_z,0) as ShovelElevation
FROM [dbo].[shovel_elevation] WITH (NOLOCK)
WHERE site_code = 'BAG')

SELECT
ShiftFlag,
ShovelId,
ShovelElevation
FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] a 
LEFT JOIN CTE b ON a.SHIFTINDEX = b.SHIFTINDEX


