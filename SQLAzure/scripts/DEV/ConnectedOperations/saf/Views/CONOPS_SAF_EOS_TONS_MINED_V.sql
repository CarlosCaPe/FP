CREATE VIEW [saf].[CONOPS_SAF_EOS_TONS_MINED_V] AS





--SELECT * FROM [SAF].[CONOPS_SAF_EOS_TONS_MINED_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [saf].[CONOPS_SAF_EOS_TONS_MINED_V]
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
	FROM [SAF].[CONOPS_SAF_EOS_TOTAL_MATERIAL_V] ov
	LEFT JOIN [SAF].[CONOPS_SAF_SHIFT_TARGET_V] t
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
FROM [SAF].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CROSS APPLY
(
  VALUES
    ('Leach', LeachActual, LeachShiftTarget),
    ('Mill Ore', MillOreActual, MillOreShiftTarget),
	(NULL, (LeachActual + MillOreActual), (LeachShiftTarget + MillOreShiftTarget))
) c (ChildKPI, ActualValue, TargetValue)

