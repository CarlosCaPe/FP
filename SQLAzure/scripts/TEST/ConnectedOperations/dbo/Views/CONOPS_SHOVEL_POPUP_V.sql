CREATE VIEW [dbo].[CONOPS_SHOVEL_POPUP_V] AS









-- SELECT * FROM [dbo].[CONOPS_SHOVEL_POPUP_V] WITH (NOLOCK)
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
FROM [saf].[CONOPS_SAF_SHOVEL_POPUP_V] [s] WITH (NOLOCK)
WHERE [s].siteflag = 'SAF'


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
FROM [sie].[CONOPS_SIE_SHOVEL_POPUP_V] [s] WITH (NOLOCK)
WHERE [s].siteflag = 'SIE'


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
FROM [cer].[CONOPS_CER_SHOVEL_POPUP_V] [s] WITH (NOLOCK)
WHERE [s].siteflag = 'CER'


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
FROM [cli].[CONOPS_CLI_SHOVEL_POPUP_V] [s] WITH (NOLOCK)
WHERE [s].siteflag = 'CMX'

UNION ALL

SELECT shiftf