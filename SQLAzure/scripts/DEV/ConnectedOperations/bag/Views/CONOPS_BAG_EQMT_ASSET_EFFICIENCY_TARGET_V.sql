CREATE VIEW [bag].[CONOPS_BAG_EQMT_ASSET_EFFICIENCY_TARGET_V] AS







--select * from [BAG].[CONOPS_BAG_EQMT_ASSET_EFFICIENCY_TARGET_V]
CREATE VIEW [BAG].[CONOPS_BAG_EQMT_ASSET_EFFICIENCY_TARGET_V] 
AS

WITH AeTarget AS(
SELECT TOP 1
	ps.SITEFLAG,
	ROUND(TRUCKAVAILABILITY,1) AS TruckAvailabilityTarget,
	ROUND(TRUCKUSEOFAVAILABILITY,1) AS TruckUtilizationTarget,
	ROUND(TRUCKASSETEFFICIENCY,1) AS TruckEfficiencyTarget,
	ROUND(SHOVELAVAILABILITY,1) AS ShovelAvailabilityTarget,
	ROUND(SHOVELUSEOFAVAILABILITY,1) AS ShovelUtilizationTarget,
	ROUND(SHOVELASSETEFFICIENCY,1) AS ShovelEfficiencyTarget,
	ROUND(dt.DRILLAVAILABILITY,1) AS DrillAvailabilityTarget,
	ROUND(dt.DRILLUTILIZATION,1) AS DrillUtilizationTarget,
	ROUND(dt.DRILLASSETEFFICIENCY,1) AS DrillEfficiencyTarget
FROM [bag].[plan_values_prod_sum] ps WITH (NOLOCK)
CROSS JOIN (SELECT TOP 1 * FROM [bag].[CONOPS_BAG_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] WITH (NOLOCK) ORDER BY SHIFTID DESC) dt
ORDER BY EFFECTIVEDATE DESC
)

SELECT
	SITEFLAG,
	TruckAvailabilityTarget,
	TruckUtilizationTarget,
	TruckEfficiencyTarget,
	ShovelAvailabilityTarget,
	ShovelUtilizationTarget,
	ShovelEfficiencyTarget,
	DrillAvailabilityTarget,
	DrillUtilizationTarget,
	DrillEfficiencyTarget
FROM AeTarget




