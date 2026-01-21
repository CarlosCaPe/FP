CREATE VIEW [SIE].[CONOPS_SIE_SHOVEL_ASSET_EFFICIENCY_V] AS



--select * from [sie].[CONOPS_SIE_SHOVEL_ASSET_EFFICIENCY_V]
CREATE VIEW [SIE].[CONOPS_SIE_SHOVEL_ASSET_EFFICIENCY_V] 
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [SIE].[CONOPS_SIE_ASSET_EFFICIENCY_V]
WHERE unittype = 'Shovel'


