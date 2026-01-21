CREATE VIEW [TYR].[CONOPS_TYR_DAILY_TRUCK_ASSET_EFFICIENCY_V] AS





--select * from [TYR].[CONOPS_TYR_DAILY_TRUCK_ASSET_EFFICIENCY_V] 
CREATE VIEW [TYR].[CONOPS_TYR_DAILY_TRUCK_ASSET_EFFICIENCY_V] 
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [TYR].[CONOPS_TYR_DAILY_ASSET_EFFICIENCY_V]
WHERE unittype = 'Truck'

