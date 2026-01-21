CREATE VIEW [BAG].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_V] AS






--select * from [bag].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_V]
CREATE VIEW [bag].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_V] 
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [bag].[CONOPS_BAG_ASSET_EFFICIENCY_V]
WHERE unittype = 'Truck'


