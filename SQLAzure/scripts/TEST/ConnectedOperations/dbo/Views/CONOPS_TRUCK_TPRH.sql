CREATE VIEW [dbo].[CONOPS_TRUCK_TPRH] AS


--select * from [dbo].[CONOPS_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [dbo].[CONOPS_TRUCK_TPRH]
AS

	SELECT [tp].shiftflag,
		   [tp].[siteflag],
		   [Truck],
		   CASE WHEN (ShiftDuration/3600.00) = 0 OR [ae].Ops_efficient_pct IS NULL OR [ae].Ops_efficient_pct = 0  THEN 0
				ELSE (COALESCE(tonsHaul, 0) / (ShiftDuration/3600.00)) / ([ae].Ops_efficient_pct / 100)
		   END [tph],
		   CASE WHEN (ShiftDuration/3600.00) = 0 OR [ae].availability_pct IS NULL OR [ae].availability_pct = 0 THEN 0
				ELSE COALESCE(tonsHaul, 0) / ((ShiftDuration/3600.00) * ([ae].availability_pct / 100))
		   END [tprh],
		   [ae].use_of_availability_pct [utilization]
	FROM [mor].[CONOPS_MOR_TRUCK_TPRH] [tp] WITH(NOLOCK)
	LEFT JOIN [mor].[CONOPS_MOR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON [tp].shiftflag = [ae].shiftflag AND [tp].Truck = [ae].eqmt
	WHERE [tp].siteflag = 'MOR'

	UNION ALL

	SELECT [tp].shiftflag,
		   [tp].[siteflag],
		   [Truck],
		   CASE WHEN (ShiftDuration/3600.00) = 0 OR [ae].Ops_efficient_pct IS NULL OR [ae].Ops_efficient_pct = 0  THEN 0
				ELSE (COALESCE(tonsHaul, 0) / (ShiftDuration/3600.00)) / ([ae].Ops_efficient_pct / 100)
		   END [tph],
		   CASE WHEN (ShiftDuration/3600.00) = 0 OR [ae].availability_pct IS NULL OR [ae].availability_pct = 0 THEN 0
				ELSE COALESCE(tonsHaul, 0) / ((ShiftDuration/3600.00) * ([ae].availability_pct / 100))
		   END [tprh],
		   [ae].use_of_availability_pct [utilization]
	FROM [bag].[CONOPS_BAG_TRUCK_TPRH] [tp] WITH(NOLOCK)
	LEFT JOIN [bag].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON [tp].shiftflag = [ae].shiftflag AND [tp].Truck = [ae].eqmt
	WHERE [tp].siteflag = 'BAG'

	UNION ALL

	SELECT [tp].shiftflag,
		   [tp].[siteflag],
		   [Truck],
		   CASE WHEN (ShiftDuration/3600.00) = 0 OR [ae].Ops_efficient_pct IS NULL OR [ae].Ops_efficient_pct = 0  THEN 0
				ELSE (COALESCE(tonsHaul, 0) / (ShiftDuration/3600.00)) / ([ae].Ops_efficient_pct / 100)
		   END [tph],
		   CASE WHEN (ShiftDuration/3600.00) = 0 OR [ae].availability_pct IS NULL OR [ae].availability_pct = 0 THEN 0
				ELSE COALESCE(tonsHaul, 0) / ((ShiftDuration/3600.00) * ([ae].availability_pct / 100))
		   END [tprh],
		   [ae].use_of_availability_pct [utilization]
	FROM [saf].[CONOPS_SAF_TRUCK_TPRH] [tp] WITH(NOLOCK)
	LEFT JOIN [saf].[CONOPS_SAF_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON [tp].shiftflag = [ae].shiftflag AND [tp].Truck = [ae].eqmt
	WHERE [tp].siteflag = 'SAF'


	
	UNION ALL

	SELECT [tp].shiftflag,
		   [tp].[siteflag],
		   [Truck],
		   CASE WHEN (ShiftDuration/3600.00) = 0 OR [ae].Ops_efficient_pct IS NULL OR [ae].Ops_efficient_pct = 0 THEN 0
				ELSE (COALESCE(tonsHaul, 0) / (ShiftDuration/3600.00)) / ([ae].Ops_efficient_pct / 100)
		   END [tph],
		   CASE WHEN (ShiftDuration/3600.00) = 0 OR [ae].availability_pct IS NULL OR [ae].availability_pct = 0 THEN 0
				ELSE COALESCE(tonsHaul, 0) / ((ShiftDuration/3600.00) * ([ae].availability_pct / 100))
		   END [tprh],
		   [ae].use_of_availability_pct [utilization]
	FROM [sie].[CONOPS_SIE_TRUCK_TPRH] [tp] WITH(NOLOCK)
	LEFT JOIN [sie].[CONOPS_SIE_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON [tp].shiftflag = [ae].shiftflag AND [tp].Truck = [ae].eqmt
	WHERE [tp].siteflag = 'SIE'

	
	UNION ALL

	SELECT [tp].shiftflag,
		   [tp].[siteflag],
		   [Truck],
		   CASE WHEN (ShiftDuration/3600.00) = 0 THEN 0
				ELSE (COALESCE(tonsHaul, 0) / (ShiftDuration/3600.00)) / ([ae].Ops_efficient_pct / 100)
		   END [tph],
		   CASE WHEN (ShiftDuration/3600.00) = 0 THEN 0
				ELSE COALESCE(tonsHaul, 0) / ((ShiftDuration/3600.00) * ([ae].availability_pct / 100))
		   END [tprh],
		   [ae].use_of_availability_pct [utilization]
	FROM [cli].[CONOPS_CLI_TRUCK_TPRH] [tp] WITH(NOLOCK)
	LEFT JOIN [cli].[CONOPS_CLI_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON [tp].shiftflag = [ae].shiftflag AND [tp].Truck = [ae].eqmt
	WHERE [tp]