CREATE VIEW [cer].[CONOPS_CER_DRILL_DETAIL_V] AS
    
      
-- SELECT * FROM [cer].[CONOPS_CER_DRILL_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY [DRILL_ID]      
CREATE VIEW [cer].[CONOPS_CER_DRILL_DETAIL_V]      
AS      
      
WITH EqmtStatus AS (      
 SELECT ShiftId,      
     eqmt,      
     startdatetime,      
     enddatetime,      
     [status] AS eqmtcurrstatus,      
     reasonidx,      
     reasons,      
     [Duration],      
     ROW_NUMBER() OVER (PARTITION BY ShiftId, eqmt      
         ORDER BY startdatetime DESC) num      
 FROM [cer].[asset_efficiency_v] ae WITH (NOLOCK)      
 WHERE UnitType = 'Drill'      
),      
      
EqmtModel AS (      
 SELECT Shiftindex,      
     EQMTID,      
     EQMTTYPE MODEL      
 FROM dbo.LH_EQUIP_LIST WITH (NOLOCK)      
 WHERE SITE_CODE = 'CER'      
    AND unit_code IN (14,43)      
),      
      
OperatorDetail AS (      
 SELECT [ds].SHIFTINDEX,      
        [ds].[SITE_CODE],      
     REPLACE(DRILL_ID, ' ','') AS DRILL_ID,      
     [ds].PATTERN_NO,      
     OPERATOR_ID AS OPERATORID,      
     PERSONNEL_ID,      
     [w].CREW,      
     [w].FIRST_LAST_NAME AS OperatorName,      
     ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, Drill_ID      
            ORDER BY END_HOLE_TS DESC) num      
 FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)      
 LEFT JOIN [dbo].[operator_personnel_map] [w] WITH (NOLOCK)      
 ON [w].FULL_NAME = [ds].OPERATORNAME AND [w].SHIFTINDEX = [ds].SHIFTINDEX      
    AND [ds].SITE_CODE = [w].SITE_CODE      
 WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'CER'      
)      
      
SELECT ae.[shiftflag] ,      
       ae.[siteflag] ,      
    ae.[ShiftIndex],      
 ae.[ShiftId],  
    [ae].Equipment AS [DRILL_ID],      
    RIGHT('0000000000' + [o].OPERATORID, 10) AS OPERATORID,      
    CASE WHEN [PERSONNEL_ID] IS NULL OR [PERSONNEL_ID] = -1 THEN NULL      
   ELSE concat([img].[value],      
       RIGHT('0000000000' + [o].PERSONNEL_ID, 10),'.jpg') END as OperatorImageURL,      
    [o].OperatorName,      
    [o].CREW,      
    [o].PATTERN_NO,      
    [em].MODEL,      
    [es].eqmtcurrstatus,      
    [es].reasonidx,      
    [es].reasons,      
    [es].[Duration],      
    [Holes_Drilled] ,      
       50 AS [Hole_Drilled_Target] ,      
       [Feet_Drilled] ,      
       500 AS [Feet_Drilled_Target] ,      
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
FROM [cer].[CONOPS_CER_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] [ae] WITH (NOLOCK)      
LEFT JOIN [cer].[CONOPS_CER_DB_DRILL_SCORE_V] [ds] WITH (NOLOCK)      
ON [ae].shiftflag = [ds].shiftflag AND [ae].siteflag = [ds].siteflag      
AND [ds].DRILL_ID = [ae].Equipment      
LEFT JOIN [cer].[CONOPS_CER_DB_DRILL_SCORE_TARGET_V] [t] WITH (NOLOCK)      
ON LEFT([ae].shiftid, 4) = [t].ShiftId AND [ae].siteflag = [t].siteflag      
LEFT JOIN EqmtStatus [es]      
ON [es].eqmt = [ae].Equipment and [es].num = 1      
   AND [es].ShiftId = [ae].shiftid      
LEFT JOIN EqmtModel em      
ON em.Shiftindex = ae.ShiftIndex AND em.EQMTID = ae.Equipment      
LEFT JOIN OperatorDetail [o]      
ON [o].DRILL_ID = [ae].Equipment and [o].num = 1      
   AND 