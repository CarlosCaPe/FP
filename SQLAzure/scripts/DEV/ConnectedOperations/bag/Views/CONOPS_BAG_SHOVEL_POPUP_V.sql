CREATE VIEW [bag].[CONOPS_BAG_SHOVEL_POPUP_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_SHOVEL_POPUP_V]
AS

WITH DELTACTarget AS (
SELECT
	FORMATSHIFTID AS FORMATSHIFTID ,
	B.TotalDeltaC as Delta_c_target,
	SPOTTINGDELTACTARGET AS spottarget,
	LOADINGDELTACTARGET AS loadtarget,
	DUMPINGDELTACTARGET AS dumpingtarget,
	QUEUEDELTACTARGET AS idletimetarget,
	LOADEDTRAVELDELTACTARGET AS LoadedTravelTarget,
	EMPTYTRAVELDELTACTARGET AS EmptyTravelTarget,
	DUMPINGATCRUSHER AS dumpingAtCrusherTarget,
	STOCKPILETARGETS AS dumpingatStockpileTarget,
	b.SHOVELAVAILABILITY AS AvailabilityTarget,
	b.EFH as EFHtarget
FROM [BAG].[PLAN_VALUES] A WITH (NOLOCK)
LEFT JOIN [bag].[plan_values_prod_sum] B
	ON LEFT(a.FORMATSHIFTID, 4) = FORMAT(b.EFFECTIVEDATE, 'yyMM')
),

EFHTarget AS(
SELECT 
	FORMATSHIFTID,
	EFH as EFHtarget
FROM [bag].[plan_values] with (nolock)
),

TONS AS (
SELECT 
	shiftid,
	shovelid,
	TotalMaterialMined AS Tons,
	TotalMaterialMoved AS TonsMoved,
	ShovelTarget AS [Target]
FROM [bag].[CONOPS_BAG_OVERVIEW_V]

),

LOADS AS (
SELECT
	SITE_CODE,
	SHIFT_ID AS SHIFTID,
	SHOVEL_NAME AS EXCAV,
	AVG(CASE WHEN PayloadFilter = 1
		THEN MEASURED_PAYLOAD_SHORT_TONS
		ELSE NULL END) AS PAYLOAD,
	AVG(REPORT_PAYLOAD_SHORT_TONS) AS PayloadTarget,
	COUNT(*) AS NrOfLoad
FROM BAG.FLEET_SHOVEL_CYCLE_V a
WHERE PayloadFilter = 1
GROUP BY
	SITE_CODE,
	SHIFT_ID,
	SHOVEL_NAME
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
	--'260' AS PayloadTarget,
	[l].PayloadTarget,
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
	dct.EFHTarget,
	[l].NrofLoad AS [NumberOfLoads],
	(tn.[target]/PayloadTarget) AS NumberOfLoadsTarget,
	[tprh].TPRH AS TonsPerReadyHour,
	CASE WHEN ae.availability_pct = 0 THEN 0 ELSE
	(tn.[target] / (12 * (0.9 * ae.availability_pct))) END AS TonsPerReadyHourTarget,
	ae.Ops_efficient_pct AS AssetEfficiency,
	NULL AS AssetEfficiencyTarget,
	ROUND(ae.availability_pct,2) AS Availability,
	[dct].AvailabilityTarget
FROM [BAG].[CONOPS_BAG_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
	ON [s].shiftid = [tn].shiftid
	AND [s].ShovelID = [tn].ShovelId
LEFT JOIN [bag].[CONOPS_BAG_SP_DELTA_C_AVG_V] [dc]
	ON dc.shiftindex = s.shiftindex
	AND dc.excav = s.ShovelID 
LEFT JOIN LOADS [l]
	ON [s].ShiftId = [l].ShiftId
	AND [s].ShovelID = [l].excav
LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
	ON [s].shiftindex = [tprh].shiftindex
	AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (NOLOCK)
	ON [s].shiftid = [ae].shiftid
	AND [s].ShovelID = [ae].eqmt
LEFT JOIN DELTACTarget dct
	ON dct.FORMATSHIFTID = s.shiftid


