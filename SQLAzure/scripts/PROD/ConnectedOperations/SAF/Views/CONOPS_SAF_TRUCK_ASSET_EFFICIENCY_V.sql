CREATE VIEW [SAF].[CONOPS_SAF_TRUCK_ASSET_EFFICIENCY_V] AS






--select * from [saf].[CONOPS_SAF_TRUCK_ASSET_EFFICIENCY_V]
CREATE VIEW [saf].[CONOPS_SAF_TRUCK_ASSET_EFFICIENCY_V] 
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [SAF].[CONOPS_SAF_ASSET_EFFICIENCY_V]
WHERE unittype = 'Truck'



