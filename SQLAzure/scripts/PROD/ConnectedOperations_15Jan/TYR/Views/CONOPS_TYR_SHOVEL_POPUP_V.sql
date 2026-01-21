CREATE VIEW [TYR].[CONOPS_TYR_SHOVEL_POPUP_V] AS


-- SELECT * FROM [tyr].[CONOPS_TYR_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [TYR].[CONOPS_TYR_SHOVEL_POPUP_V]
AS


WITH TONS AS (
SELECT 
	shiftid,
	shovelid,
	TotalMaterialMined AS Tons,
	TotalMaterialMoved AS TonsMoved,
	ShovelTarget AS [Target]
	FROM [tyr].[CONOPS_TYR_OVERVIEW_V]
WHERE shovelId IS NOT NULL 
),

LOADS AS (
SELECT
	shiftindex,
	site_code,
	excav,
	avg(measureton) as payload,
	count(excav) as NrofLoad 
FROM dbo.lh_load WITH (nolock)
WHERE site_code = 'TYR'
	AND MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'TYR')
GROUP BY shiftindex, site_code, excav
)

SELECT
	[s].shiftflag,
	[s].siteflag,
	[s].shiftid,
	[s].shiftindex,
	[s].[ShovelID],
	[s].eqmttype,
	UPPER([s].Operator) AS [Operator],
	[s].OperatorId,
	[s].OperatorImageURL,
	[s].ReasonId,
	[s].ReasonDesc,
	--[s].StatusName,
	[tn].tons AS [TotalMaterialMined],
	[tn].target AS [TotalMaterialMinedTarget],
	[tn].tonsmoved AS [TotalMaterialMoved],
	[tn].target AS [TotalMaterialMovedTarget],
	[l].payload AS Payload,
	PayloadTarget,
	[dc].deltac,
	[tg].DeltaCTarget,
	[dc].IdleTime,
	[tg].IdleTimeTarget,
	[dc].spottime AS Spotting,
	[tg].SpottingTarget,
	[dc].loadtime AS Loading,
	[tg].LoadingTarget,
	[dc].DumpingTime AS Dumping,
	[tg].DumpingTarget,
	[dc].HangTime,
	NULL AS HangTimeTarget,
	[dc].EFH,
	[tg].EFHTarget,
	[l].NrofLoad AS [NumberOfLoads],
	(tn.[target]/PayloadTarget) AS NumberOfLoadsTarget,
	[tprh].TPRH AS TonsPerReadyHour,
	CASE WHEN ae.availability_pct = 0 THEN 0 ELSE
	(tn.[target] / (12 * (0.9 * ae.availability_pct))) END AS TonsPerReadyHourTarget,
	ae.Ops_efficient_pct AS AssetEfficiency,
	NULL AS AssetEfficiencyTarget,
	ROUND(ae.availability_pct,2) AS Availability,
	[tg].AvailabilityTarget
FROM [tyr].[CONOPS_TYR_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
	ON [s].shiftid = [tn].shiftid
	AND [s].ShovelID = [tn].ShovelId
LEFT JOIN [tyr].[CONOPS_TYR_SP_DELTA_C_AVG_V] [dc]
	ON s.shiftindex = dc.shiftindex
	AND s.ShovelID = dc.excav
LEFT JOIN [tyr].[CONOPS_TYR_DELTA_C_TARGET_V][tg]
	ON s.shiftid = [tg].ShiftId
LEFT JOIN LOADS [l]
	ON [s].shiftindex = [l].SHIFTINDEX
	AND [s].siteflag = [l].site_code
	AND [s].ShovelID = [l].excav
LEFT JOIN [tyr].[CONOPS_TYR_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
	ON [s].shiftindex = [tprh].shiftindex
	AND [s].siteflag = [tprh].site_code
	AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [tyr].[CONOPS_TYR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (NOLOCK)
	ON [s].shiftid = [ae].shiftid
	AND [s].ShovelID = [ae].eqmt
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK)
	ON [s].siteflag = [pt].siteflag



