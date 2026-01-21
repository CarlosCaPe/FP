CREATE VIEW [MOR].[CONOPS_MOR_SHIFT_BASE_TARGET_V] AS

--select * from [MOR].[CONOPS_MOR_SHIFT_BASE_TARGET_V] 
CREATE VIEW [mor].[CONOPS_MOR_SHIFT_BASE_TARGET_V]
AS

SELECT
	'MOR' AS SiteFlag,
	Formatshiftid AS ShiftId,
	SUM(TON) AS TonsMinedTarget,
	(ShiftDuration / 43200.0) * SUM(TON) AS CurrentTonsMinedTarget,
	0 AS TonsMovedTarget,
	0 AS CurrentTonsMovedTarget
FROM [mor].[xecute_plan_values] pv (NOLOCK)
LEFT JOIN MOR.SHIFT_INFO si
	ON pv.FormatShiftId = si.ShiftId
GROUP BY Formatshiftid, ShiftDuration


