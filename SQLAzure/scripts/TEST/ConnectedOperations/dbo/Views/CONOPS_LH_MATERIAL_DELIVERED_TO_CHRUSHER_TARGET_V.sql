CREATE VIEW [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS





--select * from [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V]

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

UNION ALL

SELECT shiftflag,
	   [siteflag],
	   [Location],
	   [Target]
FROM [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH(NOLOCK)
WHERE siteflag = 'SAF'

UNION ALL

SELECT shiftflag,
	   [siteflag],
	   [Location],
	   [Target]
FROM [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH(NOLOCK)
WHERE siteflag = 'SIE'


UNION ALL

SELECT shiftflag,
	   [siteflag],
	   [Location],
	   [Target]
FROM [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH(NOLOCK)
WHERE siteflag = 'CMX'

UNION ALL

SELECT shiftflag,
	   [siteflag],
	   [Location],
	   [Target]
FROM [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH(NOLOCK)
WHERE siteflag = 'CHI'

UNION ALL

SELECT shiftflag,
	   [siteflag],
	   [Location],
	   [Target]
FROM [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH(NOLOCK)
WHERE siteflag = 'CER'

