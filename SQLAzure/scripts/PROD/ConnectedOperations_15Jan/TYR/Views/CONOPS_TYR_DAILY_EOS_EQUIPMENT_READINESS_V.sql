CREATE VIEW [TYR].[CONOPS_TYR_DAILY_EOS_EQUIPMENT_READINESS_V] AS
 
--select * from [tyr].[CONOPS_TYR_DAILY_EOS_EQUIPMENT_READINESS_V] where shiftflag = 'prev'
CREATE VIEW [TYR].[CONOPS_TYR_DAILY_EOS_EQUIPMENT_READINESS_V]
AS
WITH EqReadinessTarget AS (
SELECT  
	0 AS TruckReadinessTarget,
	0 AS ShovelReadinessTarget,
	0 AS DrillReadinessTarget  
)

SELECT
	site_code AS siteflag,
	shiftflag,
	KPI,
	ActualValue,
	TargetValue,
	CASE
		WHEN ActualValue = TargetValue THEN 'Within Plan'
		WHEN ActualValue < TargetValue THEN 'Below Plan'
		ELSE 'Exceeds Plan'
	END AS Status
FROM (
	SELECT
		SITE_CODE,
		shiftflag,
		--shiftindex,
		ROUND([Truck], 1) AS TruckReadiness,
		ROUND(TruckReadinessTarget, 1) AS TruckReadinessTarget,
		ROUND([Shovel], 1) AS ShovelReadiness,
		ROUND(ShovelReadinessTarget, 1) AS ShovelReadinessTarget,
		ROUND([Drill], 1) AS DrillReadiness,
		ROUND(DrillReadinessTarget, 1) AS DrillReadinessTarget
	FROM (
		SELECT
			r.SITE_CODE,
			s.shiftflag,
			--r.SHIFTINDEX,
			--s.shiftid,
			MainCategory,
			AVG(eq.TruckReadinessTarget) AS TruckReadinessTarget,
			AVG(eq.ShovelReadinessTarget) AS ShovelReadinessTarget,
			AVG(eq.DrillReadinessTarget) AS DrillReadinessTarget,
			CASE
				WHEN AVG(TotalDurationByEquipment) IS NULL OR AVG(TotalDurationByEquipment) = 0 THEN 0
				ELSE SUM(ReadyDurationByEquipment) / AVG(TotalDurationByEquipment)
			END AS Ready
		FROM (
			SELECT
				site_code,
				shiftindex,
				CASE unit
					WHEN 1 THEN 'Truck'
					WHEN 2 THEN 'Shovel'
					WHEN 12 THEN 'Drill'
				END AS MainCategory,
				eqmt AS Equipment,
				SUM(duration) AS TotalDurationByEquipment,
				SUM(CASE WHEN category IN (1, 2) THEN duration ELSE 0 END) AS ReadyDurationByEquipment
			FROM TYR.EQUIPMENT_HOURLY_STATUS WITH(NOLOCK)
			WHERE
				unit IN (1, 2, 12) -- trucks, shovels, drills
				AND status <> 0
				AND eqmt NOT LIKE '%L'
			GROUP BY site_code, shiftindex, eqmt, unit
		) AS r
		INNER JOIN TYR.CONOPS_TYR_EOS_SHIFT_INFO_V s
			ON r.site_code = s.SITEFLAG
			AND r.shiftindex = s.ShiftIndex
		CROSS JOIN EqReadinessTarget eq
		GROUP BY r.site_code, s.shiftflag, r.SHIFTINDEX, s.shiftid, r.MainCategory--, TotalDurationByEquipment
	) a
	PIVOT (
		AVG(Ready)
		FOR MainCategory IN ([Truck], [Shovel], [Drill])
	) AS pvt
) a
CROSS APPLY (
	VALUES
		('Trucks', ISNULL(TruckReadiness, 0), TruckReadinessTarget),
		('Shovels', ISNULL(ShovelReadiness, 0), ShovelReadinessTarget),
		('Drills', ISNULL(DrillReadiness, 0), DrillReadinessTarget)
) c (KPI, ActualValue, TargetValue);


