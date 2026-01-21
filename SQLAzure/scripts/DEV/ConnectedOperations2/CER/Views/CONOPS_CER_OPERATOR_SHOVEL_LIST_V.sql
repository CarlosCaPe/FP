CREATE VIEW [CER].[CONOPS_CER_OPERATOR_SHOVEL_LIST_V] AS









-- SELECT * FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_LIST_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [CER].[CONOPS_CER_OPERATOR_SHOVEL_LIST_V]
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
		,[Region]
        ,UPPER([Operator]) [Operator]
        ,CASE WHEN OperatorId IS NOT NULL THEN RIGHT(CONCAT('0000000000', OperatorId), 10) END AS OperatorId
        ,[OperatorImageURL]
    FROM [CER].[CONOPS_CER_SHOVEL_INFO_V] WITH (NOLOCK)
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
		,[Region]
        ,[Operator]
        ,[OperatorId]
        ,[OperatorImageURL]
        ,'Active' AS OperatorStatus
    FROM OperatorDetail
),
 

InactiveOperator AS (
    SELECT 'CURR' AS [ShiftFlag]
		,[o].siteflag
        ,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'CURR') AS [ShiftIndex]
        ,'NONE' AS ShovelID
        ,NULL AS [StatusName]
        ,[o].[CrewName]
        ,NULL AS [Location]
		,NULL AS [Region]
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
		,[o].siteflag        
		,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'PREV') AS [ShiftIndex]
        ,'NONE' AS ShovelID
        ,NULL AS [StatusName]
        ,[o].[CrewName]
        ,NULL AS [Location]
		,NULL AS [Region]
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

AllOperator AS(
	SELECT *
	FROM InactiveOperator 
	WHERE [ShiftIndex] IS NOT NULL

	UNION ALL

	SELECT *
	FROM ActiveOperator 
	WHERE [ShiftIndex] IS NOT NULL
),

FilterOperator AS(
	SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY SHIFTINDEX, OPERATORID, OperatorStatus ORDER BY ShovelID ASC) AS seqnum
	FROM AllOperator

)

SELECT * FROM FilterOperator
WHERE seqnum = 1




