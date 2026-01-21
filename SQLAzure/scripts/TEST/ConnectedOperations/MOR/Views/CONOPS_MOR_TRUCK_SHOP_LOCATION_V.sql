CREATE VIEW [MOR].[CONOPS_MOR_TRUCK_SHOP_LOCATION_V] AS




CREATE VIEW [mor].[CONOPS_MOR_TRUCK_SHOP_LOCATION_V] 
AS

SELECT loc.[FieldId] AS Name,
	   CONVERT(REAL, enumUnit.[Idx]) AS Unit,
	   region.[FieldId] AS Region,
	   CONVERT(REAL, loc.[FieldXloc]) AS X,
	   CONVERT(REAL, loc.[FieldYloc]) AS Y,
	   CONVERT(REAL, loc.[FieldZloc]) AS Z
FROM [mor].[pit_loc] [loc] WITH (NOLOCK)
LEFT JOIN [mor].[enum] enumUnit WITH (NOLOCK)
ON [loc].FieldUnit = enumUnit.Id
LEFT JOIN [mor].[pit_loc] [region] WITH (NOLOCK)
ON loc.FieldRegion = [region].Id
WHERE enumUnit.[Idx] in (7,8)--shop/tiedown/or Q-point locations

