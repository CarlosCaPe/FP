CREATE VIEW [BAG].[CONOPS_BAG_DAILY_EOS_TONS_MINED_V] AS

--SELECT * FROM [BAG].[CONOPS_BAG_DAILY_EOS_TONS_MINED_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_TONS_MINED_V]
AS

SELECT
	siteflag,
	shiftflag,
	--shiftid,
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
		--ov.shiftid,
		ROUND(SUM(ov.TotalMaterialMined)/1000.0,1) AS TotalMaterialMined,
		ROUND(SUM(t.TonsMinedTarget)/1000.0,1) AS TotalMaterialMinedTarget,
		ROUND(SUM(ov.TotalmaterialMoved)/1000.0,1) AS TotalMaterialMoved,
		ROUND(SUM(t.TonsMovedTarget)/1000.0, 1) AS TotalMaterialMovedTarget
	FROM [BAG].[CONOPS_BAG_DAILY_EOS_TOTAL_MATERIAL_V] ov
	LEFT JOIN [bag].[CONOPS_BAG_SHIFT_BASE_TARGET_V] t
		ON ov.shiftid = t.shiftid
	GROUP BY ov.siteflag, ov.shiftflag
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
	--shiftid,
	Name AS KPI,
	ChildKPI,
	SUM(ActualValue) AS ActualValue,
	SUM(TargetValue) AS TargetValue,
	CASE
		WHEN SUM(ActualValue) = SUM(TargetValue) THEN 'Within Plan'
		WHEN SUM(ActualValue) < SUM(TargetValue) THEN 'Below Plan'
		ELSE 'Exceeds Plan'
	END AS Status
FROM [BAG].[CONOPS_BAG_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CROSS APPLY
(
VALUES
	('Leach', LeachActual, LeachShiftTarget),
	('Mill Ore', MillOreActual, MillOreShiftTarget),
	(NULL, (LeachActual + MillOreActual), (LeachShiftTarget + MillOreShiftTarget))
) c (ChildKPI, ActualValue, TargetValue)
GROUP BY siteflag, SHIFTFLAG, Name, ChildKPI

