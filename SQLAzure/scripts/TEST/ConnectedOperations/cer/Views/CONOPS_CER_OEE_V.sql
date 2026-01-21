CREATE VIEW [cer].[CONOPS_CER_OEE_V] AS

--select * from [cer].[CONOPS_CER_OEE_V]
CREATE VIEW [cer].[CONOPS_CER_OEE_V]
AS

WITH DeltaC AS(
SELECT SHIFTINDEX
	,AVG(DELTA_C) AS DeltacAVG
	,AVG(TOTALCYCLE) AS TotalCycleAVG
	,AVG(PAYLOAD) AS PayloadAVG
	,AVG(LOADTONS) AS OptimalPayload
FROM dbo.delta_c dc WITH (NOLOCK)
INNER JOIN dbo.PAYLOAD_FILTER AS pf WITH (NOLOCK) 
	ON pf.SITEFLAG = 'CER'
WHERE SITE_CODE = 'CER'
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
	,ae.efficiency * ((dc.TotalCycleAVG - dc.DeltacAVG) / dc.TotalCycleAVG) * (dc.PayloadAVG / dc.OptimalPayload) AS OEE
FROM CER.CONOPS_CER_SHIFT_INFO_V s
LEFT JOIN CER.CONOPS_CER_ASSET_EFFICIENCY_V ae ON s.shiftflag = ae.shiftflag
	AND ae.unittype = 'Camion'
LEFT JOIN DeltaC dc ON s.shiftindex = dc.shiftindex


