CREATE VIEW [CHI].[CONOPS_CHI_EOS_TONS_MINED_V] AS







--SELECT * FROM [CHI].[CONOPS_CHI_EOS_TONS_MINED_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [chi].[CONOPS_CHI_EOS_TONS_MINED_V]
AS

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
		ROUND(t.ShiftTarget/1000.0,1) AS TotalMaterialMinedTarget,
		ROUND(ov.TotalmaterialMoved/1000.0,1) AS TotalMaterialMoved,
		0 AS TotalMaterialMovedTarget
	FROM [CHI].[CONOPS_CHI_EOS_TOTAL_MATERIAL_V] ov
	LEFT JOIN [chi].[CONOPS_CHI_SHIFT_TARGET_V] t
	ON ov.siteflag = t.siteflag AND ov.shiftflag = t.shiftflag
) a
CROSS APPLY (
VALUES
	--('Total Material Moved', 0, 0),
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
FROM [CHI].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CROSS APPLY
(
  VALUES
    ('Leach', LeachActual, LeachShiftTarget),
    ('Mill Ore', MillOreActual, MillOreShiftTarget),
	(NULL, (LeachActual + MillOreActual), (LeachShiftTarget + MillOreShiftTarget))
) c (ChildKPI, ActualValue, TargetValue)


