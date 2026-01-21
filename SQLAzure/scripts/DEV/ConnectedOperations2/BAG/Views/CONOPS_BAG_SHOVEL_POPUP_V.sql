CREATE VIEW [BAG].[CONOPS_BAG_SHOVEL_POPUP_V] AS


-- SELECT * FROM [bag].[CONOPS_BAG_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_SHOVEL_POPUP_V]
AS

WITH DELTACTarget AS (
SELECT TOP 1
	substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
	TotalDeltaC as Delta_c_target,
	--EFH as EFHtarget,
	'1.1' as spottarget,
	'2.5' as loadtarget,
	'2.5' AS dumpingtarget,
	shovelidletime AS idletimetarget,
	TRUCKLOADEDTRAVEL as loadedtraveltarget, 
	TRUCKEMPTYTRAVEL as emptytraveltarget,
	ROUND(SHOVELAVAILABILITY,2) AS AvailabilityTarget
FROM [bag].[plan_values_prod_sum] (nolock)
ORDER BY EffectiveDate DESC
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
	a.SITE_CODE,
	b.SHIFTINDEX,
	SHOVEL_NAME AS EXCAV,
	AVG(MEASURED_PAYLOAD_SHORT_TONS) AS PAYLOAD,
	COUNT(*) AS NrOfLoad
FROM BAG.FLEET_TRUCK_CYCLE_V a
LEFT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V b
	ON a.SHIFT_ID = b.SHIFTID
WHERE MEASURED_PAYLOAD_SHORT_TONS >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'BAG')
GROUP BY SHIFTFLAG, SITE_CODE, ShiftStartDateTime, SHIFT_ID, SHIFTINDEX, SHOVEL_NAME
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
	PayloadTarget,
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
	et.EFHTarget,
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
CROSS JOIN DELTACTarget [dct]
LEFT JOIN LOADS [l]
	ON [s].shiftindex = [l].SHIFTINDEX
	AND [s].siteflag = [l].site_code
	AND [s].ShovelID = [l].excav
LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
	ON [s].shiftindex = [tprh].shiftindex
	AND [s].siteflag = [tprh].site_code
	AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (NOLOCK)
	ON [s].shiftid = [ae].shiftid
	AND [s].ShovelID = [ae].eqmt
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK)
	ON [s].siteflag = [pt].siteflag
LEFT JOIN EFHTarget et
	ON et.FORMATSHIFTID = s.shiftid




