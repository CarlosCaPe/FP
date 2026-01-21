CREATE VIEW [CLI].[CONOPS_CLI_DB_DRILL_SCORE_CARD_V] AS



--select * from [cli].[CONOPS_CLI_DB_DRILL_SCORE_CARD_V] WITH (NOLOCK) where shiftflag = 'prev'
CREATE VIEW [cli].[CONOPS_CLI_DB_DRILL_SCORE_CARD_V]
AS

	WITH DrillKPI AS (
		SELECT [ds].[SHIFTINDEX],
			   LEFT(DRILL_ID, 2) + RIGHT('00' + RIGHT(DRILL_ID, 1), 2) AS DRILL_ID,
			   [HORIZ_DIFF_FLAG],
			   [DEPTH_DIFF_FLAG],
			   [OVER_DRILLED],
			   [UNDER_DRILLED],
			   [PENRATE],
			   [GPS_QUALITY],
			   DRILL_HOLE,
			   START_POINT_Z,
			   ZACTUALEND,
			   HOLETIME,
			   [DEPTH],
			   OVERALLSCORE,
			   [START_HOLE_TS],
			   [END_HOLE_TS]
		FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
		WHERE [ds].[SITE_CODE] = 'CLI'
			  AND DRILL_ID IS NOT NULL
	),

	EqmtStatus AS (
		SELECT SHIFTINDEX,
			   Drill_ID AS eqmt,
			   [status] AS eqmtcurrstatus,
			   MODEL AS eqmttype,
			   ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID
								  ORDER BY startdatetime DESC) num
		FROM [cli].[drill_asset_efficiency_v] WITH (NOLOCK)
	)

	SELECT a.shiftflag,
		   a.siteflag,
		   a.ShiftStartDateTime,
		   [DRILL_ID],
		   [s].eqmttype,
		   [HORIZ_DIFF_FLAG],
		   [DEPTH_DIFF_FLAG],
		   [OVER_DRILLED],
		   [UNDER_DRILLED],
		   [PENRATE],
		   [GPS_QUALITY],
		   DRILL_HOLE,
		   START_POINT_Z,
		   ZACTUALEND,
		   HOLETIME,
		   [DEPTH],
		   OVERALLSCORE,
		   [START_HOLE_TS],
		   [END_HOLE_TS],
		   [s].eqmtcurrstatus
	FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a (NOLOCK)
	LEFT JOIN DrillKPI kpi
	ON a.ShiftIndex = kpi.SHIFTINDEX
	LEFT JOIN EqmtStatus [s]
	ON kpi.SHIFTINDEX = s.SHIFTINDEX
	   AND kpi.DRILL_ID = s.eqmt AND  [s].num = 1



