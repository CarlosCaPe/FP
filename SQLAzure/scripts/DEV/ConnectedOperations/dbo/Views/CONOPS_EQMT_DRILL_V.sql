CREATE VIEW [dbo].[CONOPS_EQMT_DRILL_V] AS




-- SELECT * FROM [dbo].[CONOPS_EQMT_DRILL_V] WITH (NOLOCK)
CREATE VIEW [dbo].[CONOPS_EQMT_DRILL_V]
AS

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,NULL AS [Location]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[Holes_Drilled]
		  ,[Hole_Drilled_Target]
		  ,NULL AS [PerformanceMatrixActual]
		  ,NULL AS [PerformanceMatrixTarget]
		  ,[Average_Pen_Rate]
		  ,NULL AS [PenetrationRateTarget]
		  ,[Total_Depth]
		  ,NULL AS [DrillDepthTarget]
          ,[Average_GPS_Quality]
		  ,NULL AS [GPSQualityTarget]
		  ,[UofA]
		  ,[DRILLUTILIZATION]
		  ,[Feet_Drilled]
		  ,[Feet_Drilled_Target]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Duration]
		  ,[MODEL]
	FROM [mor].[CONOPS_MOR_DRILL_DETAIL_V]
	WHERE siteflag = 'MOR'

	UNION ALL

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,NULL AS [Location]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[Holes_Drilled]
		  ,[Hole_Drilled_Target]
		  ,NULL AS [PerformanceMatrixActual]
		  ,NULL AS [PerformanceMatrixTarget]
		  ,[Average_Pen_Rate]
		  ,NULL AS [PenetrationRateTarget]
		  ,[Total_Depth]
		  ,NULL AS [DrillDepthTarget]
          ,[Average_GPS_Quality]
		  ,NULL AS [GPSQualityTarget]
		  ,[UofA]
		  ,[DRILLUTILIZATION]
		  ,[Feet_Drilled]
		  ,[Feet_Drilled_Target]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Duration]
		  ,[MODEL]
	FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'BAG'

	UNION ALL

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,NULL AS [Location]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[Holes_Drilled]
		  ,[Hole_Drilled_Target]
		  ,NULL AS [PerformanceMatrixActual]
		  ,NULL AS [PerformanceMatrixTarget]
		  ,[Average_Pen_Rate]
		  ,NULL AS [PenetrationRateTarget]
		  ,[Total_Depth]
		  ,NULL AS [DrillDepthTarget]
          ,[Average_GPS_Quality]
		  ,NULL AS [GPSQualityTarget]
		  ,[UofA]
		  ,[DRILLUTILIZATION]
		  ,[Feet_Drilled]
		  ,[Feet_Drilled_Target]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Duration]
		  ,[MODEL]
	FROM [saf].[CONOPS_SAF_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'SAF'

	UNION ALL

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,NULL AS [Location]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[Holes_Drilled]
		  ,[Hole_Drilled_Target]
		  ,NULL AS [PerformanceMatrixActual]
		  ,NULL AS [PerformanceMatrixTarget]
		  ,[Average_Pen_Rate]
		  ,NULL AS [PenetrationRateTarget]
		  ,[Total_Depth]
		  ,NULL AS [DrillDepthTarget]
          ,[Average_GPS_Quality]
		  ,NULL AS [GPSQualityTarget]
		  ,[UofA]
		  ,[DRILLUTILIZATION]
		  ,[Feet_Drilled]
		  ,[Feet_Drilled_Target]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Duration]
		  ,[MODEL]
	FROM [sie].[CONOPS_SIE_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'SIE'

	UNION ALL

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,NULL AS [Location]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[Holes_Drilled]
		  ,[Hole_Drilled_Target]
		  ,NULL AS [PerformanceMatrixActual]
		  ,NULL AS [PerformanceMatrixTarget]
		  ,[Average_Pen_Rate]
		  ,NULL AS [PenetrationRateTarget]
		  ,[Total_Depth]
		  ,NULL AS [DrillDepthTarget]
          ,[Average_GPS_Quality]
		  ,NULL AS [GPSQualityTarget]
		  ,[UofA]
		  ,[DRILLUTILIZATION]
		  ,[Feet_Drilled]
		  ,[Feet_Drilled_Target]
		  ,[reasonidx]
		  ,[reasons]
		  ,[Duration]
		  ,[MODEL]
	FROM [chi].[CONOPS_CHI_DRILL_DETAIL_V] [d]
	WHERE [d].siteflag = 'CHI'

	UNION ALL

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[ShiftIndex]
		  ,[DRILL_ID]
		  ,NULL AS [Location]
		  ,[OperatorName]
		  ,[OperatorImageURL]
		  ,[eqmtcurrstatus]
		  ,[Holes_Drilled]
		  ,[Hole_Drilled_Target]
		  ,NULL AS [PerformanceMatrixActual]
		  ,NULL AS [Perfor