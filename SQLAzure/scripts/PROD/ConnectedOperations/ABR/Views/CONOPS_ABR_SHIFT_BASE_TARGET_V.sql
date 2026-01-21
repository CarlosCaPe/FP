CREATE VIEW [ABR].[CONOPS_ABR_SHIFT_BASE_TARGET_V] AS

--select * from [abr].[CONOPS_ABR_SHIFT_BASE_TARGET_V] 
CREATE VIEW [ABR].[CONOPS_ABR_SHIFT_BASE_TARGET_V]
AS  

SELECT
	SiteFlag,
	FormatShiftId AS ShiftId,
	SUM(Tons) AS TonsMinedTarget,
	0 AS TonsMovedTarget
FROM [abr].PLAN_VALUES WITH (NOLOCK)
GROUP BY SITEFLAG, FormatShiftId

