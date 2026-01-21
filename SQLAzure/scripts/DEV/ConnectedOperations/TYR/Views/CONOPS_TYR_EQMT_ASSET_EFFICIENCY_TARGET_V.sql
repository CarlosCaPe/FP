CREATE VIEW [TYR].[CONOPS_TYR_EQMT_ASSET_EFFICIENCY_TARGET_V] AS







--select * from [tyr].[CONOPS_TYR_EQMT_ASSET_EFFICIENCY_TARGET_V]
CREATE VIEW [tyr].[CONOPS_TYR_EQMT_ASSET_EFFICIENCY_TARGET_V]
AS
/*
WITH AeTarget AS(
SELECT TOP 1
	ps.SITEFLAG,
	ROUND(TruckAvailability,0) AS TruckAvailabilityTarget,
	ROUND((TruckAssetEfficiency/[TruckAvailability]) * 100,0) AS TruckUtilizationTarget,
	--CAST(REPLACE([TruckAvailability], '%', '') AS numeric) * CAST(REPLACE([TruckAssetEfficiency], '%', '') AS numeric) / 100 AS TruckUtilizationTarget,
	cast((TruckAssetEfficiency) as decimal(5,2)) AS TruckEfficiencyTarget,
	cast((ElecShovelAvailability) as decimal(5,2)) * 100  AS ShovelAvailabilityTarget,
	cast((ElecShovelUseOfAvailability) as decimal(5,2)) * 100 AS ShovelUtilizationTarget,
	cast((ElecShovelAssetEfficiency) as decimal(5,2)) * 100 AS ShovelEfficiencyTarget,
	90 AS DrillAvailabilityTarget,
	74.7 AS DrillUtilizationTarget,
	67.3 AS DrillEfficiencyTarget
FROM [tyr].[plan_values_prod_sum] ps WITH (NOLOCK)
ORDER BY DateEffective DESC
)*/

SELECT
	'TYR' AS SITEFLAG,
	0.0 AS TruckAvailabilityTarget,
	0.0 AS TruckUtilizationTarget,
	0.0 AS TruckEfficiencyTarget,
	0.0 AS ShovelAvailabilityTarget,
	0.0 AS ShovelUtilizationTarget,
	0.0 AS ShovelEfficiencyTarget,
	0.0 AS DrillAvailabilityTarget,
	0.0 AS DrillUtilizationTarget,
	0.0 AS DrillEfficiencyTarget
--FROM AeTarget





