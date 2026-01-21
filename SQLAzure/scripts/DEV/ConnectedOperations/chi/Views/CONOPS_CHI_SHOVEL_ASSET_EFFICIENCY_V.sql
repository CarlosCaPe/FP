CREATE VIEW [chi].[CONOPS_CHI_SHOVEL_ASSET_EFFICIENCY_V] AS






--select * from [chi].[CONOPS_CHI_SHOVEL_ASSET_EFFICIENCY_V]
CREATE VIEW [chi].[CONOPS_CHI_SHOVEL_ASSET_EFFICIENCY_V] 
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [CHI].[CONOPS_CHI_ASSET_EFFICIENCY_V]
WHERE unittype = 'Shovel'



