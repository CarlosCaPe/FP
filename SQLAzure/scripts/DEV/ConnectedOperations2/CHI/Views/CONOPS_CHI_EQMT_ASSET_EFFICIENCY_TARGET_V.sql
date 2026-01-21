CREATE VIEW [CHI].[CONOPS_CHI_EQMT_ASSET_EFFICIENCY_TARGET_V] AS




--select * from [CHI].[CONOPS_CHI_EQMT_ASSET_EFFICIENCY_TARGET_V]
CREATE VIEW [CHI].[CONOPS_CHI_EQMT_ASSET_EFFICIENCY_TARGET_V]
AS


WITH AeTarget AS(
SELECT TOP 1
	ps.SITEFLAG,
	ROUND(TruckAvailability,1) AS TruckAvailabilityTarget,
	ROUND(TruckUofA,1) AS TruckUtilizationTarget,
	ROUND(TruckAssetEfficiency,1) AS TruckEfficiencyTarget,
	ROUND(ElectricShovelAvailability,1) AS ShovelAvailabilityTarget,
	ROUND(ElectricShovelUofA,1) AS ShovelUtilizationTarget,
	ROUND(ElectricShovelAssetEfficiency,1) AS ShovelEfficiencyTarget,
	ROUND(dt.DRILLAVAILABILITY,1) AS DrillAvailabilityTarget,
	ROUND(dt.DRILLUTILIZATION,1) AS DrillUtilizationTarget,
	ROUND(dt.DRILLASSETEFFICIENCY,1) AS DrillEfficiencyTarget
FROM [CHI].[plan_values] ps WITH (NOLOCK)
CROSS JOIN (SELECT TOP 1 * FROM [CHI].[CONOPS_CHI_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] WITH (NOLOCK) ORDER BY SHIFTID DESC) dt
ORDER BY DateEffective DESC
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




