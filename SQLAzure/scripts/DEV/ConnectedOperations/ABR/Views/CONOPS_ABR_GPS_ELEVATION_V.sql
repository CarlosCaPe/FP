CREATE VIEW [ABR].[CONOPS_ABR_GPS_ELEVATION_V] AS
  
  
  
    
--select * from [abr].[CONOPS_ABR_GPS_ELEVATION_V] WITH (NOLOCK)    
CREATE VIEW [abr].[CONOPS_ABR_GPS_ELEVATION_V]    
AS    
    
  
WITH CTE AS (  
SELECT  
ShiftIndex,  
EXCAV_NAME AS ShovelId,  
ROUND(shovel_dig_point_z,0) as ShovelElevation  
FROM [dbo].[shovel_elevation] WITH (NOLOCK)  
WHERE site_code = 'ELA')  
  
SELECT  
ShiftFlag,  
ShovelId,  
ShovelElevation  
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a   
LEFT JOIN CTE b ON a.SHIFTINDEX = b.SHIFTINDEX  
  
  
  
  
