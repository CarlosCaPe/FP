CREATE VIEW [TYR].[CONOPS_TYR_SHIFT_BASE_TARGET_V] AS

--select * from [tyr].[CONOPS_TYR_SHIFT_BASE_TARGET_V] 
CREATE VIEW [TYR].[CONOPS_TYR_SHIFT_BASE_TARGET_V]
AS

SELECT
	SiteFlag,
	FormatShiftId AS ShiftId,
	SUM(MiningRateWaste + MiningRateROM) AS TonsMinedTarget,
	0 AS TonsMovedTarget
FROM TYR.PLAN_VALUES WITH (NOLOCK)
GROUP BY SITEFLAG, FormatShiftId

