CREATE VIEW [dbo].[CONOPS_DRILL_DETAIL_V] AS




-- SELECT * FROM [dbo].[CONOPS_DRILL_DETAIL_V] WITH (NOLOCK)
CREATE VIEW [dbo].[CONOPS_DRILL_DETAIL_V]
AS

	SELECT [d].shiftflag,
		   [d].siteflag,
		   [d].SHIFTINDEX,
		   [d].[DRILL_ID],
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [d].[Holes_Drilled],
		   [d].[Hole_Drilled_Target],
		   [d].[Feet_Drilled],
		   [d].[Feet_Drilled_Target],
		   [d].[Avail],
		   [d].[DRILLAVAILABILITY],
		   [d].[UofA],
		   [d].[DRILLUTILIZATION],
		   [d].[Average_Pen_Rate],
		   [d].[Total_Depth],
		   [d].[Over_Drill],
		   [d].[Under_Drill],
		   [d].[Average_GPS_Quality],
		   [d].[Avg_Time_Between_Holes],
		   [d].[Average_First_Last_Drill],
		   [d].[XY_Drill_Score],
		   [d].[Average_HoleTime]
	FROM [mor].[CONOPS_MOR_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'MOR'

	UNION ALL

	SELECT [d].shiftflag,
		   [d].siteflag,
		   [d].SHIFTINDEX,
		   [d].[DRILL_ID],
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [d].[Holes_Drilled],
		   [d].[Hole_Drilled_Target],
		   [d].[Feet_Drilled],
		   [d].[Feet_Drilled_Target],
		   [d].[Avail],
		   [d].[DRILLAVAILABILITY],
		   [d].[UofA],
		   [d].[DRILLUTILIZATION],
		   [d].[Average_Pen_Rate],
		   [d].[Total_Depth],
		   [d].[Over_Drill],
		   [d].[Under_Drill],
		   [d].[Average_GPS_Quality],
		   [d].[Avg_Time_Between_Holes],
		   [d].[Average_First_Last_Drill],
		   [d].[XY_Drill_Score],
		   [d].[Average_HoleTime]
	FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'BAG'

	UNION ALL

	SELECT [d].shiftflag,
		   [d].siteflag,
		   [d].SHIFTINDEX,
		   [d].[DRILL_ID],
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [d].[Holes_Drilled],
		   [d].[Hole_Drilled_Target],
		   [d].[Feet_Drilled],
		   [d].[Feet_Drilled_Target],
		   [d].[Avail],
		   [d].[DRILLAVAILABILITY],
		   [d].[UofA],
		   [d].[DRILLUTILIZATION],
		   [d].[Average_Pen_Rate],
		   [d].[Total_Depth],
		   [d].[Over_Drill],
		   [d].[Under_Drill],
		   [d].[Average_GPS_Quality],
		   [d].[Avg_Time_Between_Holes],
		   [d].[Average_First_Last_Drill],
		   [d].[XY_Drill_Score],
		   [d].[Average_HoleTime]
	FROM [saf].[CONOPS_SAF_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'SAF'

	UNION ALL

	SELECT [d].shiftflag,
		   [d].siteflag,
		   [d].SHIFTINDEX,
		   [d].[DRILL_ID],
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [d].[Holes_Drilled],
		   [d].[Hole_Drilled_Target],
		   [d].[Feet_Drilled],
		   [d].[Feet_Drilled_Target],
		   [d].[Avail],
		   [d].[DRILLAVAILABILITY],
		   [d].[UofA],
		   [d].[DRILLUTILIZATION],
		   [d].[Average_Pen_Rate],
		   [d].[Total_Depth],
		   [d].[Over_Drill],
		   [d].[Under_Drill],
		   [d].[Average_GPS_Quality],
		   [d].[Avg_Time_Between_Holes],
		   [d].[Average_First_Last_Drill],
		   [d].[XY_Drill_Score],
		   [d].[Average_HoleTime]
	FROM [sie].[CONOPS_SIE_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'SIE'

	UNION ALL

	SELECT [d].shiftflag,
		   [d].siteflag,
		   [d].SHIFTINDEX,
		   [d].[DRILL_ID],
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [d].[Holes_Drilled],
		   [d].[Hole_Drilled_Target],
		   [d].[Feet_Drilled],
		   [d].[Feet_Drilled_Target],
		   [d].[Avail],
		   [d].[DRILLAVAILABILITY],
		   [d].[UofA],
		   [d].[DRILLUTILIZATION],
		   [d].[Average_Pen_Rate],
		   [d].[Total_Depth],
		   [d].[Over_Drill],
		   [d].[Under_Drill],
		   [d].[Average_GPS_Quality],
		   [d].[Avg_Time_Between_Holes],
		   [d].[Average_First_Last_Drill],
		   [d].[XY_Drill_Score],
		   [d].[Average_HoleTime]
	FROM [chi].[CONOPS_CHI_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'CHI'

	UNION ALL

	SELECT [d].shiftflag,
		   [d].siteflag,
		   [d].SHIFTINDEX,
		   [d].[DRILL_ID],
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [d].[Holes_Drilled],
		   [d].[Hole_Drilled_Target],
		   [d].[Feet_Drilled