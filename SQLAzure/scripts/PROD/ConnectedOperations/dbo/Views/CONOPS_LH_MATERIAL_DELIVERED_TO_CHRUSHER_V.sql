CREATE VIEW [dbo].[CONOPS_LH_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS


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

