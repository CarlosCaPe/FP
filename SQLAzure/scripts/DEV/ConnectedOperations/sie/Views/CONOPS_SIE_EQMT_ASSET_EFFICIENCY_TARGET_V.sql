CREATE VIEW [sie].[CONOPS_SIE_EQMT_ASSET_EFFICIENCY_TARGET_V] AS




--select * from [SIE].[CONOPS_SIE_EQMT_ASSET_EFFICIENCY_TARGET_V]
CREATE VIEW [SIE].[CONOPS_SIE_EQMT_ASSET_EFFICIENCY_TARGET_V]
AS

WITH AeTarget AS(
SELECT TOP 1
	ps.SITEFLAG,
	ROUND(TRUCKAVAILABILITY,1) AS TruckAvailabilityTarget,
	ROUND(TRUCKUSEOFAVAILABILITY,1) AS TruckUtilizationTarget,
	ROUND(TRUCKASSETEFFICIENCY,1) AS TruckEfficiencyTarget,
	ROUND(ELECSHOVELAVAILABILITY,1) AS ShovelAvailabilityTarget,
	ROUND(ELECSHOVELUSEOFAVAILIBILITY,1) AS ShovelUtilizationTarget,
	ROUND(ELECSHOVELASSETEFFICIENCY,1) AS ShovelEfficiencyTarget,
	ROUND(DRILLAVAILABILITY,1) AS DrillAvailabilityTarget,
	ROUND(DRILLUSEOFAVAILABILITY,1) AS DrillUtilizationTarget,
	ROUND(DRILLASSETEFFICIENCY,1) AS DrillEfficiencyTarget
FROM [SIE].[plan_values_prod_sum] ps WITH (NOLOCK)
ORDER BY DATEEFFECTIVE DESC
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




