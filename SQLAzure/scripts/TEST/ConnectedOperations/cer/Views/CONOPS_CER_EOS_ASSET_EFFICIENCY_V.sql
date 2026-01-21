CREATE VIEW [cer].[CONOPS_CER_EOS_ASSET_EFFICIENCY_V] AS







--SELECT * FROM [CER].[CONOPS_CER_EOS_ASSET_EFFICIENCY_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [cer].[CONOPS_CER_EOS_ASSET_EFFICIENCY_V]
AS

WITH Truck AS(
SELECT
	SITEFLAG,
	SHIFTFLAG,
	efficiency AS TruckEfficiency,
	availability AS TruckAvailability,
	use_of_availability TruckUtilization
FROM [CER].[CONOPS_CER_TRUCK_ASSET_EFFICIENCY_V]
),

Shovel AS(
SELECT
	SITEFLAG,
	SHIFTFLAG,
	efficiency AS ShovelEfficiency,
	availability AS ShovelAvailability,
	use_of_availability ShovelUtilization
FROM [CER].[CONOPS_CER_SHOVEL_ASSET_EFFICIENCY_V]
),

Drill AS(
SELECT
	SITEFLAG,
	SHIFTFLAG,
	efficiency AS DrillEfficiency,
	availability AS DrillAvailability,
	use_of_availability DrillUtilization
FROM [CER].[CONOPS_CER_DRILL_ASSET_EFFICIENCY_V]
)

SELECT
	siteflag,
	shiftflag,
	KPI,
	ChildKPI,
	ActualValue,
	TargetValue,
	CASE 
		WHEN ActualValue = TargetValue THEN 'Within Plan'
		WHEN ActualValue < TargetValue THEN 'Below Plan'
		ELSE 'Exceeds Plan' 
	END AS Status
FROM(
	SELECT
		t.siteflag,
		t.shiftflag,
		ISNULL(TruckEfficiency,0) AS TruckEfficiency,
		ISNULL(TruckEfficiencyTarget,0) AS TruckEfficiencyTarget,
		ISNULL(TruckAvailability,0) AS TruckAvailability,
		ISNULL(TruckAvailabilityTarget,0) AS TruckAvailabilityTarget,
		ISNULL(TruckUtilization,0) AS TruckUtilization,
		ISNULL(TruckUtilizationTarget,0) AS TruckUtilizationTarget,
		ISNULL(ShovelEfficiency,0) AS ShovelEfficiency,
		ISNULL(ShovelEfficiencyTarget,0) AS ShovelEfficiencyTarget,
		ISNULL(ShovelAvailability,0) AS ShovelAvailability,
		ISNULL(ShovelAvailabilityTarget,0) AS ShovelAvailabilityTarget,
		ISNULL(ShovelUtilization,0) AS ShovelUtilization,
		ISNULL(ShovelUtilizationTarget,0) AS ShovelUtilizationTarget,
		ISNULL(DrillEfficiency,0) AS DrillEfficiency,
		ISNULL(DrillEfficiencyTarget,0) AS DrillEfficiencyTarget,
		ISNULL(DrillAvailability,0) AS DrillAvailability,
		ISNULL(DrillAvailabilityTarget,0) AS DrillAvailabilityTarget,
		ISNULL(DrillUtilization,0) AS DrillUtilization,
		ISNULL(DrillUtilizationTarget,0) AS DrillUtilizationTarget
	FROM Truck t
	LEFT JOIN Shovel s
		ON t.siteflag = s.siteflag
		AND t.shiftflag = s.shiftflag
	LEFT JOIN Drill d
		ON t.siteflag = d.siteflag
		AND t.shiftflag = d.shiftflag
	LEFT JOIN [CER].[CONOPS_CER_EQMT_ASSET_EFFICIENCY_TARGET_V] tg
		ON t.siteflag = tg.SITEFLAG
) a
CROSS APPLY (
VALUES
	('Truck Asset Efficiency', NULL, TruckEfficiency, TruckEfficiencyTarget),
	('Truck Asset Efficiency', 'Truck Availability', TruckAvailability, TruckAvailabilityTarget),
	('Truck Asset Efficiency', 'Truck Use of Availability', TruckUtilization, TruckUtilizationTarget),
	('Shovel Asset Efficiency', NULL, ShovelEfficiency, ShovelEfficiencyTarget),
	('Shovel Asset Efficiency', 'Shovel Availability', ShovelAvailability, ShovelAvailabilityTarget),
	('Shovel Asset Efficiency', 'Shovel Use of Availability', ShovelUtilization, ShovelUtilizationTarget),
	('Drill Asset Efficiency', NULL, DrillEfficiency, DrillEfficiencyTarget),
	('Drill Asset Efficiency', 'Drill Availability', DrillAvailability, DrillAvailabilityTarget),
	('Drill Asset Efficiency', 'Drill Use of Availability', DrillUtilization, DrillUtilizationTarget)
) c (KPI, ChildKPI, ActualValue, TargetValue);






