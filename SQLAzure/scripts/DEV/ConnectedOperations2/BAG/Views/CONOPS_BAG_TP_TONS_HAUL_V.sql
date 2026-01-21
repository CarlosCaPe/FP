CREATE VIEW [BAG].[CONOPS_BAG_TP_TONS_HAUL_V] AS


--select * from [BAG].[CONOPS_BAG_TP_TONS_HAUL_V]
CREATE VIEW [BAG].[CONOPS_BAG_TP_TONS_HAUL_V] 
AS

SELECT 
	a.shiftflag,
	a.[siteflag],
	[Truck],
	CASE WHEN TMCAT_00 = 0 THEN 0
		ELSE TonsHaul / (TMCAT_00 / 3600.00) END AS TPH,
	CASE WHEN TMCAT_01 + TMCAT_02 = 0 THEN 0
		ELSE TonsHaul / ((TMCAT_01 + TMCAT_02) / 3600.00) END AS TPRH,
	CASE WHEN TMCAT_01 + TMCAT_02 + TMCAT_06 + TMCAT_09 = 0 THEN 0
		ELSE TonsHaul / ((TMCAT_01 + TMCAT_02 + TMCAT_06 + TMCAT_09) / 3600.00) END AS TPOH,
	[ae].use_of_availability_pct [utilization]
FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_TPRH] [tp] WITH(NOLOCK)
	ON a.shiftid = tp.ShiftId
LEFT JOIN [BAG].[CONOPS_BAG_EQMT_TIME_CATEGORY_V] [tc]
	ON a.shiftid = tc.shiftid
	AND tp.truck = tc.eqmt
	AND tc.unittype = 'Truck'
LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON a.shiftid = ae.shiftid
	AND [tp].Truck = [ae].eqmt

	


