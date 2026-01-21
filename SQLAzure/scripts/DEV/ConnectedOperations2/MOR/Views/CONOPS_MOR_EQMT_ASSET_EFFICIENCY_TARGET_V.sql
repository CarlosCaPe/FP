CREATE VIEW [MOR].[CONOPS_MOR_EQMT_ASSET_EFFICIENCY_TARGET_V] AS





--select * from [MOR].[CONOPS_MOR_EQMT_ASSET_EFFICIENCY_TARGET_V]
CREATE VIEW [mor].[CONOPS_MOR_EQMT_ASSET_EFFICIENCY_TARGET_V]
AS

WITH AeTarget AS(
SELECT TOP 1
	ps.SITEFLAG,
	ROUND(TruckAvailability * 100.0 ,1)  AS TruckAvailabilityTarget,
	ROUND((TruckAssetEfficiency/[TruckAvailability]) * 100,0) AS TruckUtilizationTarget,
	--CAST(REPLACE([TruckAvailability], '%', '') AS numeric) * CAST(REPLACE([TruckAssetEfficiency], '%', '') AS numeric) / 100 AS TruckUtilizationTarget,
	ROUND(TruckAssetEfficiency * 100.0 ,1) AS TruckEfficiencyTarget,
	cast((ElecShovelAvailability) as decimal(5,2)) * 100  AS ShovelAvailabilityTarget,
	cast((ElecShovelUseOfAvailability) as decimal(5,2)) * 100 AS ShovelUtilizationTarget,
	cast((ElecShovelAssetEfficiency) as decimal(5,2)) * 100 AS ShovelEfficiencyTarget,
	90 AS DrillAvailabilityTarget,
	74.7 AS DrillUtilizationTarget,
	67.3 AS DrillEfficiencyTarget
FROM [MOR].[plan_values_prod_sum] ps WITH (NOLOCK)
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




