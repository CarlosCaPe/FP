CREATE VIEW [mor].[CONOPS_MOR_OPERATOR_SHOVEL_V] AS

  
  
  
  
  
-- SELECT * FROM [MOR].[CONOPS_MOR_OPERATOR_SHOVEL_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [MOR].[CONOPS_MOR_OPERATOR_SHOVEL_V]  
AS  
  
SELECT   
  [os].[shiftflag]  
 ,[os].[siteflag]  
 ,[os].[shiftid]  
 ,[os].[SHIFTINDEX]  
 ,[os].[ShovelID]  
 ,[os].[StatusName]  
 ,[os].[CrewName]  
 ,[os].[Location]  
 ,[os].[Operator]  
 ,[os].[OperatorId]  
 ,[os].[OperatorImageURL]  
 ,[os].[OperatorStatus]  
 ,[shift].[ShiftStartDateTime]  
 ,[shift].[ShiftEndDateTime]  
 ,[es].TonsPerReadyHour  
 ,[es].TonsPerReadyHourTarget  
 ,[es].[payload]  
 ,[es].[PayloadTarget]  
 ,[es].TotalMaterialMined   
 ,[es].TotalMaterialMinedTarget  
 ,[es].TotalMaterialMoved   
 ,[es].TotalMaterialMovedTarget  
 ,0 AS ToothMetrics  
 ,0 AS ToothMetricsTarget  
 ,ISNULL([ae].use_of_availability_pct,0) UseOfAvailability  
 ,ISNULL(ShovelUtilizationTarget,0) UseOfAvailabilityTarget  
 ,[es].Loading  
 ,[es].LoadingTarget  
 ,[es].Spotting  
 ,[es].SpottingTarget  
 ,[es].IdleTime  
 ,[es].IdleTimeTarget   
 ,[es].Hangtime  
 ,[es].HangtimeTarget  
FROM [MOR].[CONOPS_MOR_OPERATOR_SHOVEL_LIST_V] [os]  
LEFT JOIN [MOR].[CONOPS_MOR_SHIFT_INFO_V] [shift]   
 ON [os].shiftid = [shift].shiftid  
LEFT JOIN [MOR].[CONOPS_MOR_SHOVEL_POPUP] [es] WITH (NOLOCK)
 ON [os].ShiftFlag = [es].shiftflag  
 AND [os].ShovelID = [es].shovelid  
LEFT JOIN [MOR].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae]  
 ON [os].shiftid = [ae].shiftid  
 AND [os].ShovelID = [ae].eqmt   
CROSS JOIN [MOR].[CONOPS_MOR_EQMT_ASSET_EFFICIENCY_TARGET_V] [dct]  
  
  
  
  

