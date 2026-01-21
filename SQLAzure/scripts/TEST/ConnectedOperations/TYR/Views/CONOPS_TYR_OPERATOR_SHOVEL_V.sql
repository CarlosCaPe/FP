CREATE VIEW [TYR].[CONOPS_TYR_OPERATOR_SHOVEL_V] AS


-- SELECT * FROM [tyr].[CONOPS_TYR_OPERATOR_SHOVEL_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [TYR].[CONOPS_TYR_OPERATOR_SHOVEL_V]
AS

WITH HT AS (
SELECT 
	site_code,
	shiftindex,
	excav,
	ROUND(AVG(hangtime)/60.0,2) hangtime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'TYR'
GROUP BY site_code, shiftindex, excav)

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
	,ISNULL(useOfAvailabilityTarget,0) UseOfAvailabilityTarget
	,[es].Loading
	,[es].LoadingTarget
	,[es].Spotting
	,[es].SpottingTarget
	,[es].IdleTime
	,[es].IdleTimeTarget 
	,[ht].Hangtime
	,0 AS HangtimeTarget
FROM [tyr].[CONOPS_TYR_OPERATOR_SHOVEL_LIST_V] [os]
LEFT JOIN [tyr].[CONOPS_TYR_SHIFT_INFO_V] [shift] 
	ON [os].shiftid = [shift].shiftid
LEFT JOIN [tyr].[CONOPS_TYR_SHOVEL_POPUP_V] [es] 
	ON [os].ShiftFlag = [es].shiftflag
	AND [os].ShovelID = [es].shovelid
LEFT JOIN [tyr].[CONOPS_TYR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae]
	ON [os].shiftid = [ae].shiftid
	AND [os].ShovelID = [ae].eqmt
LEFT JOIN HT [ht]
	ON [os].shiftindex = [ht].SHIFTINDEX
	AND [os].shovelid = [ht].EXCAV
--CROSS JOIN [tyr].[CONOPS_TYR_EQMT_ASSET_EFFICIENCY_TARGET_V] [dct]
LEFT JOIN [tyr].[CONOPS_TYR_DELTA_C_TARGET_V] [dct]
	ON [os].ShiftId = [dct].ShiftId



