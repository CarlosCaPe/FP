CREATE VIEW [cer].[CONOPS_CER_TRUCK_SHOP_LOCATION_V] AS





-- SELECT * FROM [cer].[CONOPS_CER_TRUCK_SHOP_LOCATION_V] WITH (NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_TRUCK_SHOP_LOCATION_V]
AS

SELECT loc.[FieldId] AS Name,
	   CONVERT(REAL, enumUnit.[Idx]) AS Unit,
	   region.[FieldId] AS Region,
	   CONVERT(REAL, loc.[FieldXloc]) AS X,
	   CONVERT(REAL, loc.[FieldYloc]) AS Y,
	   CONVERT(REAL, loc.[FieldZloc]) AS Z
FROM [cer].[pit_loc] [loc] WITH (NOLOCK)
LEFT JOIN [cer].[enum] enumUnit WITH (NOLOCK)
ON [loc].FieldUnit = enumUnit.enum_id
LEFT JOIN [cer].[pit_loc] [region] WITH (NOLOCK)
ON loc.FieldRegion = [region].[ID]
WHERE enumUnit.[Idx] in (7,8)--shop/tiedown/or Q-point locations

