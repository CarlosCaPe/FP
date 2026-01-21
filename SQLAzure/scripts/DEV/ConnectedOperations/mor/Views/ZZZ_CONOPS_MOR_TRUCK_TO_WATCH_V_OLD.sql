CREATE VIEW [mor].[ZZZ_CONOPS_MOR_TRUCK_TO_WATCH_V_OLD] AS




-- SELECT * FROM [mor].[CONOPS_MOR_TRUCK_TO_WATCH_V] WITH (NOLOCK) WHERE [TruckID] = 'T501'
CREATE VIEW [mor].[CONOPS_MOR_TRUCK_TO_WATCH_V_OLD]
AS

	SELECT [shift].shiftflag,
		   [shift].siteflag,
		   [t].TruckID,
		   [t].Operator,
		   [t].OperatorImageURL,
		   [t].Location,
		   [t].ReasonId,
		   [t].ReasonDesc,
		   --[t].StatusDesc,
		   [t].StatusName,
		   CASE WHEN ([tp].ShiftDuration/3600.00) = 0 THEN 0
				ELSE COALESCE([tp].tonsHaul, 0) / (([tp].ShiftDuration/3600.00) * [ae].availability_pct)
		   END [tprh],
		   [ae].use_of_availability_pct [utilization],
		   COALESCE([pl].AVG_Payload, 0) [AVG_Payload],
		   [pl].Target
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
	ON [shift].ShiftIndex = [t].SHIFTINDEX AND [shift].siteflag = [t].siteflag
	LEFT JOIN [mor].[CONOPS_MOR_TRUCK_TPRH] [tp] WITH(NOLOCK)
	ON [shift].shiftflag = [tp].shiftflag AND [shift].siteflag = [tp].siteflag
		AND [t].TruckID = [tp].[Truck]
	LEFT JOIN [mor].[CONOPS_MOR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON [tp].shiftflag = [ae].shiftflag  AND [shift].siteflag = [tp].siteflag
		AND [tp].Truck = [ae].eqmt
	LEFT JOIN [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
	ON [pl].shiftflag = [shift].shiftflag
		AND [t].TruckID = [pl].TRUCK

