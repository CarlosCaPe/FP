CREATE VIEW [dbo].[CONOPS_LH_TRUCK_TO_WATCH_V] AS



CREATE VIEW [dbo].[CONOPS_LH_TRUCK_TO_WATCH_V]
AS
	SELECT [shift].shiftflag,
		   [shift].siteflag,
		   [t].TruckID,
		   [t].Location,
		   [t].StatusName,
		   CASE WHEN ([tp].ShiftDuration/3600.00) = 0 OR [ae].availability_pct IS NULL OR [ae].availability_pct = 0 THEN 0
				ELSE COALESCE([tp].tonsHaul, 0) / (([tp].ShiftDuration/3600.00) * [ae].availability_pct)
		   END [TPRH]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN [mor].[CONOPS_MOR_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
	ON [shift].ShiftIndex = [t].SHIFTINDEX AND [shift].siteflag = [t].siteflag
	LEFT JOIN [mor].[CONOPS_MOR_TRUCK_TPRH] [tp] WITH(NOLOCK)
	ON [shift].shiftflag = [tp].shiftflag AND [shift].siteflag = [tp].siteflag
		AND [t].TruckID = [tp].[Truck]
	LEFT JOIN [mor].[CONOPS_MOR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON [tp].shiftflag = [ae].shiftflag  AND [shift].siteflag = [tp].siteflag
		AND [tp].Truck = [ae].eqmt
	WHERE [shift].siteflag = 'MOR'

	UNION ALL

	SELECT [shift].shiftflag,
		   [shift].siteflag,
		   [t].TruckID,
		   [t].Location,
		   [t].StatusName,
		   CASE WHEN ([tp].ShiftDuration/3600.00) = 0 OR [ae].availability_pct IS NULL OR [ae].availability_pct = 0 THEN 0
				ELSE COALESCE([tp].tonsHaul, 0) / (([tp].ShiftDuration/3600.00) * [ae].availability_pct)
		   END [TPRH]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN [bag].[CONOPS_BAG_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
	ON [shift].ShiftIndex = [t].SHIFTINDEX AND [shift].siteflag = [t].siteflag
	LEFT JOIN [bag].[CONOPS_BAG_TRUCK_TPRH] [tp] WITH(NOLOCK)
	ON [shift].shiftflag = [tp].shiftflag AND [shift].siteflag = [tp].siteflag
		AND [t].TruckID = [tp].[Truck]
	LEFT JOIN [bag].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON [tp].shiftflag = [ae].shiftflag  AND [shift].siteflag = [tp].siteflag
		AND [tp].Truck = [ae].eqmt
	WHERE [shift].siteflag = 'BAG'

