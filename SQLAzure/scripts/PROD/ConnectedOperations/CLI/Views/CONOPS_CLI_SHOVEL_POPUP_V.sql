CREATE VIEW [CLI].[CONOPS_CLI_SHOVEL_POPUP_V] AS


-- SELECT * FROM [cli].[CONOPS_CLI_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [cli].[CONOPS_CLI_SHOVEL_POPUP_V]
AS

WITH DELTACTarget AS (
SELECT TOP 1
	8.6 Delta_c_target,
	2.12 idletimetarget,
	1.1 spottarget,
	8.3 loadtimetarget,
	3.73 dumpingtarget,
	ps.EFHtarget,
	22.9 emptytraveltarget,
	11.4 loadedtraveltarget,
	NULL AssetEfficiencyTarget,
	av.AvailabilityTarget
FROM (
	SELECT
		TOP 1
		EFH as EFHtarget
		FROM [cli].[plan_values] (nolock)
		ORDER BY shiftid DESC
) ps
CROSS JOIN (SELECT TOP 1 cast((SHOVELAVAILABILITY) as decimal(5,2)) * 100AS AvailabilityTarget
	FROM [CLI].[PLAN_VALUES_MONTHLY_TARGET] WITH (NOLOCK) ORDER BY ID DESC) av
),

TONS AS (
SELECT 
	shiftid,
	shovelid,
	TotalMaterialMined AS Tons,
	TotalMaterialMoved AS TonsMoved,
	ShovelTarget AS [Target]
FROM [cli].[CONOPS_CLI_OVERVIEW_V]
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
WHERE site_code = 'CLI' 
	AND MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CLI')
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
	[tn].tons AS [TotalMaterialMined],
	[tn].target AS [TotalMaterialMinedTarget],
	[tn].tonsmoved AS [TotalMaterialMoved],
	[tn].target AS [TotalMaterialMovedTarget],
	[l].payload AS Payload,
	--'200' AS PayloadTarget,
	PayloadTarget,
	[dc].deltac,
	[dct].Delta_c_target AS DeltaCTarget,
	[dc].IdleTime,
	[dct].IdleTimeTarget,
	[dc].spottime AS Spotting,
	[dct].spottarget AS SpottingTarget,
	[dc].loadtime AS Loading,
	[dct].LoadTimeTarget AS LoadingTarget,
	[dc].DumpingTime AS Dumping,
	[dct].dumpingtarget AS DumpingTarget,
	[dc].HangTime,
	NULL HangTimeTarget,
	[dc].EFH,
	[dct].EFHTarget,
	[l].NrofLoad AS [NumberOfLoads],
	(tn.[target]/PayloadTarget) AS NumberOfLoadsTarget,
	[tprh].TPRH AS TonsPerReadyHour,
	CASE WHEN ae.availability_pct = 0 THEN 0 ELSE
	(tn.[target] / (12 * (0.9 * ae.availability_pct))) END AS TonsPerReadyHourTarget,
	ae.Ops_efficient_pct AS AssetEfficiency,
	[dct].AssetEfficiencyTarget,
	ROUND(ae.availability_pct,2) AS Availability,
	[dct].AvailabilityTarget
FROM [CLI].[CONOPS_CLI_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
	ON [s].shiftid = [tn].shiftid 
	AND [s].ShovelID = [tn].ShovelId
LEFT JOIN [cli].[CONOPS_CLI_SP_DELTA_C_AVG_V] [dc] 
	ON s.shiftindex = dc.shiftindex 
	AND s.ShovelID = dc.excav
CROSS JOIN DELTACTarget [dct]
LEFT JOIN LOADS [l]
	ON [s].shiftindex = [l].SHIFTINDEX 
	AND [s].ShovelID = [l].excav
LEFT JOIN [CLI].[CONOPS_CLI_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
	ON [s].shiftindex = [tprh].shiftindex 
	AND [s].siteflag = [tprh].site_code
	AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [CLI].[CONOPS_CLI_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (NOLOCK)
	ON [s].shiftid = [ae].shiftid 
	AND [s].ShovelID = [ae].eqmt
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK) 
	ON [s].siteflag = [pt].siteflag



