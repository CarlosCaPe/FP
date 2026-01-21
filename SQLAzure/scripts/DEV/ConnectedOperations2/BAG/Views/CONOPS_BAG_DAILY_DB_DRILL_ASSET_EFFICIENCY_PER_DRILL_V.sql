CREATE VIEW [BAG].[CONOPS_BAG_DAILY_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] AS


  
  
--select * from [bag].[CONOPS_BAG_DAILY_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V]  
CREATE VIEW [BAG].[CONOPS_BAG_DAILY_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V]  
AS  
  
WITH TimesDetails AS (  
 SELECT SHIFTINDEX,  
     SITE_CODE,  
     'AC' + RIGHT(CONCAT('00', SUBSTRING(EQMT, CHARINDEX('C', EQMT)+1, len(EQMT))) , 2) as Equipment,  
     COALESCE(SUM(TotalTime), 0) as TotalTime,  
     COALESCE(SUM(ReadyTime), 0) as ReadyTime,  
     COALESCE(SUM(OperationalDownTime), 0) as OperationalDownTime,  
     COALESCE(SUM(ScheduledDownTime), 0) as ScheduledDownTime,  
     COALESCE(SUM(UnscheduledDownTime), 0) as UnscheduledDownTime,  
     COALESCE(SUM(DelayTime), 0) as DelayTime,  
     COALESCE(SUM(SpareTime), 0) as SpareTime,  
     COALESCE(SUM(ShiftChangeTime), 0) as ShiftChangeTime  
 FROM(  
		SELECT SHIFTINDEX,
			   SITE_CODE,
			   SHIFTDATE,
			   EQMT,
			   HOS,
			   UNIT,
			   HOS.Duration AS TotalTime,
			   CASE WHEN HOS.category IN (1, 2) THEN HOS.duration ELSE 0 END AS ReadyTime,
			   CASE WHEN HOS.category = 3 THEN HOS.duration ELSE 0 END AS OperationalDownTime,
			   CASE WHEN HOS.category = 4 THEN HOS.duration ELSE 0 END AS ScheduledDownTime,
			   CASE WHEN HOS.category IN (5, 8) THEN HOS.duration ELSE 0 END AS UnscheduledDownTime,
			   CASE WHEN HOS.category = 6 THEN HOS.duration ELSE 0 END AS DelayTime,
			   CASE WHEN HOS.category = 7 THEN HOS.duration ELSE 0 END AS SpareTime,
			   CASE WHEN  HOS.category = 9 THEN HOS.duration ELSE 0 END AS ShiftChangeTime
		FROM [bag].[FLEET_EQUIPMENT_HOURLY_STATUS] [HOS] WITH (NOLOCK)
		WHERE UNIT = 12 
 ) [AE]  
 GROUP BY SHIFTINDEX, SITE_CODE, EQMT  
)  
  
SELECT [shift].shiftflag,  
    [shift].[siteflag],  
    [shift].ShiftIndex,  
    [shift].shiftid,  
    [shift].ShiftStartDateTime,  
    Equipment,  
    AE,  
    Avail,  
    CASE WHEN [Avail] = 0  
   THEN 0  
   ELSE ROUND(([AE]/[Avail]) * 100, 2)  
    END AS [UofA],  
    [t].DRILLASSETEFFICIENCY [AETarget],  
    [t].DRILLAVAILABILITY [AvailTarget],  
    [t].DRILLUTILIZATION [UofATarget]  
FROM [bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
LEFT JOIN (  
 SELECT  TimesDetails.shiftindex ,  
   SITE_CODE [siteflag],  
   TimesDetails.Equipment ,  
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
on [drillAE].SHIFTINDEX = [shift].ShiftIndex AND [drillAE].[siteflag] = [shift].[siteflag]  
LEFT JOIN [bag].[CONOPS_BAG_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]  WITH (NOLOCK)  
ON LEFT([shift].shiftid, 4) = [t].ShiftId  
  
  

