CREATE VIEW [CLI].[CONOPS_CLI_DRILL_DETAIL_PER_HOUR_V] AS
  
    
    
    
-- SELECT * FROM [cli].[CONOPS_CLI_DRILL_DETAIL_PER_HOUR_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY [DRILL_ID]    
CREATE VIEW [cli].[CONOPS_CLI_DRILL_DETAIL_PER_HOUR_V]    
AS    
    
WITH DrillScoreBASE AS (    
     SELECT [ds].shiftflag,    
              [ds].siteflag,    
              [ds].[SHIFTINDEX],    
              LEFT(DRILL_ID, 2) + RIGHT('00' + RIGHT(DRILL_ID, 1), 2) AS DRILL_ID,    
              start_point_z,    
              zactualend,    
              [PENRATE],    
              DRILL_HOLE,    
              [DEPTH],    
              [GPS_QUALITY],    
      [HORIZ_DIFF_FLAG],    
      [DEPTH_DIFF_FLAG],    
      [OVER_DRILLED],    
      [UNDER_DRILLED],    
      [START_HOLE_TS],    
      [END_HOLE_TS],    
      [HOLETIME],    
      [OVERALLSCORE],    
              IIF(HOS > 12, 12, HOS) AS HOS    
     FROM (    
         SELECT a.shiftflag,    
          a.siteflag,    
       [ds].[SHIFTINDEX],    
                  CASE [ds].[SITE_CODE]    
                     WHEN 'CLI' THEN 'CMX'    
                     ELSE [ds].[SITE_CODE]    
                  END  AS [SITE_CODE],    
                  [DRILL_ID],    
                  start_point_z,    
                  zactualend,    
                  [PENRATE],    
                  DRILL_HOLE,    
                  [DEPTH],    
                  [GPS_QUALITY],    
       [HORIZ_DIFF_FLAG],    
       [DEPTH_DIFF_FLAG],    
       [OVER_DRILLED],    
       [UNDER_DRILLED],    
       [START_HOLE_TS],    
       [END_HOLE_TS],    
       [HOLETIME],    
       [OVERALLSCORE],    
                  CEILING(DATEDIFF(MINUTE, [a].ShiftStartDateTime, [ds].END_HOLE_TS) / 60.00) as HOS    
         FROM [cli].CONOPS_CLI_SHIFT_INFO_V a (NOLOCK)    
         LEFT JOIN [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)    
         ON [a].ShiftIndex = [ds].SHIFTINDEX AND [a].siteflag = IIF([ds].SITE_CODE = 'CLI', 'CMX', [ds].SITE_CODE)    
         WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'CLI'    
     ) [ds]    
 ),    
    
 EqmtStatus AS (    
  SELECT SHIFTINDEX,    
      'CMX' site_code,    
      Drill_ID AS eqmt,    
      MODEL,    
      startdatetime,    
      enddatetime,    
      [status] AS eqmtcurrstatus,    
      reasonidx,    
      reason AS reasons,    
      [Duration],    
      ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID    
          ORDER BY startdatetime DESC) num    
  FROM [cli].[drill_asset_efficiency_v] WITH (NOLOCK)    
 ),    
    
 OperatorDetail AS (    
  SELECT [ds].SHIFTINDEX,    
      'CMX' AS [SITE_CODE],    
      LEFT(REPLACE(DRILL_ID, ' ',''), 2) + RIGHT('00' + RIGHT(REPLACE(DRILL_ID, ' ',''), 1), 2) AS DRILL_ID,    
      OPERATORID,    
      [w].FIRST_LAST_NAME AS OperatorName,    
      ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, Drill_ID    
          ORDER BY END_HOLE_TS DESC) num    
  FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)    
  LEFT JOIN [dbo].[operator_personnel_map] [w] WITH (NOLOCK)    
  ON CAST([w].[OPERATOR_ID] AS numeric) = CAST([ds].OPERATORID AS numeric) AND [w].SHIFTINDEX = [ds].SHIFTINDEX    
     AND [ds].SITE_CODE = [w].SITE_CODE    
  WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'CLI'    
 ),    
    
 DrillTime AS (    
  SELECT [SHIFTINDEX],    
      [siteflag],    
      DRILL_ID,    
      HOS,    
      [START_HOLE_TS] AS StartDateTime,    
      [END_HOLE_TS] AS EndDateTime,    
      LEAD([START_HOLE_TS]) OVER ( PARTITION BY DRILL_ID, HOS ORDER BY [START_HOLE_TS] ASC ) AS [NextStartDateTime] ,    
      ROW_NUMBER() OVER ( PARTITION BY HOS ORDER BY [START_HOLE_TS] ASC ) AS [DrillIndex]    
  FROM DrillScoreBASE WITH (NOLOCK)    
 ),    
    
 FirstDrillHole AS (    
  SELECT [siteflag],    
      SHIFTINDEX,    
      DRILL_ID,    
      HOS,    
      CAST(AVG(CAST(dt.StartDateTime AS FLOAT)) A