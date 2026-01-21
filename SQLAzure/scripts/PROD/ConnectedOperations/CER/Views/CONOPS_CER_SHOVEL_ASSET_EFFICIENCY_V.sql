CREATE VIEW [CER].[CONOPS_CER_SHOVEL_ASSET_EFFICIENCY_V] AS





--select * from [cer].[CONOPS_CER_SHOVEL_ASSET_EFFICIENCY_V]
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_ASSET_EFFICIENCY_V]
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [CER].[CONOPS_CER_ASSET_EFFICIENCY_V]
WHERE unittype = 'Pala'

