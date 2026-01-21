CREATE VIEW [mor].[ZZZ_CONOPS_MOR_OPERATOR_SHOVEL_V_OLD] AS




-- SELECT * FROM [MOR].[CONOPS_MOR_OPERATOR_SHOVEL_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [mor].[CONOPS_MOR_OPERATOR_SHOVEL_V_OLD]
AS

WITH OperatorDetail AS (
    SELECT [shiftflag]
        ,[siteflag]
        ,[shiftid]
        ,[SHIFTINDEX]
        ,[ShovelID]
        ,[StatusName]
        ,[CrewName]
        ,[Location]
        ,[Operator]
        ,[OperatorId]
        ,[OperatorImageURL]
    FROM [MOR].[CONOPS_MOR_SHOVEL_INFO_V] WITH (NOLOCK)
    WHERE [Operator] != 'NONE'
),


ActiveOperator AS (
    SELECT [shiftflag]
        ,[siteflag]
        ,[shiftid]
        ,[SHIFTINDEX]
        ,[ShovelID]
        ,[StatusName]
        ,[CrewName]
        ,[Location]
        ,[Operator]
        ,[OperatorId]
        ,[OperatorImageURL]
        ,'Active' AS OperatorStatus
    FROM OperatorDetail
),
 

InactiveOperator AS (
    SELECT 'CURR' AS [ShiftFlag]
        ,'MOR' AS [SiteFlag]
        ,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'CURR') AS [ShiftIndex]
        ,'NONE' AS ShovelID
        ,NULL AS [StatusName]
        ,[o].[CrewName]
        ,NULL AS [Location]
        ,[o].[Operator]
        ,[o].[OperatorId]
        ,[o].[OperatorImageURL]
        ,'Inactive' AS OperatorStatus
    FROM OperatorDetail o WITH (NOLOCK)
    LEFT JOIN ActiveOperator ao
        ON ao.[OPERATORID] = o.[OPERATORID]
        AND ao.SHIFTFLAG = 'CURR'
    WHERE ao.[OPERATORID] IS NULL
    UNION ALL
    SELECT 'PREV' AS [ShiftFlag]
        ,'MOR' AS [SiteFlag]
        ,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'PREV') AS [ShiftIndex]
        ,'NONE' AS ShovelID
        ,NULL AS [StatusName]
        ,[o].[CrewName]
        ,NULL AS [Location]
        ,[o].[Operator]
        ,[o].[OperatorId]
        ,[o].[OperatorImageURL]
        ,'Inactive' AS OperatorStatus
    FROM OperatorDetail o WITH (NOLOCK)
    LEFT JOIN ActiveOperator ao
        ON ao.[OPERATORID] = o.[OPERATORID]
        AND ao.SHIFTFLAG = 'PREV'
    WHERE ao.[OPERATORID] IS NULL
),

OperStatus AS (
	SELECT [shiftflag]
   		,[siteflag]
   		,[shiftid]
   		,[SHIFTINDEX]
   		,[ShovelID]
   		,[StatusName]
   		,[CrewName]
   		,[Location]
   		,[Operator]
   		,[OperatorId]
   		,[OperatorImageURL]
   		,[OperatorStatus]
	FROM InactiveOperator
	UNION ALL 
	SELECT [shiftflag]
   		,[siteflag]
   		,[shiftid]
   		,[SHIFTINDEX]
   		,[ShovelID]
   		,[StatusName]
   		,[CrewName]
   		,[Location]
   		,[Operator]
   		,[OperatorId]
   		,[OperatorImageURL]
   		,[OperatorStatus]
	FROM ActiveOperator
)

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
	,[shift].[ShiftStartDateTime]
	,[shift].[ShiftEndDateTime]
	,[es].[payload]
	,[es].[PayloadTarget]  
    ,[es].TonsPerReadyHour  
    ,[es].TonsPerReadyHourTarget   
    ,[es].TotalMaterialMoved AS Tons  
    ,[es].TotalMaterialMovedTarget AS TonsTarget  
    ,[es].NumberOfLoads   
    ,ROUND([es].Spotting,2) Spotting  
    ,[es].SpottingTarget  
    ,[es].TotalMaterialMined/1000.00 AS TotalMaterialMined  
    ,[es].TotalMaterialMinedTarget/1000.00 AS TotalMaterialMinedTarget  
    ,ROUND([es].UseOfAvailability,0) UseOfAvailability  
    ,ROUND([es].Loading,2) Loading  
    ,[es].LoadingTarget  
    ,ROUND([es].IdleTime,2) IdleTime  
    ,[es].IdleTimeTarget  
    ,[es].ToothMetrics  
    ,[os].[OperatorStatus]
FROM OperStatus [os]
LEFT OUTER JOIN [MOR].[CONOPS_MOR_EQMT_SHOVEL_V] [es]
	ON [os].ShiftFlag = [es].shiftflag
	AND [os].ShovelID = [es].shovelid
LEFT OUTER JOIN [MOR].[CONOPS_MOR_SHIFT_INFO_V] [shift]
	ON [os].shiftindex = [shift].shiftindex
