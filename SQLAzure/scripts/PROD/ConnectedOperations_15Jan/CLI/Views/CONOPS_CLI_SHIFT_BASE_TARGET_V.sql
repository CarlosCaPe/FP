CREATE VIEW [CLI].[CONOPS_CLI_SHIFT_BASE_TARGET_V] AS

--select * from [CLI].[CONOPS_CLI_SHIFT_BASE_TARGET_V] 
CREATE VIEW [cli].[CONOPS_CLI_SHIFT_BASE_TARGET_V]
AS

SELECT
	SITEFLAG,
	case when right(shiftid,1) = 1 THEN concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'001')
	ELSE concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'002')
	END AS ShiftId,
	TotalTonsMined AS TonsMinedTarget,
	TotalTonsMoved as TonsMovedTarget
FROM CLI.PLAN_VALUES WITH(NOLOCK)

