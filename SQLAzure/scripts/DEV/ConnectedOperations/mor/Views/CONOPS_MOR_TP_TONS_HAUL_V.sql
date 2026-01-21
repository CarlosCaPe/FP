CREATE VIEW [mor].[CONOPS_MOR_TP_TONS_HAUL_V] AS


--select * from [mor].[CONOPS_MOR_TP_TONS_HAUL_V]
CREATE VIEW [mor].[CONOPS_MOR_TP_TONS_HAUL_V] 
AS

SELECT a.shiftflag,
	   a.[siteflag],
	   [Truck],
	   TonsHaul / (TMCAT_00 / 3600.00) AS TPH,
	   TonsHaul / ((TMCAT_01 + TMCAT_02) / 3600.00) AS TPRH,
	   TonsHaul / ((TMCAT_01 + TMCAT_02 + TMCAT_06 + TMCAT_09) / 3600.00) AS TPOH,
	   [ae].use_of_availability_pct [utilization]
FROM [MOR].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN [MOR].[CONOPS_MOR_TRUCK_TPRH] [tp] WITH(NOLOCK)
	ON a.shiftid = tp.ShiftId
LEFT JOIN [MOR].[CONOPS_MOR_EQMT_TIME_CATEGORY_V] [tc]
	ON a.shiftid = tc.shiftid
	AND tp.truck = tc.eqmt
	AND tc.unittype = 'Truck'
LEFT JOIN [MOR].[CONOPS_MOR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON a.shiftid = ae.shiftid
	AND [tp].Truck = [ae].eqmt


	

