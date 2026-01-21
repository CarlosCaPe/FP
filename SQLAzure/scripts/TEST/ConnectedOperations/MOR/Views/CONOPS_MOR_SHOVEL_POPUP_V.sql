CREATE VIEW [MOR].[CONOPS_MOR_SHOVEL_POPUP_V] AS

-- SELECT * FROM [mor].[CONOPS_MOR_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_POPUP_V]
AS

WITH DELTACTarget AS (
SELECT TOP 1 
	substring(replace(DateEffective,'-',''),3,4) as shiftdate,
	DeltaC as Delta_c_target,
	EquivalentFlatHaul as EFHtarget,
	spoting as spottarget, 
	loading as loadtarget,
	'1.1' idletimetarget,
	(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget,
	loadedtravel as loadedtraveltarget,
	emptytravel as emptytraveltarget,
	ElecShovelAssetEfficiency * 100 AS AssetEfficiencyTarget,
	ROUND(ElecShovelAvailability,2) * 100 AS AvailabilityTarget
FROM [mor].[plan_values_prod_sum] (nolock)
ORDER BY DateEffective DESC
),

TONS AS (
SELECT 
	shiftid,
	shovelid,
	TotalMaterialMined AS Tons,
	TotalMaterialMoved AS TonsMoved,
	ShovelTarget AS [Target]
FROM [mor].[CONOPS_MOR_OVERVIEW_V]
WHERE shovelId IS NOT NULL
),

LOADS AS (
SELECT
	SiteFlag,
	ShiftId,
	Excav,
	AVG(FieldTons) AS Payload,
	AVG(FieldLSizetons) AS PayloadTarget,
	COUNT(Excav) AS NrOfLoad
FROM MOR.SHIFT_LOAD_DETAIL_V
WHERE PayloadFilter = 1
GROUP BY SiteFlag, ShiftId, Excav
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
	--'267' AS PayloadTarget,
	PayloadTarget,
	[dc].deltac,
	[dct].Delta_c_target AS DeltaCTarget,
	[dc].IdleTime,
	[dct].IdleTimeTarget,
	[dc].spottime AS Spotting,
	[dct].spottarget AS SpottingTarget,
	[dc].loadtime AS Loading,
	CASE WHEN [s].eqmttype = 'P&H 4100A' THEN 1.4
		WHEN [s].eqmttype = 'CAT 994' THEN NULL
	ELSE 1.1 END AS LoadingTarget,
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
	AssetEfficiencyTarget,
	ROUND(ae.availability_pct,2) AS Availability,
	[dct].AvailabilityTarget
FROM [mor].[CONOPS_MOR_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
	ON [s].shiftid = [tn].shiftid 
	AND [s].ShovelID = [tn].ShovelId
CROSS JOIN DELTACTarget [dct]
LEFT JOIN LOADS [l]
	ON [s].shiftid = [l].shiftid
	AND [s].ShovelID = [l].excav
LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
	ON [s].shiftindex = [tprh].shiftindex
	AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (NOLOCK)
	ON [s].shiftid = [ae].shiftid
	AND [s].ShovelID = [ae].eqmt
LEFT JOIN [mor].[CONOPS_MOR_SP_DELTA_C_AVG_V] [dc]
	ON [s].shiftindex = dc.shiftindex
	AND [s].ShovelID = dc.excav

