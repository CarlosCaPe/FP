CREATE VIEW [ABR].[CONOPS_ABR_DAILY_HOURLY_DRILL_ASSET_EFFICIENCY_V] AS



--select * from [abr].[CONOPS_ABR_DAILY_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)  
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_HOURLY_DRILL_ASSET_EFFICIENCY_V]  
AS  
  
WITH TimesDetails AS (  
 SELECT SHIFTINDEX,  
     EQMT as Equipment,  
     eqmttype,  
     HOS + 1 as Hr,  
     COALESCE(SUM(TotalTime), 0) as TotalTime,  
     COALESCE(SUM(ReadyTime), 0) as ReadyTime,  
     COALESCE(SUM(OperationalDownTime), 0) as OperationalDownTime,  
     COALESCE(SUM(ScheduledDownTime), 0) as ScheduledDownTime,  
     COALESCE(SUM(UnscheduledDownTime), 0) as UnscheduledDownTime,  
     COALESCE(SUM(DelayTime), 0) as DelayTime,  
     COALESCE(SUM(SpareTime), 0) as SpareTime,  
     COALESCE(SUM(ShiftChangeTime), 0) as ShiftChangeTime  
 FROM(  
  SELECT [HOS].SHIFTINDEX,  
      REPLACE([HOS].[EQUIPMENTNUMBER], ' ','') AS EQMT,  
      EQUIPMENTMODEL AS eqmttype,  
      HOS,  
      [STATUS_DURATION] AS TotalTime,  
      CASE WHEN [s].category IN (1, 2) THEN [STATUS_DURATION] ELSE 0 END AS ReadyTime,  
      CASE WHEN [s].category = 3 THEN [STATUS_DURATION] ELSE 0 END AS OperationalDownTime,  
      CASE WHEN [s].category = 4 THEN [STATUS_DURATION] ELSE 0 END AS ScheduledDownTime,  
      CASE WHEN [s].category IN (5, 8) THEN [STATUS_DURATION] ELSE 0 END AS UnscheduledDownTime,  
      CASE WHEN [s].category = 6 THEN [STATUS_DURATION] ELSE 0 END AS DelayTime,  
      CASE WHEN [s].category = 7 THEN [STATUS_DURATION] ELSE 0 END AS SpareTime,  
      CASE WHEN  [s].category = 9 THEN [STATUS_DURATION] ELSE 0 END AS ShiftChangeTime  
  FROM [abr].[DRILL_UTILIZATION] [HOS] WITH (NOLOCK)  
  LEFT JOIN [dbo].[LH_REASON] [s] WITH (NOLOCK)  
  ON [s].[SHIFTINDEX] = [HOS].[SHIFTINDEX] AND [s].[SITE_CODE] = [HOS].[SITE_CODE]  
   AND [s].[REASON] = [HOS].[MACHINESTATUSCODE]  
 ) [AE]  
 GROUP BY SHIFTINDEX, EQMT, eqmttype, HOS  
),  
  
EqmtStatus AS (  
 SELECT SHIFTINDEX,  
        site_code,  
        Drill_ID AS eqmt,  
        [status] AS eqmtcurrstatus,  
     [MODEL] AS eqmttype,  
        ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID  
                           ORDER BY startdatetime DESC) num  
 FROM [abr].[drill_asset_efficiency_v] WITH (NOLOCK)  
)  
  
SELECT [shift].shiftflag,  
    [shift].[siteflag],  
    [shift].ShiftIndex,  
    [shift].shiftid,  
    [shift].ShiftStartDateTime,  
    Equipment,  
    [drillAe].eqmttype,  
    [es].eqmtcurrstatus,  
    Hr [hos],  
    DATEADD(HOUR, Hr - 1, ShiftStartDateTime) Hr,  
    AE,  
    Avail,  
    [UofA],  
    0 [AETarget],  
    0 [AvailTarget],  
    0 [UofATarget]  
FROM [abr].[CONOPS_ABR_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
LEFT JOIN (  
 SELECT  TimesDetails.shiftindex ,  
   TimesDetails.Hr AS Hr ,  
   TimesDetails.Equipment ,  
   TimesDetails.eqmttype,  
   CASE WHEN TimesDetails.TotalTime = 0 THEN 0   
     ELSE CAST(( TimesDetails.ReadyTime + TimesDetails.DelayTime + TimesDetails.SpareTime + TimesDetails.ShiftChangeTime ) AS FLOAT)  
       / CAST(TimesDetails.TotalTime AS FLOAT) * 100  
   END AS Avail,  
   CASE WHEN TimesDetails.TotalTime = 0 THEN 0  
     ELSE CAST(TimesDetails.ReadyTime AS FLOAT) / CAST(TimesDetails.TotalTime AS FLOAT) * 100  
   END AS AE ,  
   CASE WHEN TimesDetails.ReadyTime + TimesDetails.DelayTime + TimesDetails.SpareTime + TimesDetails.ShiftChangeTime = 0  
     THEN 0  
     ELSE CAST(TimesDetails.ReadyTime AS FLOAT) / CAST(TimesDetails.ReadyTime + TimesDetails.DelayTime + TimesDetails.SpareTime  
       + TimesDetails.ShiftChangeTime AS FLOAT) * 100  
   END AS UofA  
 FROM    TimesDetails  
) [drillAE]  
on [drillAE].SHIFTINDEX = [shift].ShiftIndex  
LEFT JOIN EqmtStatus [es]  
 ON [drillAe].SHIFTINDEX = [es].SHIFTINDEX  
 AND [drillAe].Equipment = [es].eqmt  
 AND [es].num = 1  
  
  

