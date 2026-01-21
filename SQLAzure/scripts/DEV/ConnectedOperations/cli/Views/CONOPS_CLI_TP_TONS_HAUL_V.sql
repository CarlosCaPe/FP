CREATE VIEW [cli].[CONOPS_CLI_TP_TONS_HAUL_V] AS

--select * from [CLI].[CONOPS_CLI_TP_TONS_HAUL_V]
CREATE VIEW [CLI].[CONOPS_CLI_TP_TONS_HAUL_V] 
AS

SELECT a.shiftflag,
	   a.[siteflag],
	   [Truck],
	   TonsHaul / (TMCAT_00 / 3600.00) AS TPH,
	   TonsHaul / ((TMCAT_01 + TMCAT_02) / 3600.00) AS TPRH,
	   TonsHaul / ((TMCAT_01 + TMCAT_02 + TMCAT_06 + TMCAT_09) / 3600.00) AS TPOH,
	   [ae].use_of_availability_pct [utilization]
FROM [CLI].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN [CLI].[CONOPS_CLI_TRUCK_TPRH] [tp] WITH(NOLOCK)
	ON a.shiftid = tp.ShiftId
LEFT JOIN [CLI].[CONOPS_CLI_EQMT_TIME_CATEGORY_V] [tc]
	ON a.shiftid = tc.shiftid
	AND tp.truck = tc.eqmt
	AND tc.unittype = 'Truck'
LEFT JOIN [CLI].[CONOPS_CLI_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON a.shiftid = ae.shiftid
	AND [tp].Truck = [ae].eqmt

	

