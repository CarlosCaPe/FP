CREATE VIEW [CER].[CONOPS_CER_EQMT_ASSET_EFFICIENCY_TARGET_V] AS




--select * from [CER].[CONOPS_CER_EQMT_ASSET_EFFICIENCY_TARGET_V]
CREATE VIEW [CER].[CONOPS_CER_EQMT_ASSET_EFFICIENCY_TARGET_V]
AS

WITH AeTarget AS(
SELECT TOP 1
	ps.SITEFLAG,
	cast((AVAILABILITYTOTALTRUCK) as decimal(5,2)) * 100.0  AS TruckAvailabilityTarget,
	cast((USEOFAVAILABILITYTOTALTRUCK) as decimal(5,2)) * 100.0  AS TruckUtilizationTarget,
	cast((ASSETEFFICIENCYTOTALTRUCK) as decimal(5,2)) * 100.0  AS TruckEfficiencyTarget,
	cast((AVAILABILITYELECTRICSHOVEL) as decimal(5,2)) * 100.0  AS ShovelAvailabilityTarget,
	cast((USEOFAVAILABILITYELECTRICSHOVEL) as decimal(5,2)) * 100.0  AS ShovelUtilizationTarget,
	cast((ASSETEFFICIENCYELECTRICSHOVEL) as decimal(5,2)) * 100.0  AS ShovelEfficiencyTarget,
	ROUND(dt.DRILLAVAILABILITY,1) AS DrillAvailabilityTarget,
	ROUND(dt.DRILLUTILIZATION,1) AS DrillUtilizationTarget,
	ROUND(dt.DRILLASSETEFFICIENCY,1) AS DrillEfficiencyTarget
FROM [CER].[PLAN_VALUES] ps WITH (NOLOCK)
CROSS JOIN (SELECT TOP 1 * FROM [CER].[CONOPS_CER_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] WITH (NOLOCK) ORDER BY SHIFTID DESC) dt
WHERE TITLE = FORMAT(GETDATE(), 'MMM yyyy', 'en-US') 
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




