CREATE VIEW [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS


CREATE VIEW [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V]
AS

SELECT shiftflag,
	   [siteflag],
	   [Location],
	   [Target]
FROM [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH(NOLOCK)
WHERE siteflag = 'MOR'

UNION ALL

SELECT shiftflag,
	   [siteflag],
	   [Location],
	   [Target]
FROM [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH(NOLOCK)
WHERE siteflag = 'BAG'

