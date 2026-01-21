CREATE VIEW [BAG].[CONOPS_BAG_OEE_V] AS

--select * from [bag].[CONOPS_BAG_OEE_V]
CREATE VIEW [bag].[CONOPS_BAG_OEE_V]
AS

WITH AvgPayload AS(
SELECT
	fc.SITE_CODE,
	fc.SHIFT_ID AS SHIFTID,
	COALESCE(AVG(fc.MEASURED_PAYLOAD_SHORT_TONS), 0) AS ActualPayloadAvg,
	260 AS OptimalPayload
FROM BAG.FLEET_TRUCK_CYCLE_V AS fc
INNER JOIN dbo.PAYLOAD_FILTER AS pf WITH (NOLOCK)
	ON pf.SITEFLAG = 'BAG'
WHERE fc.MEASURED_PAYLOAD_SHORT_TONS >= pf.PayloadFilterLower
GROUP BY fc.SITE_CODE, fc.SHIFT_ID
)

SELECT
	s.siteflag,
	s.shiftflag,
	s.shiftid,
	s.shiftindex,
	ae.efficiency,
	cy.AvgCycleTime,
	tg.TotalCycleTime,
	ActualPayloadAvg,
	OptimalPayload,
	(60 / AvgCycleTime) / (60 / TotalCycleTime)  AS CycleEff,
	(efficiency) * ((60 / TotalCycleTime) / (60 / AvgCycleTime)) * (ActualPayloadAvg / OptimalPayload) AS OEE
FROM BAG.CONOPS_BAG_SHIFT_INFO_V s
LEFT JOIN BAG.CONOPS_BAG_ASSET_EFFICIENCY_V ae
	ON s.shiftflag = ae.shiftflag
	AND ae.unittype = 'Truck'
LEFT JOIN BAG.CONOPS_BAG_DELTA_C_OVERALL_DETAIL_V cy
	ON s.shiftindex = cy.shiftindex
LEFT JOIN [bag].[plan_values_prod_sum] tg WITH (NOLOCK)
	ON YEAR(s.shiftstartdate) = YEAR(tg.effectivedate)
	AND MONTH(s.shiftstartdate) = MONTH(tg.effectivedate)
LEFT JOIN AvgPayload py
	ON s.shiftid = py.shiftid

