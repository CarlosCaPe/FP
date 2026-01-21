CREATE VIEW [CLI].[CONOPS_CLI_DAILY_SHOVEL_ASSET_EFFICIENCY_V] AS





--select * from [cli].[CONOPS_CLI_DAILY_SHOVEL_ASSET_EFFICIENCY_V] 
CREATE VIEW [cli].[CONOPS_CLI_DAILY_SHOVEL_ASSET_EFFICIENCY_V]  
AS

SELECT shiftflag,
	   [siteflag],
	   [overall_efficiency],
	   [efficiency],
	   [availability],
	   [use_of_availability]	   
FROM [CLI].[CONOPS_CLI_DAILY_ASSET_EFFICIENCY_V]
WHERE unittype = 'Shovel'



