CREATE VIEW [SAF].[CONOPS_SAF_OPERATOR_DRILL_LIST_V] AS






-- SELECT * FROM [saf].[CONOPS_SAF_OPERATOR_DRILL_LIST_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [saf].[CONOPS_SAF_OPERATOR_DRILL_LIST_V] 
AS

	WITH OperatorDetail AS (
		SELECT [shiftflag]
			  ,d.[siteflag]
			  ,d.[ShiftIndex]
			  ,[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL]
			  ,[DRILL_ID]
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
		FROM [saf].[CONOPS_SAF_DRILL_DETAIL_V] d WITH (NOLOCK)
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
			  ,'SAF' AS [siteflag]
			  ,(SELECT DISTINCT [ShiftIndex] FROM ActiveOperator WHERE SHIFTFLAG = 'CURR') AS [ShiftIndex]
			  ,o.[OPERATORID]
			  ,o.[OperatorName]
			  ,o.[OperatorImageURL]
			  ,'None' AS [DRILL_ID]
			  ,NULL AS [eqmtcurrstatus]
			  ,'None' AS [PATTERN_NO]
			  ,0 AS FeetDrilledActual
			  ,0 AS FeetDrilledTarget
			  ,0 AS PenetrationRateActual
			  ,0 AS PenetrationRateTarget
			  ,0 AS HolesDrilledActual
			  ,0 AS HolesDrilledTarget
			  ,0 AS TotalDrillDepthActual
			  ,0 AS TotalDrillDepthTarget
			  ,0 AS DepthDrillActual
			  ,0 AS DepthDrillTarget
			  ,0 AS AvgUseofAvailActual
			  ,0 AS AvgUseofAvailTarget
			  ,0 AS GPSQualityActual
			  ,0 AS [GPSQualityTarget]
			  ,0 AS AvgTimeBnHolesActual
			  ,0 AS AvgTimeBnHolesTarge