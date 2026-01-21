CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_ASSET_EFFICIENCY_V] AS





--SELECT * FROM [abr].[CONOPS_ABR_DAILY_EOS_ASSET_EFFICIENCY_V] WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_ASSET_EFFICIENCY_V]  
AS  
  
WITH Truck AS(
SELECT
	SITEFLAG,
	SHIFTFLAG,
	efficiency AS TruckEfficiency,
	availability AS TruckAvailability,
	use_of_availability TruckUtilization
FROM [ABR].[CONOPS_ABR_DAILY_TRUCK_ASSET_EFFICIENCY_V]
),

Shovel AS(
SELECT
	SITEFLAG,
	SHIFTFLAG,
	efficiency AS ShovelEfficiency,
	availability AS ShovelAvailability,
	use_of_availability ShovelUtilization
FROM [ABR].[CONOPS_ABR_DAILY_SHOVEL_ASSET_EFFICIENCY_V]
),

Drill AS(
SELECT
	SITEFLAG,
	SHIFTFLAG,
	efficiency AS DrillEfficiency,
	availability AS DrillAvailability,
	use_of_availability DrillUtilization
FROM [ABR].[CONOPS_ABR_DAILY_DRILL_ASSET_EFFICIENCY_V]
)
  
SELECT  
 siteflag,  
 shiftflag,  
 --SHIFTID,
 KPI,  
 ChildKPI,  
 ROUND(ActualValue,1) AS ActualValue,
	ROUND(TargetValue,1) AS TargetValue, 
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
		TruckEfficiencyTarget,
		ISNULL(TruckAvailability,0) AS TruckAvailability,
		TruckAvailabilityTarget,  
		ISNULL(TruckUtilization,0) AS TruckUtilization,
		TruckUtilizationTarget,
		ISNULL(ShovelEfficiency,0) AS ShovelEfficiency,
		ShovelEfficiencyTarget,
		ISNULL(ShovelAvailability,0) AS ShovelAvailability,
		ShovelAvailabilityTarget,
		ISNULL(ShovelUtilization,0) AS ShovelUtilization,
		ShovelUtilizationTarget,
		ISNULL(DrillEfficiency,0) AS DrillEfficiency,
		DrillEfficiencyTarget,
		ISNULL(DrillAvailability,0) AS DrillAvailability,
		DrillAvailabilityTarget,
		ISNULL(DrillUtilization,0) AS DrillUtilization,
		DrillUtilizationTarget
	FROM Truck t
	LEFT JOIN Shovel s
		ON t.siteflag = s.siteflag
		AND t.shiftflag = s.shiftflag
	LEFT JOIN Drill d
		ON t.siteflag = d.siteflag
		AND t.shiftflag = d.shiftflag
 LEFT JOIN [abr].[CONOPS_ABR_EQMT_ASSET_EFFICIENCY_TARGET_V] tg  
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
  
  
  
  
  





