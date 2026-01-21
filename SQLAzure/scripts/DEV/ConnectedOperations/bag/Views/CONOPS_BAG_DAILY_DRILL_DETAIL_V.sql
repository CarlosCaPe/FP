CREATE VIEW [bag].[CONOPS_BAG_DAILY_DRILL_DETAIL_V] AS
  
    
      
      
      
      
-- SELECT * FROM [bag].[CONOPS_BAG_DAILY_DRILL_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY [DRILL_ID]      
CREATE VIEW [bag].[CONOPS_BAG_DAILY_DRILL_DETAIL_V]      
AS      
      
WITH EqmtStatus AS (      
 SELECT SHIFTINDEX,      
     site_code,      
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
 FROM [bag].[drill_asset_efficiency_v] WITH (NOLOCK)      
),      
      
OperatorDetail AS (      
 SELECT [ds].SHIFTINDEX,      
        [ds].[SITE_CODE],      
     REPLACE(DRILL_ID, ' ','') AS DRILL_ID,      
     [ds].PATTERN_NO,      
     OPERATORID,      
     [w].CREW,      
     [w].FIRST_LAST_NAME AS OperatorName,      
     ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, Drill_ID      
            ORDER BY END_HOLE_TS DESC) num      
 FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)      
 LEFT JOIN [dbo].[operator_personnel_map] [w] WITH (NOLOCK)      
 ON CAST([w].[OPERATOR_ID] AS numeric) = CAST([ds].OPERATORID AS numeric) AND [w].SHIFTINDEX = [ds].SHIFTINDEX      
    AND [ds].SITE_CODE = [w].SITE_CODE      
 WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'BAG'      
)      
      
SELECT DISTINCT ae.[shiftflag] ,      
       ae.[siteflag] ,      
    ae.[ShiftIndex],      
 ae.[ShiftId],      
    [ae].Equipment AS [DRILL_ID],      
    [o].OPERATORID,      
    CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL      
   ELSE concat('https://images.services-dev.fmi.com/publishedimages/',      
       RIGHT('0000000000' + [o].OPERATORID, 10),'.jpg') END as OperatorImageURL,      
    [o].OperatorName,      
    [o].CREW,      
    [o].PATTERN_NO,      
    [es].MODEL,      
    [es].eqmtcurrstatus,      
    [es].reasonidx,      
    [es].reasons,      
    [es].[Duration],      
    [Holes_Drilled] ,      
       15 [Hole_Drilled_Target] ,      
       [Feet_Drilled] ,      
       550 AS [Feet_Drilled_Target] ,      
       [Avail] ,      
       [DRILLAVAILABILITY] ,      
       CASE WHEN [ae].Avail IS NULL OR [ae].Avail = 0      
   THEN 0      
   ELSE ([ae].AE / [ae].Avail) * 100      
    END AS UofA,      
       [DRILLUTILIZATION] ,      
    [ae].AE AS AssetEfficiency,    
 DRILLASSETEFFICIENCY AS AssetEfficiencyTarget,    
       [Average_Pen_Rate] ,      
    230 AS PenetrationRateTarget,      
       [Total_Depth] ,      
    [Depth_Drill_Score],      
       [Over_Drill] ,      
       [Under_Drill] ,      
    [Average_HoleTime] ,      
       [Average_GPS_Quality] ,      
       [Avg_Time_Between_Holes] ,      
       [Average_First_Last_Drill],      
    [Average_First_Drill],      
    [Average_Last_Drill],      
    [XY_Drill_Score],      
    [OVERALLSCORE]      
FROM [bag].[CONOPS_BAG_DAILY_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] [ae] WITH (NOLOCK)      
LEFT JOIN [bag].[CONOPS_BAG_DAILY_DB_DRILL_SCORE_V] [ds] WITH (NOLOCK)      
ON [ae].shiftid = [ds].shiftid AND [ae].siteflag = [ds].siteflag      
AND [ds].DRILL_ID = [ae].Equipment      
LEFT JOIN [bag].[CONOPS_BAG_DB_DRILL_SCORE_TARGET_V] [t] WITH (NOLOCK)      
ON LEFT([ae].shiftid, 4) = [t].ShiftId AND [ae].siteflag = [t].siteflag      
LEFT JOIN EqmtStatus [es]      
ON [es].eqmt = [ae].Equipment and [es].num = 1      
   AND [es].SHIFTINDEX = [ae].ShiftIndex AND [ae].siteflag = [es].site_code      
LEFT JOIN OperatorDetail [o]      
ON [o].DRILL_ID = [ae].Equipment and [o].num = 1      
   AND [o].SHIFTINDEX = [ae].ShiftIndex AND [ae].siteflag = [o].[SITE_CODE]      
      
      
      
      
    
  
