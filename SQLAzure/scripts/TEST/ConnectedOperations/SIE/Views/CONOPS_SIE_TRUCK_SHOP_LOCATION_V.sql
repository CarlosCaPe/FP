CREATE VIEW [SIE].[CONOPS_SIE_TRUCK_SHOP_LOCATION_V] AS




-- SELECT * FROM [bag].[CONOPS_SIE_TRUCK_SHOP_LOCATION_V] WITH (NOLOCK)
CREATE VIEW [sie].[CONOPS_SIE_TRUCK_SHOP_LOCATION_V] 
AS

SELECT loc.[FieldId] AS Name,
	   CONVERT(REAL, enumUnit.[Idx]) AS Unit,
	   region.[FieldId] AS Region,
	   CONVERT(REAL, loc.[FieldXloc]) AS X,
	   CONVERT(REAL, loc.[FieldYloc]) AS Y,
	   CONVERT(REAL, loc.[FieldZloc]) AS Z
FROM [sie].[pit_loc] [loc] WITH (NOLOCK)
LEFT JOIN [sie].[enum] enumUnit WITH (NOLOCK)
ON [loc].FieldUnit = enumUnit.Id
LEFT JOIN [sie].[pit_loc] [region] WITH (NOLOCK)
ON loc.FieldRegion = [region].Id
WHERE enumUnit.[Idx] in (7,8)--shop/tiedown/or Q-point locations

