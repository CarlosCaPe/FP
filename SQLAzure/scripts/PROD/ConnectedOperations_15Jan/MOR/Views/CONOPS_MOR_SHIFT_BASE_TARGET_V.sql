CREATE VIEW [MOR].[CONOPS_MOR_SHIFT_BASE_TARGET_V] AS

--select * from [MOR].[CONOPS_MOR_SHIFT_BASE_TARGET_V] 
CREATE VIEW [mor].[CONOPS_MOR_SHIFT_BASE_TARGET_V]
AS

SELECT
	'MOR' AS SiteFlag,
	Formatshiftid AS ShiftId,
	SUM(TON) AS TonsMinedTarget,
	0 AS TonsMovedTarget
FROM [mor].[xecute_plan_values] (NOLOCK)
GROUP BY Formatshiftid

