CREATE VIEW [TYR].[CONOPS_TYR_GPS_ELEVATION_V] AS

  
  
  
    
--select * from [tyr].[CONOPS_TYR_GPS_ELEVATION_V] WITH (NOLOCK)    
CREATE VIEW [TYR].[CONOPS_TYR_GPS_ELEVATION_V]    
AS    
    
  
WITH CTE AS (  
SELECT  
ShiftIndex,  
EXCAV_NAME AS ShovelId,  
ROUND(shovel_dig_point_z,0) as ShovelElevation  
FROM [dbo].[shovel_elevation] WITH (NOLOCK)  
WHERE site_code = 'TYR')  
  
SELECT  
ShiftFlag,  
ShovelId,  
ShovelElevation  
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a   
LEFT JOIN CTE b ON a.SHIFTINDEX = b.SHIFTINDEX  
  
  
  
  
