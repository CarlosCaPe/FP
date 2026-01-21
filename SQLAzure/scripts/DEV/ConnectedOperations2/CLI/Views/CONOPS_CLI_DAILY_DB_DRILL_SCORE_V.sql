CREATE VIEW [CLI].[CONOPS_CLI_DAILY_DB_DRILL_SCORE_V] AS
  
  
  
  
--select * from [cli].[CONOPS_CLI_DAILY_DB_DRILL_SCORE_V] WITH (NOLOCK) where shiftflag = 'prev'  
CREATE VIEW [cli].[CONOPS_CLI_DAILY_DB_DRILL_SCORE_V]  
AS  
  
 WITH DrillKPI AS (  
  SELECT [ds].[SHIFTINDEX],  
      LEFT(DRILL_ID, 2) + RIGHT('00' + RIGHT(DRILL_ID, 1), 2) AS DRILL_ID,  
      CASE WHEN COUNT(DRILL_HOLE) = 0 THEN 0  
        ELSE (SUM([HORIZ_DIFF_FLAG]) / COUNT(DRILL_HOLE)) * 100  
      END  AS [XY_Drill_Score],  
      CASE WHEN COUNT(DRILL_HOLE) = 0 THEN 0  
     ELSE (SUM([DEPTH_DIFF_FLAG]) / COUNT(DRILL_HOLE)) * 100  
      END  AS [Depth_Drill_Score],  
      CASE WHEN COUNT(DRILL_HOLE) = 0 THEN 0  
        ELSE (SUM([OVER_DRILLED]) / COUNT(DRILL_HOLE)) * 100  
      END  AS [Over_Drill],  
      CASE WHEN COUNT(DRILL_HOLE) = 0 THEN 0  
        ELSE (SUM([UNDER_DRILLED]) / COUNT(DRILL_HOLE)) * 100  
      END  AS [Under_Drill],  
      AVG([PENRATE]) AS [Average_Pen_Rate],  
      AVG([GPS_QUALITY]) * 100 AS [Average_GPS_Quality],  
      COUNT(DRILL_HOLE) AS [Holes_Drilled],  
      SUM(start_point_z) - SUM(zactualend) AS [Feet_Drilled],  
      AVG(HOLETIME) AS [Average_HoleTime],  
      SUM([DEPTH]) AS [Total_Depth],  
      AVG(OVERALLSCORE) AS OVERALLSCORE  
  FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)  
  WHERE [ds].[SITE_CODE] = 'CLI'  
     AND DRILL_ID IS NOT NULL  
  GROUP BY [ds].[SHIFTINDEX], [ds].[SITE_CODE], DRILL_ID  
 ),  
  
 DrillTime AS (  
  SELECT [SHIFTINDEX],  
      LEFT(DRILL_ID, 2) + RIGHT('00' + RIGHT(DRILL_ID, 1), 2) DRILL_ID,  
      [START_HOLE_TS] AS StartDateTime,  
      [END_HOLE_TS] AS EndDateTime,  
      LEAD([START_HOLE_TS]) OVER ( PARTITION BY [SHIFTINDEX], [SITE_CODE], [DRILL_ID] ORDER BY [START_HOLE_TS] ASC ) AS [NextStartDateTime] ,  
      ROW_NUMBER() OVER ( PARTITION BY [SHIFTINDEX], [SITE_CODE], [DRILL_ID] ORDER BY [START_HOLE_TS] ASC ) AS [FirstHoleIndex],  
      ROW_NUMBER() OVER ( PARTITION BY [SHIFTINDEX], [SITE_CODE], [DRILL_ID] ORDER BY [START_HOLE_TS] DESC ) AS [LastHoleIndex]  
  FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)  
  WHERE [SITE_CODE] = 'CLI'  
     AND DRILL_ID IS NOT NULL  
 ),  
  
 FirstDrillHole AS (  
  SELECT SHIFTINDEX,  
      DRILL_ID,  
      ISNULL(CAST(AVG(CAST(dt.StartDateTime AS FLOAT)) AS DATETIME), NULL) AS [AverageFirstHoleStartDateTime]  
  FROM DrillTime dt  
  WHERE dt.[FirstHoleIndex] = 1  
  GROUP BY SHIFTINDEX, DRILL_ID  
 ),  
  
 LastDrillHole AS (  
  SELECT SHIFTINDEX,  
      DRILL_ID,  
      ISNULL(CAST(AVG(CAST(dt.StartDateTime AS FLOAT)) AS DATETIME), NULL) AS [AverageLastHoleStartDateTime]  
  FROM DrillTime dt  
  WHERE dt.[LastHoleIndex] = 1  
  GROUP BY SHIFTINDEX, DRILL_ID  
 ),  
  
 DrillTimeBetweenHoles AS (   
  SELECT SHIFTINDEX,  
      DRILL_ID,  
      AVG(DATEDIFF_BIG(SECOND, dt.EndDateTime, dt.NextStartDateTime)) / 60.00 AS [AverageTime]  
     FROM DrillTime dt  
     WHERE dt.NextStartDateTime IS NOT NULL  
  GROUP BY SHIFTINDEX, DRILL_ID  
 )  
  
 SELECT a.shiftflag,  
     a.siteflag,  
     a.shiftid,  
     [DRILL_ID],  
     ISNULL([XY_Drill_Score], 0) AS [XY_Drill_Score],  
     ISNULL([Depth_Drill_Score], 0) AS [Depth_Drill_Score],  
     ISNULL([Over_Drill], 0) AS [Over_Drill],  
     ISNULL([Under_Drill], 0) AS [Under_Drill],  
     ISNULL([Avg_Time_Between_Holes], 0) AS [Avg_Time_Between_Holes],  
     ISNULL([Average_Pen_Rate], 0) AS [Average_Pen_Rate],  
     ISNULL([Average_GPS_Quality], 0) AS [Average_GPS_Quality],  
     DATEDIFF(SECOND, a.ShiftStartDateTime, [Average_First_Last_Drill]) / 60.00 AS [Average_First_Last_Drill],  
     CASE WHEN [Average_First_Drill] = '1900-01-01 00:00:00.000'  
    THEN NULL  
    ELSE [Average_First_Drill]  
     END AS [Average_First_Drill],  
     CASE WHEN [Average_Last_Drill] = '1900-01-01 00:00:00.000'  
    THEN NULL  
    ELSE [Average_Last_Drill]  
     END AS [Average_Last_Drill],  
     ISNULL([Holes_Drilled], 0) 