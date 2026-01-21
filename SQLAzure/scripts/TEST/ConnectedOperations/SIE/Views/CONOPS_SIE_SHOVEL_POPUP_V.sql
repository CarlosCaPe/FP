CREATE VIEW [SIE].[CONOPS_SIE_SHOVEL_POPUP_V] AS

-- SELECT * FROM [sie].[CONOPS_SIE_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [sie].[CONOPS_SIE_SHOVEL_POPUP_V]
AS

WITH DELTACTarget AS (
SELECT TOP 1
	--substring(replace(DateEffective,'-',''),3,4) as shiftdate,
	substring(replace(cast(getdate() as date),'-',''),3,4) as shiftdate,
	DeltaC as Delta_c_target,
	EquivalentFlatHaul as EFHtarget,
	'1.1' as spottarget,
	(dumpingatcrusher + dumpingatstockpile) AS dumpingtarget,
	idletime AS idletimetarget,
	LOADEDTRAVEL as loadedtraveltarget, 
	EMPTYTRAVEL as emptytraveltarget,
	LOADINGASSETEFFICIENCY as AssetEfficiencyTarget,
	ELECSHOVELAVAILABILITY AS AvailabilityTarget
FROM [sie].[plan_values_prod_sum] (nolock)
ORDER BY DateEffective DESC
),

LOADTIME AS (
SELECT 
    SUBSTRING(REPLACE(CAST(GETDATE() AS DATE), '-', ''), 3, 4) AS shiftdate,
    CASE 
        WHEN ShovelId LIKE '%S43%' THEN 'S43'
        WHEN ShovelId LIKE '%S44%' THEN 'S44'
        WHEN ShovelId LIKE '%S48%' THEN 'S48'
        WHEN ShovelId LIKE '%S45%' THEN 'S45'
        WHEN ShovelId LIKE '%L50%' THEN 'L50'
        WHEN ShovelId LIKE '%L98%' THEN 'L98'
    END AS Shovelid,
    LoadTimeTarget
FROM (
    SELECT TOP 1
        S43LOADING,
        S44LOADING,
        S48LOADING,
        S45LOADING,
        L50LOADING,
        L98LOADING
    FROM [sie].[plan_values_prod_sum] 
    ORDER BY DateEffective DESC
) shv
UNPIVOT (
    LoadTimeTarget FOR ShovelId IN (S43LOADING, S44LOADING, S48LOADING, S45LOADING, L50LOADING, L98LOADING)
) unpiv
),

TONS AS (
SELECT 
	shiftid,
	shovelid,
	TotalMaterialMined AS Tons,
	TotalMaterialMoved AS TonsMoved,
	ShovelTarget AS [Target]
FROM [sie].[CONOPS_SIE_OVERVIEW_V]
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
FROM SIE.SHIFT_LOAD_DETAIL_V
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
	[tn].tons AS [TotalMaterialMined],
	[tn].target AS [TotalMaterialMinedTarget],
	[tn].tonsmoved AS [TotalMaterialMoved],
	[tn].target AS [TotalMaterialMovedTarget],
	[l].payload AS Payload,
	--'269' AS PayloadTarget,
	PayloadTarget,
	[dc].deltac,
	[dct].Delta_c_target AS DeltaCTarget,
	[dc].IdleTime,
	[dct].IdleTimeTarget,
	[dc].spottime AS Spotting,
	[dct].spottarget AS SpottingTarget,
	[dc].loadtime AS Loading,
	[lt].LoadTimeTarget AS LoadingTarget,
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
FROM [SIE].[CONOPS_SIE_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
	ON [s].shiftid = [tn].shiftid
	AND [s].ShovelID = [tn].ShovelId
CROSS JOIN DELTACTarget [dct]
LEFT JOIN [sie].[CONOPS_SIE_SP_DELTA_C_AVG_V] [dc]
	ON [s].shiftindex = [dc].shiftindex
	AND [s].ShovelID = [dc].excav
LEFT JOIN LOADS [l]
	ON [s].shiftid = [l].shiftid
	AND [s].ShovelID = [l].excav
LEFT JOIN [SIE].[CONOPS_SIE_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
	ON [s].shiftindex = [tprh].shiftindex
	AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [SIE].[CONOPS_SIE_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (NOLOCK)
	ON [s].shiftid = [ae].shiftid
	AND [s].ShovelID = [ae].eqmt
LEFT JOIN LOADTIME [lt] 
	ON left(s.shiftid,4) = lt.shiftdate
	AND dc.excav = lt.Shovelid 
