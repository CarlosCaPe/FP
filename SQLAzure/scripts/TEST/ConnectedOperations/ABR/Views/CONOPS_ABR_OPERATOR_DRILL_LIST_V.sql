CREATE VIEW [ABR].[CONOPS_ABR_OPERATOR_DRILL_LIST_V] AS


-- SELECT * FROM [abr].[CONOPS_ABR_OPERATOR_DRILL_LIST_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [ABR].[CONOPS_ABR_OPERATOR_DRILL_LIST_V] 
AS

	WITH OperatorList AS (
		SELECT [shift].[SHIFTFLAG],
			   [shift].SITEFLAG,
			   [ds].[SITE_CODE],
			   DRILL_ID,
			   OPERATORID,
			   ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, OPERATORID
								  ORDER BY END_HOLE_TS DESC) num
		FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] [shift] WITH (NOLOCK)
		LEFT JOIN [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
		ON [shift].SHIFTINDEX = [ds].SHIFTINDEX AND [shift].SITEFLAG = [ds].SITE_CODE
		WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'ELA'
		AND OPERATORID IS NOT NULL
	),

	OperatorDetail AS (
		SELECT [o].[shiftflag]
			  ,[o].[siteflag]
			  ,d.[ShiftIndex]
			  ,[o].[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL]
			  ,[o].[DRILL_ID]
			  ,[eqmtcurrstatus]
			  ,[PATTERN_NO]
			  ,ROUND([Feet_Drilled], 0) AS FeetDrilledActual
			  ,ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget
			  ,ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual
			  ,PenetrationRateTarget
			  ,ROUND([Holes_Drilled], 1) AS HolesDrilledActual
			  ,ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget
			  ,ROUND([Total_Depth], 2) AS TotalDrillDepthActual
			  ,0 AS TotalDrillDepthTarget
			  ,ROUND([Depth_Drill_Score], 2) AS DepthDrillActual
			  ,0 AS DepthDrillTarget
			  ,ROUND([UofA], 2) AS AvgUseofAvailActual
			  ,ROUND([DRILLUTILIZATION], 2) AS AvgUseofAvailTarget
			  ,ROUND([Average_GPS_Quality], 0) AS GPSQualityActual
			  ,0 AS [GPSQualityTarget]
			  ,ROUND([Avg_Time_Between_Holes], 2) AS AvgTimeBnHolesActual
			  ,0 AS AvgTimeBnHolesTarget
			  ,ROUND([Average_First_Last_Drill], 2) AS AvgFirstLastDrillActual
			  ,0 AS AvgFirstLastDrillTarget
			  ,[Average_First_Drill] AS AvgFirstDrillActual
			  ,NULL AS AvgFirstDrillTarget
			  ,[Average_Last_Drill] AS AvgLastDrillActual
			  ,NULL AS AvgLastDrillTarget
			  ,ROUND([Average_HoleTime], 2) AS AvgDrillingTimeActual
			  ,0 AS AvgDrillingTimeTarget
			  ,ROUND([XY_Drill_Score], 2) AS XyDrillScoreActual
			  ,0 AS XyDrillScoreTarget
			  ,ROUND([Over_Drill], 2) AS OverDrilledActual
			  ,0 AS OverDrilledTarget
			  ,ROUND([Under_Drill], 2) AS UnderDrilledActual
			  ,0 AS UnderDrilledTarget
			  ,[OVERALLSCORE] AS [PerformanceMatrixActual]
			  ,0 AS [PerformanceMatrixTarget]
		FROM OperatorList [o]
		LEFT JOIN [abr].[CONOPS_ABR_DRILL_DETAIL_V] d WITH (NOLOCK)
		ON [o].SHIFTFLAG = [d].shiftflag AND [o].SITEFLAG = [d].siteflag
		   AND [o].OPERATORID = [d].OPERATORID AND [o].DRILL_ID = [d].DRILL_ID
		   AND [o].num	= 1
		WHERE [OperatorName] IS NOT NULL
	),

	ActiveOperator AS (
		SELECT [shiftflag]
			  ,UPPER(SITEFLAG) AS SITEFLAG
			  ,[ShiftIndex]
			  ,[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL]
			  ,[DRILL_ID]
			  ,[eqmtcurrstatus]
			  ,[PATTERN_NO]
			  ,FeetDrilledActual
			  ,FeetDrilledTarget
			  ,PenetrationRateActual
			  ,PenetrationRateTarget
			  ,HolesDrilledActual
			  ,HolesDrilledTarget
			  ,TotalDrillDepthActual
			  ,TotalDrillDepthTarget
			  ,DepthDrillActual
			  ,DepthDrillTarget
			  ,AvgUseofAvailActual
			  ,AvgUseofAvailTarget
			  ,GPSQualityActual
			  ,[GPSQualityTarget]
			  ,AvgTimeBnHolesActual
			  ,AvgTimeBnHolesTarget
			  ,AvgFirstLastDrillActual
			  ,AvgFirstLastDrillTarget
			  ,AvgFirstDrillActual
			  ,AvgFirstDrillTarget
			  ,AvgLastDrillActual
			  ,AvgLastDrillTarget
			  ,AvgDrillingTimeActual
			  ,AvgDrillingTimeTarget
			  ,XyDrillScoreActual
			  ,XyDrillScoreTarget
			  ,OverDrilledActual
			  ,OverDrilledTarget
			  ,UnderDrilledActual
			  ,UnderDrilledTarget
			  ,[PerformanceMatrixActual]
			  ,[PerformanceMatrixTarget]
			  ,'Active' Status
		FROM OperatorDetail
	),

	InactiveOperator AS (
		SELECT 'CURR' AS [shiftflag]
			  ,'MOR' AS [siteflag]
			  ,