CREATE VIEW [ABR].[CONOPS_ABR_DB_DRILL_TO_WATCH_V] AS



--select * from [abr].[CONOPS_ABR_DB_DRILL_TO_WATCH_V] WITH (NOLOCK) where shiftflag = 'prev'
CREATE VIEW [ABR].[CONOPS_ABR_DB_DRILL_TO_WATCH_V]
AS

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[DRILL_ID]
		  ,[MODEL] as eqmttype
		  ,[OperatorImageURL]
		  ,[OperatorID]
		  ,[OperatorName]
		  ,[reasonidx]
		  ,[reasons]
		  ,([Feet_Drilled_Target]) - [Feet_Drilled] AS [OffTarget]
		  ,[Feet_Drilled] AS [Actual]
		  ,[Feet_Drilled_Target] AS [Target]
		  ,[Holes_Drilled]
		  ,[Avail] AS [Availability]
		  ,[UofA] AS [Utilization]
		  ,[Average_Pen_Rate] AS [PenetrationRate]
		  ,[Total_Depth] AS [TotalDrillDepth]
		  ,[Over_Drill] AS [OverDrilled]
		  ,[Under_Drill] AS [UnderDrilled]
		  ,[Average_GPS_Quality] AS [GpsQuality]
		  ,[Average_HoleTime] AS [AvgTimeToDrill]
		  ,[Average_First_Last_Drill] AS [AvgFirstLastDrill]
		  ,[Average_First_Drill]
		  ,[Average_Last_Drill]
		  ,[Avg_Time_Between_Holes] AS [TimeBetweenHoles]
		  ,[eqmtcurrstatus]
	  FROM [abr].[CONOPS_ABR_DRILL_DETAIL_V]
	  WHERE (([Feet_Drilled_Target]) - [Feet_Drilled]) > 0



