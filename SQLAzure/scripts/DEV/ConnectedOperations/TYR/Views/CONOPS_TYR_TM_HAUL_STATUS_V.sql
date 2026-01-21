CREATE VIEW [TYR].[CONOPS_TYR_TM_HAUL_STATUS_V] AS


-- SELECT * FROM [tyr].[CONOPS_TYR_TM_HAUL_STATUS_V] WITH (NOLOCK)
CREATE VIEW [tyr].[CONOPS_TYR_TM_HAUL_STATUS_V] 
AS

	WITH HaulStatus AS (
	
		SELECT delta.SHIFTINDEX AS SHIFTINDEX,
			   Site_code,
			   delta.DUMPNAME AS DUMPNAME,
			   SUM(delta.LT_DELTA) AS SUM_LT_DELTA,
			   AVG(delta_c) AS deltac,
			   AVG(idletime) AS idletime,
			   AVG(spottime) AS spotting,
			   AVG(loadtime) AS loading,
			   AVG(DumpingTime) AS Dumping,
			   AVG(ET_DELTA) AS EmptyTravel,
			   AVG(LT_DELTA) AS LoadedTravel,
			   CASE WHEN unit = 'Stockpile' THEN COALESCE(AVG([dumpdelta]), 0) END AS DumpingAtStockpile,
			   CASE WHEN unit = 'Crusher' THEN COALESCE(AVG([dumpdelta]), 0) END AS DumpingAtCrusher
		FROM [dbo].[delta_c] AS delta WITH (NOLOCK)
		WHERE SITE_CODE = 'TYR'
		GROUP BY delta.SHIFTINDEX,
				delta.DUMPNAME,
				Site_code,
				Unit
	)

	SELECT a.SHIFTFLAG
		  ,a.SITEFLAG
		  ,h.DUMPNAME
		  ,h.SUM_LT_DELTA AS TOTAL_MIN_OVER_EXPECTED
		  ,h.deltac
		  ,dt.DeltaCTarget
		  ,h.idletime
		  ,dt.idletimetarget
		  ,h.spotting
		  ,dt.SpottingTarget
		  ,h.loading
		  ,dt.LoadingTarget
		  ,h.Dumping
		  ,dt.DumpingTarget
		  ,h.EmptyTravel
		  ,dt.emptytraveltarget
		  ,h.LoadedTravel
		  ,dt.loadedtraveltarget
		  ,h.DumpingAtStockpile
		  ,dt.DumpingAtStockpileTarget
		  ,h.DumpingAtCrusher
		  ,dt.DumpingAtCrusherTarget
	FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a WITH (NOLOCK)
	LEFT JOIN HaulStatus [h]
	ON a.SHIFTINDEX = h.SHIFTINDEX AND a.SITEFLAG = h.SITE_CODE
	LEFT JOIN [tyr].[CONOPS_TYR_DELTA_C_DETAIL_V] [dt]
	ON a.SHIFTFLAG = dt.shiftflag AND a.SITEFLAG = dt.siteflag AND dt.Pushback = 'Overall'
	WHERE h.SUM_LT_DELTA >= 0


