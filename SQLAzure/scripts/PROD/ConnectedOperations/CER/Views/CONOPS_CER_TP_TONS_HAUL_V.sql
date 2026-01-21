CREATE VIEW [CER].[CONOPS_CER_TP_TONS_HAUL_V] AS

--select * from [CER].[CONOPS_CER_TP_TONS_HAUL_V]
CREATE VIEW [CER].[CONOPS_CER_TP_TONS_HAUL_V] 
AS

SELECT a.shiftflag,
	   a.[siteflag],
	   [Truck],
	   TonsHaul / (TMCAT_00 / 3600.00) AS TPH,
	   TonsHaul / ((TMCAT_01 + TMCAT_02) / 3600.00) AS TPRH,
	   TonsHaul / ((TMCAT_01 + TMCAT_02 + TMCAT_06 + TMCAT_09) / 3600.00) AS TPOH,
	   [ae].use_of_availability_pct [utilization]
FROM [CER].[CONOPS_CER_SHIFT_INFO_V] a
LEFT JOIN [CER].[CONOPS_CER_TRUCK_TPRH] [tp] WITH(NOLOCK)
	ON a.shiftid = tp.ShiftId
LEFT JOIN [CER].[CONOPS_CER_EQMT_TIME_CATEGORY_V] [tc]
	ON a.shiftid = tc.shiftid
	AND tp.truck = tc.eqmt
	AND tc.unittype = 'Camion'
LEFT JOIN [CER].[CONOPS_CER_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
	ON a.shiftid = ae.shiftid
	AND [tp].Truck = [ae].eqmt

	

