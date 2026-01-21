CREATE VIEW [dbo].[CONOPS_SHOVEL_POPUP_V] AS


CREATE VIEW [dbo].[CONOPS_SHOVEL_POPUP_V]
AS

SELECT shiftflag,
	   siteflag,
	   [ShovelID],
	   [Operator],
	   OperatorImageURL,
	   ReasonId,
	   ReasonDesc,
	   [TotalMaterialMined],
	   [TotalMaterialMinedTarget],
	   Payload,
	   PayloadTarget,
	   deltac,
	   DeltaCTarget,
	   IdleTime,
	   IdleTimeTarget,
	   Spotting,
	   SpottingTarget,
	   Loading,
	   LoadingTarget,
	   Dumping,
	   DumpingTarget,
       [NumberOfLoads],
	   NumberOfLoadsTarget,
	   TonsPerReadyHour,
	   TonsPerReadyHourTarget,
	   AssetEfficiency,
	   AssetEfficiencyTarget
FROM [mor].[CONOPS_MOR_SHOVEL_POPUP_V] [s] WITH (NOLOCK)
WHERE [s].siteflag = 'MOR'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   [ShovelID],
	   [Operator],
	   OperatorImageURL,
	   ReasonId,
	   ReasonDesc,
	   [TotalMaterialMined],
	   [TotalMaterialMinedTarget],
	   Payload,
	   PayloadTarget,
	   deltac,
	   DeltaCTarget,
	   IdleTime,
	   IdleTimeTarget,
	   Spotting,
	   SpottingTarget,
	   Loading,
	   LoadingTarget,
	   Dumping,
	   DumpingTarget,
       [NumberOfLoads],
	   NumberOfLoadsTarget,
	   TonsPerReadyHour,
	   TonsPerReadyHourTarget,
	   AssetEfficiency,
	   AssetEfficiencyTarget
FROM [bag].[CONOPS_BAG_SHOVEL_POPUP_V] [s] WITH (NOLOCK)
WHERE [s].siteflag = 'BAG'



