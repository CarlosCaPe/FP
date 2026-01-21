CREATE VIEW [CER].[CONOPS_CER_SHIFT_BASE_TARGET_V] AS

--select * from [CER].[CONOPS_CER_SHIFT_BASE_TARGET_V] 
CREATE VIEW [cer].[CONOPS_CER_SHIFT_BASE_TARGET_V]
AS

WITH CTE AS (
select
	siteflag,
	CONCAT(RIGHT(REPLACE(FECHA,'-',''),6), CASE WHEN turno = 'Noche' THEN '002' ELSE '001' END) AS ShiftId,
	pala as Shovel,
	TONELADAS AS Tons,
	Fase
from cer.PLAN_VALUES_SHOVEL WITH (NOLOCK)
),

MovedTarget AS (
SELECT
	ShiftId,
	SUM(Tons) AS TonsMovedTarget
FROM CTE
GROUP BY ShiftId
),

MinedTarget AS (
SELECT
	ShiftId,
	SUM(Tons) AS TonsMinedTarget
FROM CTE
WHERE FASE LIKE 'SR%' 
	OR FASE LIKE 'CN%'
	OR FASE LIKE 'CV%'
GROUP BY ShiftId
)

SELECT
	a.siteflag,
	a.Shiftid,
	b.TonsMinedTarget,
	c.TonsMovedTarget
FROM CTE a
LEFT JOIN MinedTarget b
	ON a.shiftid = b.shiftid
LEFT JOIN MovedTarget c
	ON a.shiftid = c.shiftid
GROUP BY a.siteflag, a.shiftid, TonsMinedTarget, TonsMovedTarget


