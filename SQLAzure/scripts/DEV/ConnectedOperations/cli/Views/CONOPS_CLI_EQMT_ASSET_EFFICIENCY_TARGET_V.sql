CREATE VIEW [cli].[CONOPS_CLI_EQMT_ASSET_EFFICIENCY_TARGET_V] AS




--select * from [CLI].[CONOPS_CLI_EQMT_ASSET_EFFICIENCY_TARGET_V]
CREATE VIEW [CLI].[CONOPS_CLI_EQMT_ASSET_EFFICIENCY_TARGET_V]
AS

WITH AeTarget AS(
SELECT TOP 1
	SITEFLAG,
	cast((TRUCKAVAILABILITY) as decimal(5,2)) * 100.0  AS TruckAvailabilityTarget,
	cast((TRUCKUTILIZATION) as decimal(5,2)) * 100.0  AS TruckUtilizationTarget,
	cast((TRUCKASSETEFFICIENCY) as decimal(5,2)) * 100.0  AS TruckEfficiencyTarget,
	cast((SHOVELAVAILABILITY) as decimal(5,2)) * 100.0  AS ShovelAvailabilityTarget,
	cast((SHOVELUTILIZATION) as decimal(5,2)) * 100.0  AS ShovelUtilizationTarget,
	cast((SHOVELASSETEFFICIENCY) as decimal(5,2)) * 100.0  AS ShovelEfficiencyTarget,
	cast((DRILLAVAILABILITY) as decimal(5,2)) * 100.0  AS DrillAvailabilityTarget,
	cast((DRILLUTILIZATION) as decimal(5,2)) * 100.0  AS DrillUtilizationTarget,
	cast((DRILLASSETEFFICIENCY) as decimal(5,2)) * 100.0  AS DrillEfficiencyTarget
FROM [CLI].[PLAN_VALUES_MONTHLY_TARGET] WITH (NOLOCK)
ORDER BY ID DESC
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




