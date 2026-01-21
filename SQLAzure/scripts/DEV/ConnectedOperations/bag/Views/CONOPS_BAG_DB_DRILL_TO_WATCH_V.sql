CREATE VIEW [bag].[CONOPS_BAG_DB_DRILL_TO_WATCH_V] AS







--select * from [bag].[CONOPS_BAG_DB_DRILL_TO_WATCH_V] WITH (NOLOCK) where shiftflag = 'prev'
CREATE VIEW [bag].[CONOPS_BAG_DB_DRILL_TO_WATCH_V]
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
		  ,([Feet_Drilled_Target] / 2) - [Feet_Drilled] AS [OffTarget]
		  ,[Feet_Drilled] AS [Actual]
		  ,[Feet_Drilled_Target] / 2 AS [Target]
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
	  FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V]
	  WHERE (([Feet_Drilled_Target] / 2) - [Feet_Drilled]) > 0
			AND [DRILL_ID] <> 'AC08'



