CREATE VIEW [SAF].[CONOPS_SAF_EQMT_ASSET_EFFICIENCY_TARGET_V] AS




--select * from [SAF].[CONOPS_SAF_EQMT_ASSET_EFFICIENCY_TARGET_V]
CREATE VIEW [SAF].[CONOPS_SAF_EQMT_ASSET_EFFICIENCY_TARGET_V]
AS

WITH AeTarget AS(
SELECT TOP 1
	ps.SITEFLAG,
	cast((TRUCKAVAILIBILITY) as decimal(5,2)) * 100.0  AS TruckAvailabilityTarget,
	ROUND(cast((TRUCKAVAILIBILITY) as decimal(5,2)) * cast((TRUCKASSETEFFICIENCY) as decimal(5,2)) * 100.0, 1)  AS TruckUtilizationTarget,
	cast((TRUCKASSETEFFICIENCY) as decimal(5,2)) * 100.0  AS TruckEfficiencyTarget,
	cast((ELECSHOVELAVAILABILITY) as decimal(5,2)) * 100.0  AS ShovelAvailabilityTarget,
	cast((ELECSHOVELUSEOFAVAILIBILITY) as decimal(5,2)) * 100.0  AS ShovelUtilizationTarget,
	cast((ELECSHOVELASSETEFFICENCY) as decimal(5,2)) * 100.0  AS ShovelEfficiencyTarget,
	ROUND(dt.DRILLAVAILABILITY,1) AS DrillAvailabilityTarget,
	ROUND(dt.DRILLUTILIZATION,1) AS DrillUtilizationTarget,
	ROUND(dt.DRILLASSETEFFICIENCY,1) AS DrillEfficiencyTarget
FROM [SAF].[PLAN_VALUES] ps WITH (NOLOCK)
CROSS JOIN (SELECT TOP 1 * FROM [SAF].[CONOPS_SAF_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] WITH (NOLOCK) ORDER BY SHIFTID DESC) dt
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




