CREATE VIEW [saf].[CONOPS_SAF_DB_DRILL_SCORE_CARD_PER_HOUR_V] AS



--select * from [saf].[CONOPS_SAF_DB_DRILL_SCORE_CARD_PER_HOUR_V] WITH (NOLOCK) where shiftflag = 'prev'
CREATE VIEW [saf].[CONOPS_SAF_DB_DRILL_SCORE_CARD_PER_HOUR_V]
AS

	WITH DrillKPI AS (
		SELECT shiftflag,
			   siteflag,
			   ShiftStartDateTime,
			   [SHIFTINDEX],
			   DRILL_ID,
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
			   IIF(HOS > 12, 12, HOS) AS HOS
		FROM (
			SELECT a.shiftflag,
				   a.siteflag,
				   a.ShiftStartDateTime,
				   [ds].[SHIFTINDEX],
				   'D' + RIGHT('000' + SUBSTRING(DRILL_ID,CHARINDEX('-',DRILL_ID)+1,LEN(DRILL_ID)), 3) AS DRILL_ID,
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
				   CEILING(DATEDIFF(MINUTE, [a].ShiftStartDateTime, [ds].END_HOLE_TS) / 60.00) as HOS
			FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a (NOLOCK)
       		LEFT JOIN [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
       		ON [a].ShiftIndex = [ds].SHIFTINDEX AND [a].siteflag = [ds].SITE_CODE
       		WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'SAF'
		) [ds]
	),

	EqmtStatus AS (
		SELECT SHIFTINDEX,
			   Drill_ID AS eqmt,
			   [status] AS eqmtcurrstatus,
			   [MODEL] AS eqmttype,
			   ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID
								  ORDER BY startdatetime DESC) num
		FROM [saf].[drill_asset_efficiency_v] WITH (NOLOCK)
	)

	SELECT HOS,
		   DATEADD(HOUR, HOS - 1, ShiftStartDateTime) Hr,
		   shiftflag,
		   siteflag,
		   ShiftStartDateTime,
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
	FROM DrillKPI kpi
	LEFT JOIN EqmtStatus [s]
	ON kpi.SHIFTINDEX = s.SHIFTINDEX
	   AND kpi.DRILL_ID = s.eqmt AND [s].num = 1


