CREATE VIEW [ABR].[CONOPS_ABR_SHOVEL_POPUP_V] AS

-- SELECT * FROM [abr].[CONOPS_ABR_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [ABR].[CONOPS_ABR_SHOVEL_POPUP_V]
AS

WITH TONS AS (
SELECT 
	shiftid,
	shovelid,
	TotalMaterialMined AS Tons,
	TotalMaterialMoved AS TonsMoved,
	ShovelTarget AS [Target]
FROM [abr].[CONOPS_ABR_OVERVIEW_V]
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
FROM ABR.SHIFT_LOAD_DETAIL_V
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
	PayloadTarget,
	[dc].deltac,
	[dct].DeltaCTarget,
	[dc].IdleTime,
	[dct].IdleTimeTarget, 
	[dc].spottime AS Spotting,
	[dct].SpottingTarget,
	[dc].loadtime AS Loading,
	[dct].LoadingTarget, 
	[dc].DumpingTime AS Dumping,
	[dct].DumpingTarget, 
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
	[dct].ShovelAssetEfficiencyTarget AS AssetEfficiencyTarget,
	ROUND(ae.availability_pct,2) AS Availability,
	NULL AvailabilityTarget 
FROM [abr].[CONOPS_ABR_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
	ON [s].shiftid = [tn].shiftid 
	AND [s].ShovelID = [tn].ShovelId
LEFT JOIN [abr].[CONOPS_ABR_SP_DELTA_C_AVG_V] [dc]
	ON s.shiftindex = dc.shiftindex
	AND s.ShovelID = dc.excav
LEFT JOIN [abr].[CONOPS_ABR_DELTA_C_TARGET_V] [dct]
	ON s.shiftid = [dct].ShiftId
LEFT JOIN LOADS [l]
	ON [s].shiftid = [l].shiftid
	AND [s].ShovelID = [l].excav
LEFT JOIN [abr].[CONOPS_ABR_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
	ON [s].shiftindex = [tprh].shiftindex 
	AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [abr].[CONOPS_ABR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (NOLOCK)
	ON [s].shiftid = [ae].shiftid
	AND [s].ShovelID = [ae].eqmt

