CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_SHOVEL_V] AS

  
  
  
  
  
-- SELECT * FROM [bag].[CONOPS_BAG_OPERATOR_SHOVEL_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_SHOVEL_V]  
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
FROM [bag].[CONOPS_BAG_OPERATOR_SHOVEL_LIST_V] [os]  
LEFT JOIN [bag].[CONOPS_BAG_SHIFT_INFO_V] [shift]   
 ON [os].shiftid = [shift].shiftid  
LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_POPUP] [es] WITH (NOLOCK)
 ON [os].ShiftFlag = [es].shiftflag  
 AND [os].ShovelID = [es].shovelid  
LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae]  
 ON [os].shiftid = [ae].shiftid  
 AND [os].ShovelID = [ae].eqmt  
CROSS JOIN [BAG].[CONOPS_BAG_EQMT_ASSET_EFFICIENCY_TARGET_V] [dct]  
  
  
  
  
  

