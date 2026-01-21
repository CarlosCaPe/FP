CREATE VIEW [mor].[ZZZ_CONOPS_MOR_OPERATOR_TRUCK_DETAIL_DELTA_C_V_OLD] AS





-- SELECT * FROM [mor].[CONOPS_MOR_OPERATOR_TRUCK_DETAIL_DELTA_C_V_OLD] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [mor].[CONOPS_MOR_OPERATOR_TRUCK_DETAIL_DELTA_C_V_OLD] 
AS


SELECT [shift].ShiftFlag
	,[shift].SiteFlag
	,[shift].ShiftId
	,[t].ShiftIndex
	,[t].TruckID
	,[t].OperatorId
	,[t].[Idle]
	,[t].[Spotting]
	,[t].[Loading]
	,[t].[Dumping]
	,[t].[EmptyTravel]
	,[t].[LoadedTravel]
	,[t].[DeltaC]
	,[t].DumpingToCrusher
	,[t].DumpingToStockpile
	,[ht].Total_Score AS HTOS
	,272 AS HTOSTarget -- Temporary Target
	,[tprh].tonsHaul AS TPRH
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
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
	FROM [mor].[pit_truck_c] [t] WITH (NOLOCK)
	LEFT JOIN [mor].[pit_worker] [w] WITH (NOLOCK)
		ON [w].Id = [t].FieldCuroper
	LEFT JOIN [dbo].[delta_c] [dc] WITH (NOLOCK)
		ON [t].[ShiftIndex] = [dc].[ShiftIndex]
		AND [t].[FieldId] = [dc].[Truck]
	GROUP BY [t].ShiftIndex, [t].FieldId, [w].FieldId, [t].SiteFlag, [t].ShiftId
) [t]
	ON [t].SHIFTINDEX = [shift].ShiftIndex
LEFT JOIN [dbo].htos [ht] WITH (NOLOCK)
	ON [t].SiteFlag = [ht].site_code
	AND RIGHT('0000000000' + [t].[OperatorId], 10) = [ht].Operator_Id
	AND [t].ShiftIndex = [ht].ShiftIndex
LEFT JOIN [mor].[CONOPS_MOR_TRUCK_TPRH] [tprh] WITH (NOLOCK)
	ON [t].ShiftId = [tprh].ShiftId
	AND [t].TruckId = [tprh].Truck

