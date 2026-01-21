CREATE VIEW [cer].[ZZZ_CONOPS_CER_SHOVEL_TARGET_V_NEW] AS




-- SELECT * FROM [cer].[CONOPS_CER_SHOVEL_TARGET_V_NEW] order by shiftid, shovel
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_TARGET_V_NEW]
AS


WITH CTE AS (
select 
CONCAT(RIGHT(REPLACE(FECHA,'-',''),6), CASE WHEN turno = 'Noche' THEN '002' ELSE '001' END) AS ShiftId,
pala as ShovelId,
TONELADAS AS Tons,
Fase
from cer.PLAN_VALUES_SHOVEL),

MovedTarget AS (
SELECT
ShiftId,
SUM(Tons) AS MaterialMovedShiftTarget
FROM CTE
GROUP BY ShiftId),

MinedTarget AS (
SELECT
ShiftId,
SUM(Tons) AS MaterialMinedShiftTarget
FROM CTE
WHERE FASE LIKE 'SR%' OR FASE LIKE 'CN%' OR FASE LIKE 'CV%'
GROUP BY ShiftId)

SELECT
a.Shiftid,
a.ShovelId,
SUM(a.Tons) ShovelShiftTarget,
b.MaterialMinedShiftTarget,
c.MaterialMovedShiftTarget
FROM CTE a
LEFT JOIN MinedTarget b
ON a.shiftid = b.shiftid
LEFT JOIN MovedTarget c
ON a.shiftid = c.shiftid
GROUP BY a.shiftid,a.ShovelId,MaterialMinedShiftTarget,MaterialMovedShiftTarget


