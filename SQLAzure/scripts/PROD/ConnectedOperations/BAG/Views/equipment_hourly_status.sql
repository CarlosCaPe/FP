CREATE VIEW [BAG].[equipment_hourly_status] AS

--SELECT * FROM [bag].[equipment_hourly_status] WITH (NOLOCK)  
CREATE VIEW [bag].[equipment_hourly_status]     
AS

SELECT 
*
FROM bag2.equipment_hourly_status ae WITH(NOLOCK)

