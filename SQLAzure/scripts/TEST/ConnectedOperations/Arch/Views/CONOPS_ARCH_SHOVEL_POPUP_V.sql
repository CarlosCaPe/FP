CREATE VIEW [Arch].[CONOPS_ARCH_SHOVEL_POPUP_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_SHOVEL_POPUP_V]
AS

WITH DELTAC AS (
	SELECT a.shiftflag,
		   a.siteflag,
		   a.shiftid,
		   a.shiftindex,
		   b.excav,
		   b.deltac,
		   b.Delta_c_target,
		   b.idletime,
		   b.idletimetarget,
		   b.spottime,
		   b.spottarget,
		   b.loadtime,
		   b.loadtarget,
		   b.DumpingTime,
		   b.dumpingtarget,
		   b.EFH,
		   b.EFHtarget,
		   b.EmptyTravel,
		   b.emptytraveltarget,
		   b.LoadedTravel,
		   b.loadedtraveltarget
	FROM dbo.shift_info_v a
	LEFT JOIN (
			SELECT dcavg.shiftid,
					dcavg.site_code,
					dcavg.excav,
					dcavg.deltac,
					ps.Delta_c_target,
					dcavg.idletime,
					ps.idletimetarget,
					dcavg.spottime,
					ps.spottarget,
					dcavg.loadtime,
					ps.loadtarget,
					dcavg.DumpingTime,
					ps.dumpingtarget,
					dcavg.EFH,
					ps.EFHtarget,
					dcavg.EmptyTravel,
					ps.emptytraveltarget,
					dcavg.LoadedTravel,
					ps.loadedtraveltarget
			FROM [Arch].[CONOPS_ARCH_SP_DELTA_C_AVG_V] dcavg
			LEFT JOIN (
				SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
					   TotalDeltaC as Delta_c_target,
					   EFH as EFHtarget,
					   '1.1' as spottarget,
					   '2.5' as loadtarget,
					   '2.5' AS  dumpingtarget,
					   shovelidletime AS idletimetarget,
					   TRUCKLOADEDTRAVEL as loadedtraveltarget, 
					   TRUCKEMPTYTRAVEL as emptytraveltarget
				FROM [Arch].[plan_values_prod_sum] (nolock)
			) ps
			on left(dcavg.shiftid,4) = ps.shiftdate
			WHERE dcavg.site_code = '<SITECODE>'  
	) b ON a.shiftid = b.shiftid and a.siteflag = b.site_code
),

TONS AS (
	SELECT actual.shiftid,
		   '<SITECODE>' [siteflag],
		   actual.shovelid,
		   sum(actual.totalmaterialmined) as tons,
		   sum(tgt.shovelshifttarget) AS  [target] 
	FROM [Arch].[CONOPS_ARCH_SHIFT_OVERVIEW_V] (NOLOCK) actual
	LEFT JOIN [Arch].[CONOPS_ARCH_SHOVEL_TARGET_V] tgt
	ON actual.shiftid = tgt.FORMATSHIFTID AND actual.ShovelId = tgt.shovel
	GROUP BY actual.shiftid,actual.shovelid
),

LOADS AS (
	SELECT  shiftindex,
			site_code,
			excav,
			avg(measureton) as payload,
			count(excav) as NrofLoad 
	FROM dbo.lh_load WITH (nolock)
	--WHERE site_code = '<SITECODE>'
	GROUP BY shiftindex, site_code, excav
)

SELECT [s].shiftflag,
	   [s].siteflag,
	   [s].shiftid,
	   [s].shiftindex,
	   [s].[ShovelID],
	   UPPER([s].Operator) AS [Operator],
	   [s].OperatorId,
	   [s].OperatorImageURL,
	   [s].ReasonId,
	   [s].ReasonDesc,
	   [tn].tons AS [TotalMaterialMined],
	   [tn].target AS [TotalMaterialMinedTarget],
	   [l].payload AS Payload,
	   '260' AS PayloadTarget,
	   [dc].deltac,
	   [dc].Delta_c_target AS DeltaCTarget,
	   [dc].IdleTime,
	   [dc].IdleTimeTarget,
	   [dc].spottime AS Spotting,
	   [dc].spottarget AS SpottingTarget,
	   [dc].loadtime AS Loading,
	   [dc].loadtarget AS LoadingTarget,
	   [dc].DumpingTime AS Dumping,
	   [dc].dumpingtarget AS DumpingTarget,
	   [dc].EFH,
	   [dc].EFHTarget,
       [l].NrofLoad AS [NumberOfLoads],
	   (tn.[target]/260.0) AS NumberOfLoadsTarget,
	   [tprh].TPRH AS TonsPerReadyHour,
	   (tn.[target] / (12 * (0.9 * ae.availability_pct))) AS TonsPerReadyHourTarget,
	   ae.Ops_efficient_pct AS AssetEfficiency,
	   NULL AS AssetEfficiencyTarget
FROM [Arch].[CONOPS_ARCH_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
ON [s].shiftid = [tn].shiftid AND [s].siteflag = [tn].siteflag
   AND [s].ShovelID = [tn].ShovelId
LEFT JOIN DELTAC [dc]
ON [s].shiftflag = [dc].shiftflag AND [s].siteflag = [dc].siteflag
   AND [s].ShovelID = [dc].excav
LEFT JOIN LOADS [l]
ON [s].shiftindex = [l].SHIFTINDEX AND [s].siteflag = [l].site_code
   AND [s].ShovelID = [l].excav
LEFT JOIN [Arch].[CONOPS_ARCH_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
ON [s].shiftindex = [tprh].shiftindex AND [s].siteflag = [tprh].site_code
   AND [s].ShovelID = [tprh].EQMT
LEFT JOIN [Arch].[CONOPS_ARCH_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] [ae] WITH (