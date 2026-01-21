CREATE VIEW [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS






--select * from [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)
CREATE VIEW [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V]
AS
	SELECT FORMATSHIFTID AS shiftid,
			   [siteflag],
			   'Crusher 2' [Location], 
			   CRUSHER2 [Target]
		FROM [bag].[plan_values] WITH (NOLOCK)

