CREATE VIEW [SAF].[CONOPS_SAF_OPERATOR_TRUCK_LIST_V] AS









-- SELECT * FROM [saf].[CONOPS_SAF_OPERATOR_TRUCK_LIST_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' 
CREATE VIEW [saf].[CONOPS_SAF_OPERATOR_TRUCK_LIST_V] 
AS

WITH OperatorDetail AS (
    SELECT [shiftflag]
        ,[siteflag]
        ,[shiftid]
        ,[SHIFTINDEX]
        ,[TruckID]
        ,[StatusName]
        ,[CrewName]
        ,[Location]
		,[Region]
        ,UPPER([Operator]) [Operator]
        ,[OperatorId]
        ,[OperatorImageURL]
    FROM [saf].[CONOPS_SAF_TRUCK_DETAIL_V] WITH (NOLOCK)
    WHERE [Operator] != 'NONE'
),


ActiveOperator AS (
    SELECT [shiftflag]
        ,[siteflag]
        ,[shiftid]
        ,[SHIFTINDEX]
        ,[TruckID]
        ,[StatusName]
        ,[CrewName]
		,[Region]
        ,[Location]
        ,[Operator]
        ,[OperatorId]
        ,[OperatorImageURL]
        ,'Active' AS OperatorStatus
    FROM OperatorDetail
),
 

InactiveOperator AS (
    SELECT 'CURR' AS [ShiftFlag]
        ,[o].[SiteFlag]
        ,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'CURR') AS [ShiftIndex]
        ,'NONE' AS TruckID
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
        ,[o].[SiteFlag]
        ,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'PREV') AS [ShiftIndex]
        ,'NONE' AS TruckID
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
    WHERE ao.[OPERATORID] IS NULL),

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
	ROW_NUMBER() OVER(PARTITION BY SHIFTINDEX, OPERATORID, OperatorStatus ORDER BY TruckID ASC) AS seqnum
	FROM AllOperator

)

SELECT * FROM FilterOperator
WHERE seqnum = 1




