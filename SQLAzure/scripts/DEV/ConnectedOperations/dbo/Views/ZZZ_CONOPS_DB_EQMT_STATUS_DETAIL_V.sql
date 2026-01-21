CREATE VIEW [dbo].[ZZZ_CONOPS_DB_EQMT_STATUS_DETAIL_V] AS

--SELECT * from [dbo].[CONOPS_DB_EQMT_STATUS_DETAIL_V]
CREATE VIEW [dbo].[CONOPS_DB_EQMT_STATUS_DETAIL_V]
AS

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Feet_Drilled]
		  ,[Holes_Drilled]
		  ,[Avail]
		  ,[UofA]
		  ,[Average_Pen_Rate]
		  ,[Depth_Drill_Score]
		  ,[Over_Drill]
		  ,[Under_Drill]
          ,[Average_GPS_Quality]
		  ,[Average_HoleTime]
		  ,[Average_First_Last_Drill]
		  ,[Avg_Time_Between_Holes]
	  FROM [mor].[CONOPS_MOR_DRILL_DETAIL_V]
	  WHERE siteflag = 'MOR'

	  UNION ALL

	  SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Feet_Drilled]
		  ,[Holes_Drilled]
		  ,[Avail]
		  ,[UofA]
		  ,[Average_Pen_Rate]
		  ,[Depth_Drill_Score]
		  ,[Over_Drill]
		  ,[Under_Drill]
          ,[Average_GPS_Quality]
		  ,[Average_HoleTime]
		  ,[Average_First_Last_Drill]
		  ,[Avg_Time_Between_Holes]
	  FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V]
	  WHERE siteflag = 'BAG'

	  UNION ALL

	  SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Feet_Drilled]
		  ,[Holes_Drilled]
		  ,[Avail]
		  ,[UofA]
		  ,[Average_Pen_Rate]
		  ,[Depth_Drill_Score]
		  ,[Over_Drill]
		  ,[Under_Drill]
          ,[Average_GPS_Quality]
		  ,[Average_HoleTime]
		  ,[Average_First_Last_Drill]
		  ,[Avg_Time_Between_Holes]
	  FROM [saf].[CONOPS_SAF_DRILL_DETAIL_V]
	  WHERE siteflag = 'SAF'

	  UNION ALL

	  SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Feet_Drilled]
		  ,[Holes_Drilled]
		  ,[Avail]
		  ,[UofA]
		  ,[Average_Pen_Rate]
		  ,[Depth_Drill_Score]
		  ,[Over_Drill]
		  ,[Under_Drill]
          ,[Average_GPS_Quality]
		  ,[Average_HoleTime]
		  ,[Average_First_Last_Drill]
		  ,[Avg_Time_Between_Holes]
	  FROM [sie].[CONOPS_SIE_DRILL_DETAIL_V]
	  WHERE siteflag = 'SIE'

	  UNION ALL

	  SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Feet_Drilled]
		  ,[Holes_Drilled]
		  ,[Avail]
		  ,[UofA]
		  ,[Average_Pen_Rate]
		  ,[Depth_Drill_Score]
		  ,[Over_Drill]
		  ,[Under_Drill]
          ,[Average_GPS_Quality]
		  ,[Average_HoleTime]
		  ,[Average_First_Last_Drill]
		  ,[Avg_Time_Between_Holes]
	  FROM [cli].[CONOPS_CLI_DRILL_DETAIL_V]
	  WHERE siteflag = 'CMX'

	  UNION ALL

	  SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Feet_Drilled]
		  ,[Holes_Drilled]
		  ,[Avail]
		  ,[UofA]
		  ,[Average_Pen_Rate]
		  ,[Depth_Drill_Score]
		  ,[Over_Drill]
		  ,[Under_Drill]
          ,[Average_GPS_Quality]
		  ,[Average_HoleTime]
		  ,[Average_First_Last_Drill]
		  ,[Avg_Time_Between_Holes]
	  FROM [chi].[CONOPS_CHI_DRILL_DETAIL_V]
	  WHERE siteflag = 'CHI'

	  UNION ALL

	  SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Feet_Drilled]
		  ,[Holes_Drilled]
		  ,[Avail]
		  ,[UofA]
		  ,[Average_Pen_Rate]
		  ,[Depth_Drill_Score]
		  ,[Over_Drill]
		  ,[Under_Drill]
          ,[Average_GPS_Quality]
		  ,[Average_HoleTime]
		  ,[Average_First_Last_Drill]
		  ,[Avg_Time_Between_Holes]
	  FROM [cer].[CONOPS_CER_DRILL_DETAIL_V]
	  WHERE siteflag = 'CER'
