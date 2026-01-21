CREATE VIEW [dbo].[CONOPS_DRILL_DETAIL_PER_HOUR_V] AS


-- SELECT * FROM [dbo].[CONOPS_DRILL_DETAIL_PER_HOUR_V] WITH (NOLOCK)
CREATE VIEW [dbo].[CONOPS_DRILL_DETAIL_PER_HOUR_V]
AS

	SELECT [dh].shiftflag,
		   [dh].siteflag,
		   [d].SHIFTINDEX,
		   [dh].[DRILL_ID],
		   [dh].HOS,
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [dh].[Holes_Drilled],
		   [dh].[Feet_Drilled],
		   [dh].[UofA],
		   [dh].[Average_Pen_Rate],
		   [dh].[Total_Depth],
		   [dh].[Over_Drill],
		   [dh].[Under_Drill],
		   [dh].[Average_GPS_Quality],
		   [dh].[Avg_Time_Between_Holes],
		   [dh].[Average_First_Last_Drill],
		   [dh].[XY_Drill_Score],
		   [dh].[Average_HoleTime]
	FROM [mor].[CONOPS_MOR_DRILL_DETAIL_V] [d]
	LEFT JOIN [mor].[CONOPS_MOR_DRILL_DETAIL_PER_HOUR_V] [dh]
	ON [d].shiftflag = [dh].shiftflag AND [d].siteflag = [dh].siteflag
	   AND [d].DRILL_ID = [dh].DRILL_ID
	WHERE [d].siteflag = 'MOR'

	UNION ALL

	SELECT [dh].shiftflag,
		   [dh].siteflag,
		   [d].SHIFTINDEX,
		   [dh].[DRILL_ID],
		   [dh].HOS,
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [dh].[Holes_Drilled],
		   [dh].[Feet_Drilled],
		   [dh].[UofA],
		   [dh].[Average_Pen_Rate],
		   [dh].[Total_Depth],
		   [dh].[Over_Drill],
		   [dh].[Under_Drill],
		   [dh].[Average_GPS_Quality],
		   [dh].[Avg_Time_Between_Holes],
		   [dh].[Average_First_Last_Drill],
		   [dh].[XY_Drill_Score],
		   [dh].[Average_HoleTime]
	FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V] [d]
	LEFT JOIN [bag].[CONOPS_BAG_DRILL_DETAIL_PER_HOUR_V] [dh]
	ON [d].shiftflag = [dh].shiftflag AND [d].siteflag = [dh].siteflag
	   AND [d].DRILL_ID = [dh].DRILL_ID
	WHERE [d].siteflag = 'BAG'

	UNION ALL

	SELECT [dh].shiftflag,
		   [dh].siteflag,
		   [d].SHIFTINDEX,
		   [dh].[DRILL_ID],
		   [dh].HOS,
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [dh].[Holes_Drilled],
		   [dh].[Feet_Drilled],
		   [dh].[UofA],
		   [dh].[Average_Pen_Rate],
		   [dh].[Total_Depth],
		   [dh].[Over_Drill],
		   [dh].[Under_Drill],
		   [dh].[Average_GPS_Quality],
		   [dh].[Avg_Time_Between_Holes],
		   [dh].[Average_First_Last_Drill],
		   [dh].[XY_Drill_Score],
		   [dh].[Average_HoleTime]
	FROM [saf].[CONOPS_saf_DRILL_DETAIL_V] [d]
	LEFT JOIN [saf].[CONOPS_SAF_DRILL_DETAIL_PER_HOUR_V] [dh]
	ON [d].shiftflag = [dh].shiftflag AND [d].siteflag = [dh].siteflag
	   AND [d].DRILL_ID = [dh].DRILL_ID
	WHERE [d].siteflag = 'SAF'

	UNION ALL

	SELECT [dh].shiftflag,
		   [dh].siteflag,
		   [d].SHIFTINDEX,
		   [dh].[DRILL_ID],
		   [dh].HOS,
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [dh].[Holes_Drilled],
		   [dh].[Feet_Drilled],
		   [dh].[UofA],
		   [dh].[Average_Pen_Rate],
		   [dh].[Total_Depth],
		   [dh].[Over_Drill],
		   [dh].[Under_Drill],
		   [dh].[Average_GPS_Quality],
		   [dh].[Avg_Time_Between_Holes],
		   [dh].[Average_First_Last_Drill],
		   [dh].[XY_Drill_Score],
		   [dh].[Average_HoleTime]
	FROM [sie].[CONOPS_SIE_DRILL_DETAIL_V] [d]
	LEFT JOIN [sie].[CONOPS_SIE_DRILL_DETAIL_PER_HOUR_V] [dh]
	ON [d].shiftflag = [dh].shiftflag AND [d].siteflag = [dh].siteflag
	   AND [d].DRILL_ID = [dh].DRILL_ID
	WHERE [d].siteflag = 'SIE'

	UNION ALL

	SELECT [dh].shiftflag,
		   [dh].siteflag,
		   [d].SHIFTINDEX,
		   [dh].[DRILL_ID],
		   [dh].HOS,
		   [d].eqmtcurrstatus,
		   [d].reasonidx,
		   [d].reasons,
		   [dh].[Holes_Drilled],
		   [dh].[Feet_Drilled],
		   [dh].[UofA],
		   [dh].[Average_Pen_Rate],
		   [dh].[Total_Depth],
		   [dh].[Over_Drill],
		   [dh].[Under_Drill],
		   [dh].[Average_GPS_Quality],
		   [dh].[Avg_Time_Between_Holes],
		   [dh].[Average_First_Last_Drill],
		   [dh].[XY_Drill_Score],
		   [dh].[Average_HoleTime]
	FROM [chi].[CONOPS_CHI_DRILL_DETAIL_V] [d]
	LEFT JOIN [chi].[CONOPS_CHI_DRILL_DETAIL_PER_HOUR_V] [dh]
	ON [d].shiftflag = [dh].shiftflag AND [d].siteflag = [dh].siteflag
	   AND [d].DRILL_ID = [dh].DRILL_ID
	WHERE 