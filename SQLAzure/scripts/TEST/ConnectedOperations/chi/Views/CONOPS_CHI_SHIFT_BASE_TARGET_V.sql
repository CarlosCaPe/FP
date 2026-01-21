CREATE VIEW [chi].[CONOPS_CHI_SHIFT_BASE_TARGET_V] AS

--select * from [CHI].[CONOPS_CHI_SHIFT_BASE_TARGET_V] 
CREATE VIEW [chi].[CONOPS_CHI_SHIFT_BASE_TARGET_V]
AS

SELECT TOP 1
	SITEFLAG,
	NULL AS ShiftId,
	ISNULL([TotalExPitTPD], 0) / 2 AS TonsMinedTarget,
	(ISNULL([TotalExPitTPD], 0) + ISNULL([OreRehandletoCrusherTPD], 0)) / 2 as TonsMovedTarget
FROM CHI.PLAN_VALUES WITH(NOLOCK)
ORDER BY DateEffective DESC

