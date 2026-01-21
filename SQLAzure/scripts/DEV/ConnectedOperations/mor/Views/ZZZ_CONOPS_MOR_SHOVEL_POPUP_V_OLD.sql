CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SHOVEL_POPUP_V_OLD] AS








-- SELECT * FROM [mor].[CONOPS_MOR_SHOVEL_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_POPUP_V_OLD]
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
			SELECT dcavg.shiftindex,
					dcavg.site_code,
					dcavg.excav,
					dcavg.deltac,
					ps.Delta_c_target,
					dcavg.idletime,
					'1.1' as idletimetarget,
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
			FROM [mor].[CONOPS_MOR_SP_DELTA_C_AVG_V] dcavg
			CROSS JOIN (
				SELECT TOP 1 
				substring(replace(DateEffective,'-',''),3,4) as shiftdate,
						DeltaC as Delta_c_target,
						EquivalentFlatHaul as EFHtarget,
						spoting as spottarget, 
						loading as loadtarget,
						(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget,
						loadedtravel as loadedtraveltarget,
						emptytravel as emptytraveltarget
				FROM [mor].[plan_values_prod_sum] (nolock)
				ORDER BY DateEffective DESC
			) ps
			
			WHERE dcavg.site_code = 'MOR'  
	) b ON a.shiftindex = b.shiftindex and a.siteflag = b.site_code
),

TONS AS (
	SELECT actual.shiftid,
		   'MOR' [siteflag],
		   actual.shovelid,
		   sum(actual.totalmaterialmined) as tons,
		   starget.[target]
	FROM [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V] (NOLOCK) actual
	LEFT JOIN (
		SELECT formatshiftid,
			   shovel,
			   sum(tons) as [target]
		FROM [mor].[plan_values] (NOLOCK) 
		GROUP BY formatshiftid, shovel
	) starget
	ON actual.shiftid = starget.formatshiftid 
	   AND actual.shovelid = starget.shovel
	GROUP BY actual.shiftid,actual.shovelid,starget.[target]
),

LOADS AS (
	SELECT  shiftindex,
			site_code,
			excav,
			avg(measureton) as payload,
			count(excav) as NrofLoad 
	FROM dbo.lh_load WITH (nolock)
	WHERE site_code = 'MOR'
	GROUP BY shiftindex, site_code, excav
)

SELECT [s].shiftflag,
	   [s].siteflag,
	   [s].shiftid,
	   [s].shiftindex,
	   [s].[ShovelID],
	   UPPER([s].Operator) AS [Operator],
	   [s].OperatorImageURL,
	   [s].ReasonId,
	   [s].ReasonDesc,
	   [tn].tons AS [TotalMaterialMined],
	   [tn].target AS [TotalMaterialMinedTarget],
	   [l].payload AS Payload,
	   '267' AS PayloadTarget,
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
	   (tn.[target]/267.0) AS NumberOfLoadsTarget,
	   [tprh].TPRH AS TonsPerReadyHour,
	   (tn.[target] / (12 * (0.9 * ae.availability_pct))) AS TonsPerReadyHourTarget,
	   ae.Ops_efficient_pct AS AssetEfficiency,
	   NULL AS AssetEfficiencyTarget
FROM [mor].[CONOPS_MOR_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN TONS [tn]
ON [s].shiftid = [tn].shiftid AND [s].siteflag = [tn].siteflag
   AND [s].ShovelID = [tn].ShovelId
LEFT JOIN DELTAC [dc]
ON [s].shiftflag = [dc].shiftflag AND [s].siteflag = [dc].siteflag
   AND [s].ShovelID = [dc].excav
LEFT JOIN LOADS [l]
ON [s].shiftindex = [l].SHIFTINDEX AND [s].siteflag = [l].site_code
   AND [s].ShovelID = [l].excav
LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_TPRH_V] [tprh] WITH (NOLOCK)
ON [s].shiftin