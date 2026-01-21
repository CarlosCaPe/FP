CREATE VIEW [BAG].[CONOPS_BAG_OEE_V] AS

--select * from [bag].[CONOPS_BAG_OEE_V]
CREATE VIEW [bag].[CONOPS_BAG_OEE_V]
AS

WITH DeltaC AS(
SELECT SHIFTINDEX
	,AVG(DELTA_C) AS DeltacAVG
	,AVG(TOTALCYCLE) AS TotalCycleAVG
	,AVG(PAYLOAD) AS PayloadAVG
	,AVG(LOADTONS) AS OptimalPayload
FROM dbo.delta_c dc WITH (NOLOCK)
INNER JOIN dbo.PAYLOAD_FILTER AS pf WITH (NOLOCK) 
	ON pf.SITEFLAG = 'BAG'
WHERE SITE_CODE = 'BAG'
	AND (pf.PayloadFilterLower IS NULL OR PAYLOAD >= pf.PayloadFilterLower)
	AND (pf.PayloadFilterUpper IS NULL OR PAYLOAD <= pf.PayloadFilterUpper)
GROUP BY SHIFTINDEX
)

SELECT s.siteflag
	,s.shiftflag
	,s.shiftid
	,s.shiftindex
	,ae.Efficiency AS TruckEfficiency
	,dc.TotalCycleAVG
	,dc.DeltacAVG
	,dc.PayloadAVG
	,dc.OptimalPayload
	,CASE WHEN TotalCycleAVG = 0 OR OptimalPayload = 0 THEN 0
		ELSE ae.efficiency * ((dc.TotalCycleAVG - dc.DeltacAVG) / dc.TotalCycleAVG) * (dc.PayloadAVG / dc.OptimalPayload)
		END AS OEE
FROM BAG.CONOPS_BAG_SHIFT_INFO_V s
LEFT JOIN BAG.CONOPS_BAG_ASSET_EFFICIENCY_V ae ON s.shiftflag = ae.shiftflag
	AND ae.unittype = 'Truck'
LEFT JOIN DeltaC dc ON s.shiftindex = dc.shiftindex

