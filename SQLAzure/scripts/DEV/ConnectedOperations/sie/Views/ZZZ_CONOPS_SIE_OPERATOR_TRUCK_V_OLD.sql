CREATE VIEW [sie].[ZZZ_CONOPS_SIE_OPERATOR_TRUCK_V_OLD] AS







-- SELECT * FROM [sie].[CONOPS_SIE_OPERATOR_TRUCK_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' AND OperatorStatus = 'Active'
CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_TRUCK_V] 
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
        ,[Operator]
        ,[OperatorId]
        ,[OperatorImageURL]
    FROM [SIE].[CONOPS_SIE_TRUCK_DETAIL_V] WITH (NOLOCK)
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
        ,[Location]
        ,[Operator]
        ,[OperatorId]
        ,[OperatorImageURL]
        ,'Active' AS OperatorStatus
    FROM OperatorDetail
),
 

InactiveOperator AS (
    SELECT 'CURR' AS [ShiftFlag]
        ,'SIE' AS [SiteFlag]
        ,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'CURR') AS [ShiftIndex]
        ,'NONE' AS TruckID
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
        ,'SIE' AS [SiteFlag]
        ,[o].ShiftId
        ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'PREV') AS [ShiftIndex]
        ,'NONE' AS TruckID
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
   		,[TruckID]
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
   		,[TruckID]
   		,[StatusName]
   		,[CrewName]
   		,[Location]
   		,[Operator]
   		,[OperatorId]
   		,[OperatorImageURL]
   		,[OperatorStatus]
	FROM ActiveOperator
),

DBOSHIFTDATE AS (
	SELECT [shiftindex]
      ,[shiftdate]
      ,[site_code]
      ,[shift_code]
	FROM [dbo].[shift_date] WITH (NOLOCK)
	WHERE [site_code] = 'SIE'
),

DELTAC AS (
	SELECT [t].ShiftIndex
		,[t].ShiftId
		,[t].SiteFlag
		,[t].FieldId AS [TruckID]
		,[w].FieldId AS [OperatorId]
		,SUM([TRUCK_IDLEDELTA]) AS [Idle]
		,SUM([SPOTDELTA]) AS [Spotting]
		,SUM([LOADDELTA]) AS [Loading]
		,SUM([DUMPDELTA]) AS [Dumping]
		,SUM([ET_DELTA]) AS [EmptyTravel]
		,SUM([LT_DELTA]) AS [LoadedTravel]
		,SUM([DELTA_C]) AS [DeltaC]
		,(
			SELECT COALESCE( AVG(DumpDelta), 0)
			FROM [dbo].[delta_c] [d] WITH (NOLOCK)
			WHERE [d].Unit = 'Crusher'
			AND [d].Truck = [t].FieldId
			AND [d].ShiftIndex = [t].ShiftIndex
		) AS DumpingToCrusher
		,(
			SELECT COALESCE( AVG(DumpDelta), 0)
			FROM [dbo].[delta_c] [d] WITH (NOLOCK)
			WHERE [d].Unit != 'Stockpile'
			AND [d].Truck = [t].FieldId
			AND [d].ShiftIndex = [t].ShiftIndex
		) AS DumpingToStockpile
	FROM [SIE].[pit_truck_c] [t] WITH (NOLOCK)
	LEFT JOIN [SIE].[pit_worker] [w] WITH (NOLOCK)
		ON [w].Id = [t].FieldCuroper
	LEFT JOIN [dbo].[delta_c] [dc] WITH (NOLOCK)
		ON [t].[ShiftIndex] = [dc].[ShiftIndex]
		AND [t].[FieldId] = [dc].[Truck]
	GROUP BY [t].ShiftIndex,