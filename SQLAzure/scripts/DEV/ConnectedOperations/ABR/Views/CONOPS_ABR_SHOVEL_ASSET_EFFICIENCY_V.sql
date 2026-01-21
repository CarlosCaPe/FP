CREATE VIEW [ABR].[CONOPS_ABR_SHOVEL_ASSET_EFFICIENCY_V] AS






--select * from [ABR].[CONOPS_ABR_SHOVEL_ASSET_EFFICIENCY_V]
CREATE VIEW [ABR].[CONOPS_ABR_SHOVEL_ASSET_EFFICIENCY_V] 
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [ABR].[CONOPS_ABR_ASSET_EFFICIENCY_V]
WHERE unittype = 'Excav'


