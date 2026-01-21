CREATE VIEW [SIE].[CONOPS_SIE_EOS_TONS_MINED_V] AS






--SELECT * FROM [SIE].[CONOPS_SIE_EOS_TONS_MINED_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [sie].[CONOPS_SIE_EOS_TONS_MINED_V]
AS

WITH TonsTarget AS(
SELECT 
	siteflag,
	shiftflag,
	SUM(ShovelShiftTarget) AS TotalMaterialMinedTarget
FROM [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V]
GROUP BY siteflag, shiftflag
)

SELECT
	siteflag,
	shiftflag,
	KPI,
	NULL AS ChildKPI,
	ActualValue,
	TargetValue,
	CASE 
		WHEN ActualValue = TargetValue THEN 'Within Plan'
		WHEN ActualValue < TargetValue THEN 'Below Plan'
		ELSE 'Exceeds Plan' 
	END AS Status
FROM(
	SELECT
		ov.siteflag,
		ov.shiftflag,
		ROUND(ov.TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
		ROUND(t.TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
		ROUND(ov.TotalmaterialMoved/1000.0,1) AS TotalMaterialMoved,
		0 AS TotalMaterialMovedTarget
	FROM [SIE].[CONOPS_SIE_EOS_TOTAL_MATERIAL_V] ov
	LEFT OUTER JOIN TonsTarget t
	ON ov.siteflag = t.siteflag AND ov.shiftflag = t.shiftflag
) a
CROSS APPLY (
VALUES
	('Total Material Moved', TotalMaterialMoved, TotalMaterialMovedTarget),
	('Total Material Mined', TotalMaterialMined, TotalMaterialMinedTarget)
) c (KPI, ActualValue, TargetValue)

UNION

SELECT
	siteflag,
	SHIFTFLAG,
	Name AS KPI,
	ChildKPI,
	ActualValue,
	TargetValue,
	CASE 
		WHEN ActualValue = TargetValue THEN 'Within Plan'
		WHEN ActualValue < TargetValue THEN 'Below Plan'
		ELSE 'Exceeds Plan' 
	END AS Status
FROM [SIE].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CROSS APPLY
(
  VALUES
    ('Leach', LeachActual, LeachShiftTarget),
    ('Mill Ore', MillOreActual, MillOreShiftTarget),
	(NULL, (LeachActual + MillOreActual), (LeachShiftTarget + MillOreShiftTarget))
) c (ChildKPI, ActualValue, TargetValue)


