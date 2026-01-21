CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_V] AS




--select * from [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_V]
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_V] 
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [MOR].[CONOPS_MOR_ASSET_EFFICIENCY_V]
WHERE unittype = 'Shovel'




