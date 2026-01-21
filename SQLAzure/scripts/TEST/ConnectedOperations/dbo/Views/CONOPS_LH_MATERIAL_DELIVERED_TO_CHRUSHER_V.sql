CREATE VIEW [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS







--select * from [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_V]

CREATE VIEW [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_V]
AS

SELECT
a.shiftflag,
a.siteflag,
b.CrusherLoc,
b.MflDeliveredToCrusher [CrusherLeach],
b.MillOreDeliveredToCrusher [MillOre]
FROM [dbo].[SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V] b WITH (NOLOCK)
on a.shiftid = b.shiftid AND a.siteflag = b.siteflag
WHERE a.siteflag = 'MOR'

UNION ALL

SELECT a.shiftflag,
	   a.siteflag,
	   b.CrusherLoc,
	   b.CrusherLeach,
	   b.MillOre
FROM [dbo].[SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V] b WITH (NOLOCK)
on a.shiftid = b.shiftid AND a.siteflag = b.siteflag
WHERE a.siteflag = 'BAG'

UNION ALL

SELECT a.shiftflag,
	   a.siteflag,
	   b.CrusherLoc,
	   b.CrusherLeach,
	   b.MillOre
FROM [dbo].[SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V] b WITH (NOLOCK)
on a.shiftid = b.shiftid AND a.siteflag = b.siteflag
WHERE a.siteflag = 'SAF'

UNION ALL

SELECT a.shiftflag,
	   a.siteflag,
	   b.CrusherLoc,
	   b.CrusherLeach,
	   b.MillOre
FROM [dbo].[SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_V] b WITH (NOLOCK)
on a.shiftid = b.shiftid AND a.siteflag = b.siteflag
WHERE a.siteflag = 'SIE'


UNION ALL

SELECT a.shiftflag,
	   a.siteflag,
	   b.CrusherLoc,
	   b.CrusherLeach,
	   b.MillOre
FROM [dbo].[SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V] b WITH (NOLOCK)
on a.shiftid = b.shiftid AND a.siteflag = b.siteflag
WHERE a.siteflag = 'CMX'

UNION ALL

SELECT a.shiftflag,
	   a.siteflag,
	   b.CrusherLoc,
	   b.CrusherLeach,
	   b.MillOre
FROM [dbo].[SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V] b WITH (NOLOCK)
on a.shiftid = b.shiftid AND a.siteflag = b.siteflag
WHERE a.siteflag = 'CHI'

UNION ALL

SELECT a.shiftflag,
	   a.siteflag,
	   b.CrusherLoc,
	   b.CrusherLeach,
	   b.MillOre
FROM [dbo].[SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V] b WITH (NOLOCK)
on a.shiftid = b.shiftid AND a.siteflag = b.siteflag
WHERE a.siteflag = 'CER'

