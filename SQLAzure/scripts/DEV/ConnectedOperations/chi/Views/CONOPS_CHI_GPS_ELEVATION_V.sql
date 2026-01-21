CREATE VIEW [chi].[CONOPS_CHI_GPS_ELEVATION_V] AS

  
--select * from [chi].[CONOPS_CHI_GPS_ELEVATION_V] WITH (NOLOCK)  
CREATE VIEW [chi].[CONOPS_CHI_GPS_ELEVATION_V]  
AS  
  

WITH CTE AS (
SELECT
ShiftIndex,
EXCAV_NAME AS ShovelId,
ROUND(shovel_dig_point_z,0) as ShovelElevation
FROM [dbo].[shovel_elevation] WITH (NOLOCK)
WHERE site_code = 'CHI')

SELECT
ShiftFlag,
ShovelId,
ShovelElevation
FROM [CHI].[CONOPS_CHI_SHIFT_INFO_V] a 
LEFT JOIN CTE b ON a.SHIFTINDEX = b.SHIFTINDEX


