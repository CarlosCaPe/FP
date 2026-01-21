CREATE VIEW [TYR].[CONOPS_TYR_DAILY_DB_DRILL_PLAN_V] AS


  
--select * from [tyr].[CONOPS_TYR_DAILY_DB_DRILL_PLAN_V] where shiftflag = 'prev'  
CREATE VIEW [TYR].[CONOPS_TYR_DAILY_DB_DRILL_PLAN_V]  
AS  
  
 WITH DrillKPI AS (  
        SELECT [ds].[SHIFTINDEX],  
               [ds].[SITE_CODE],  
               DRILL_ID,  
               COUNT(DRILL_HOLE) AS [Holes_Drilled],  
               SUM(start_point_z) - SUM(zactualend) AS [Feet_Drilled]  
        FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)  
        WHERE [ds].[SITE_CODE] = 'TYR' AND DRILL_ID IS NOT NULL  
        GROUP BY [ds].[SHIFTINDEX], [ds].[SITE_CODE], DRILL_ID  
    ),  
  
 EqmtStatus AS (  
        SELECT SHIFTINDEX,  
               site_code,  
               Drill_ID AS eqmt,  
               [status] AS eqmtcurrstatus,  
    MODEL AS eqmttype,  
               ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID  
                                  ORDER BY startdatetime DESC) num  
        FROM [tyr].[drill_asset_efficiency_v] WITH (NOLOCK)  
    )  
  
 SELECT [shift].shiftflag,  
           [shift].siteflag,  
           [shift].[SHIFTINDEX],  
           [dk].DRILL_ID,  
           [es].eqmtcurrstatus,  
           [es].eqmttype,  
           [Holes_Drilled] AS [HolesDrilled],  
     TARGETHOLESDRILLED * (FLOOR([shift].ShiftDuration / 3600) / 12.00 ) AS [HolesDrilledTarget], 
	 TARGETHOLESDRILLED AS [HolesDrilledShiftTarget],
           [Feet_Drilled] AS [FeetDrilled],  
     TARGETFEETDRILLED * (FLOOR([shift].ShiftDuration / 3600) / 12.00 ) AS [FeetDrilledTarget], 
	 TARGETFEETDRILLED AS [FeetDrilledShiftTarget]
    FROM [tyr].[CONOPS_TYR_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
    LEFT JOIN DrillKPI [dk]  
    ON [shift].ShiftIndex = [dk].SHIFTINDEX  
    LEFT JOIN [tyr].[CONOPS_TYR_DB_DRILL_SCORE_TARGET_V] [t] WITH (NOLOCK)  
    ON LEFT([shift].shiftid, 4) = [t].ShiftId  
    LEFT JOIN EqmtStatus [es]  
    ON [es].eqmt = [dk].DRILL_ID and [es].num = 1  
       AND [es].SHIFTINDEX = [dk].ShiftIndex  
  
  
  
