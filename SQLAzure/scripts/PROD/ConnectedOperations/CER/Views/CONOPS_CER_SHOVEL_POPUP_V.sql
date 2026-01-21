CREATE VIEW [CER].[CONOPS_CER_SHOVEL_POPUP_V] AS



-- SELECT * FROM [cer].[CONOPS_CER_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_POPUP_V]
AS

WITH DELTACTarget AS (
	SELECT TOP 1 *
	FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V]
),

DCTargetAvailability AS (
SELECT TOP 1
	ps.SITEFLAG,
	cast((AVAILABILITYELECTRICSHOVEL) as decimal(5,2)) * 100 AS AvailabilityTarget
FROM [CER].[PLAN_VALUES] ps WITH (NOLOCK)
WHERE TITLE = FORMAT(GETDATE(), 'MMM yyyy', 'en-US')
),

TONS AS (
SELECT 
	shiftid,
	shovelid,
	TotalMaterialMined AS Tons,
	TotalMaterialMoved AS TonsMoved,
	ShovelTarget AS [Target]
FROM [cer].[CONOPS_CER_OVERVIEW_V] 
),

LOADS AS (
SELECT
	shiftindex,
	site_code,
	excav,
	avg(measureton) as payload,
	count(excav) as NrofLoad
FROM dbo.lh_load WITH (nolock)
WHERE site_code = 'CER'
	AND MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CER')
GROUP BY shiftindex, site_code, excav
)

SELECT
	[s].shiftflag,
	[s].siteflag,
	[s].shiftid,
	[s].shiftindex,
	[s].[ShovelID],
	[s].[eqmttype],
	UPPER([s].Operator) AS [Operator],
	[s].OperatorId,
	[s].OperatorImageURL,
	[s].ReasonId,
	[s].ReasonDesc,
	[tn].tons AS [TotalMaterialMined],
	[tn].target AS [TotalMaterialMinedTarget],
	[tn].tonsmoved AS [TotalMaterialMoved],
	[tn].target AS [TotalMaterialMovedTarget],
	[l].payload AS Payload,
	ShovelPayloadTarget AS PayloadTarget,
	[dc].deltac,
	[dct].Delta_c_target AS DeltaCTarget,
	[dc].IdleTime,
	[dct].IdleTimeTarget,
	[dc].spottime AS Spotting,
	[dct].spottarget AS SpottingTarget,
	[dc].loadtime AS Loading,
	[dct].loadtarget AS LoadingTarget,
	[dc].DumpingTime AS Dumping,
	[dct].dumpingtarget AS DumpingTarget, 
	[dc].HangTime,
	NULL HangTimeTarget,
	[dc].EFH,
	[dct].EFHTarget,
	[l].NrofLoad AS [NumberOfLoads],
	(tn.[target]/ShovelPayloadTarget) AS NumberOfLoadsTarget,
	[tprh].TPRH AS TonsPerReadyHour,
	CASE WHEN ae.availability_pct = 0 THEN 0 ELSE
	(tn.[target] / (12 * (0.9 * ae.availability_pct))) END AS TonsPerReadyHourTarget,
	ae.Ops_efficient_pct AS AssetEfficiency,
	NULL AS AssetEfficiencyTarget,
	ROUND(ae.availability_pct,2) AS Availability,
	[dcta].AvailabilityTarget
FROM [CER].[CONOPS_CER_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
	ON [s].shiftid = [tn].shiftid
	AND [s].ShovelID = [tn].ShovelId
LEFT JOIN [cer].[CONOPS_CER_SP_DELTA_C_AVG_V] [dc]
	ON s.shiftindex = dc.shiftindex
	AND s.ShovelID = dc.excav
CROSS JOIN DELTACTarget [dct]
CROSS JOIN DCTargetAvailability [dcta]
LEFT JOIN LOADS [l]
	ON [s].shiftindex = [l].SHIFTINDEX
	AND [s].siteflag = [l].site_code
	AND [s].ShovelID = [l].excav
LEFT JOIN [CER].[CONOPS_CER_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
	ON [s].shiftindex = [tprh].shiftindex
	AND [s].siteflag = [tprh].site_code
	AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [CER].[CONOPS_CER_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (NOLOCK)
	ON [s].shiftid = [ae].shiftid
	AND [s].ShovelID = [ae].eqmt
LEFT JOIN [cer].[CONOPS_CER_SHOVEL_PAYLOAD_TARGET_V] tg
	ON s.shiftid = tg.shiftid
	AND s.ShovelID = tg.shovelid



