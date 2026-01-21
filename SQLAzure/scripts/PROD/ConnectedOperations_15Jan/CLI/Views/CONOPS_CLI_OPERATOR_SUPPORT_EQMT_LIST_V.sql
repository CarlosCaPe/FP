CREATE VIEW [CLI].[CONOPS_CLI_OPERATOR_SUPPORT_EQMT_LIST_V] AS









-- SELECT * FROM [CLI].[CONOPS_CLI_OPERATOR_SUPPORT_EQMT_LIST_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [CLI].[CONOPS_CLI_OPERATOR_SUPPORT_EQMT_LIST_V]
AS

WITH OperatorDetail AS (
    SELECT [shiftflag]
        ,[siteflag]
        ,[shiftid]
        ,[SHIFTINDEX]
        ,[SupportEquipmentId]
        ,[StatusName]
        ,[Crew] AS CrewName
        ,[Location]
        ,UPPER([Operator]) [Operator]
        ,CASE WHEN OperatorId IS NOT NULL THEN RIGHT(CONCAT('0000000000', OperatorId), 10) END AS OperatorId
        ,[OperatorImageURL]
    FROM [CLI].[CONOPS_CLI_EQMT_OTHER_V] WITH (NOLOCK)
    WHERE [Operator] != 'NONE'
),


ActiveOperator AS (
    SELECT [shiftflag]
        ,[siteflag]
        ,[shiftid]
        ,[SHIFTINDEX]
        ,[SupportEquipmentId]
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
		,[o].siteflag
        ,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'CURR') AS [ShiftIndex]
        ,'NONE' AS SupportEquipmentId
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
		,[o].siteflag        
		,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'PREV') AS [ShiftIndex]
        ,'NONE' AS SupportEquipmentId
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
	ROW_NUMBER() OVER(PARTITION BY SHIFTINDEX, OPERATORID, OperatorStatus ORDER BY SupportEquipmentId ASC) AS seqnum
	FROM AllOperator

)

SELECT * FROM FilterOperator
WHERE seqnum = 1



