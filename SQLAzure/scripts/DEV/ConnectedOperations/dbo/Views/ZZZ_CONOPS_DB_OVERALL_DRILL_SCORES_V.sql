CREATE VIEW [dbo].[ZZZ_CONOPS_DB_OVERALL_DRILL_SCORES_V] AS


--select * from [dbo].[CONOPS_DB_OVERALL_DRILL_SCORES_V] WITH (NOLOCK) where shiftflag = 'prev'
CREATE VIEW [dbo].[CONOPS_DB_OVERALL_DRILL_SCORES_V]
AS

	WITH DrillKPI AS (
		SELECT [ds].[SHIFTINDEX],
			   CASE [ds].[SITE_CODE]
					WHEN 'CLI' THEN 'CMX'
					ELSE [ds].[SITE_CODE]
			   END AS [SITE_CODE],
			   (SUM([HORIZ_DIFF_FLAG]) / COUNT([DRILL_ID])) * 100 AS [XY_Drill_Score],
			   (SUM([DEPTH_DIFF_FLAG]) / COUNT([DRILL_ID])) * 100 AS [Depth_Drill_Score],
			   --(((SUM([DEPTH_DIFF_FLAG]) / COUNT([DRILL_ID])) + (SUM([HORIZ_DIFF_FLAG]) / COUNT([DRILL_ID]))) / 2) * 100 AS [Overall Drill Score]
			   (SUM([OVER_DRILLED]) / COUNT([DRILL_ID])) * 100 AS [Over_Drill],
			   (SUM([UNDER_DRILLED]) / COUNT([DRILL_ID])) * 100 AS [Under_Drill],
			   AVG([PENRATE]) AS [Average_Pen_Rate],
			   AVG([GPS_QUALITY]) * 100 AS [Average_GPS_Quality]
		FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
		GROUP BY [ds].[SHIFTINDEX], [ds].[SITE_CODE]
	),

	DrillTime AS (
		SELECT [SHIFTINDEX],
			   CASE [SITE_CODE]
					WHEN 'CLI' THEN 'CMX'
					ELSE [SITE_CODE]
			   END AS [SITE_CODE],
			   [START_HOLE_TS] AS StartDateTime,
			   [END_HOLE_TS] AS EndDateTime,
			   LEAD([START_HOLE_TS]) OVER ( PARTITION BY [DRILL_ID] ORDER BY [START_HOLE_TS] ASC ) AS [NextStartDateTime] ,
			   ROW_NUMBER() OVER ( PARTITION BY [DRILL_ID] ORDER BY [START_HOLE_TS] ASC ) AS [DrillIndex]
		FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)
	),

	FirstDrillHole AS (
		SELECT SITE_CODE,
			   SHIFTINDEX,
			   CAST(AVG(CAST(dt.StartDateTime AS FLOAT)) AS DATETIME) AS [AverageStartDateTime]
		FROM DrillTime dt
		WHERE dt.DrillIndex = 1
		GROUP BY SITE_CODE, SHIFTINDEX
	),

	DrillTimeBetweenHoles AS ( 
		SELECT SITE_CODE,
			   SHIFTINDEX,
			   AVG(DATEDIFF_BIG(SECOND, dt.EndDateTime, dt.NextStartDateTime)) / 60.00 AS [AverageTime]
    	FROM DrillTime dt
    	WHERE dt.NextStartDateTime IS NOT NULL
		GROUP BY SITE_CODE, SHIFTINDEX
	)

	SELECT a.shiftflag,
		   a.siteflag,
		   ISNULL([XY_Drill_Score], 0) AS [XY_Drill_Score],
		   ISNULL([Depth_Drill_Score], 0) AS [Depth_Drill_Score],
		   ISNULL([Over_Drill], 0) AS [Over_Drill],
		   ISNULL([Under_Drill], 0) AS [Under_Drill],
		   ISNULL([Avg_Time_Between_Holes], 0) AS [Avg_Time_Between_Holes],
		   ISNULL([Average_Pen_Rate], 0) AS [Average_Pen_Rate],
		   ISNULL([Average_GPS_Quality], 0) AS [Average_GPS_Quality]
	FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)
	LEFT JOIN (
		SELECT [ds].[SHIFTINDEX],
			   [ds].[SITE_CODE],
			   [XY_Drill_Score],
			   [Depth_Drill_Score],
			   [Over_Drill],
			   [Under_Drill],
			   [dtbh].AverageTime AS [Avg_Time_Between_Holes],
			   [Average_Pen_Rate],
			   [Average_GPS_Quality]
		FROM DrillKPI [ds]
		INNER JOIN DrillTimeBetweenHoles [dtbh]
		ON [dtbh].SITE_CODE = [ds].SITE_CODE AND [dtbh].SHIFTINDEX = [ds].SHIFTINDEX
	) kpi ON a.ShiftIndex = kpi.SHIFTINDEX AND a.siteflag = kpi.SITE_CODE

