CREATE VIEW [cli].[CONOPS_CLI_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] AS


--select * from [cli].[CONOPS_CLI_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V]
CREATE VIEW [cli].[CONOPS_CLI_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V]
AS

WITH TimesDetails AS (
	SELECT SHIFTINDEX,
		   SITE_CODE,
		   EQMT as Equipment,
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
			   [HOS].SITE_CODE,
			   REPLACE([HOS].[EQUIPMENTNUMBER], ' ','') AS EQMT,
			   [STATUS_DURATION] AS TotalTime,
			   CASE WHEN [s].category IN (1, 2) THEN [STATUS_DURATION] ELSE 0 END AS ReadyTime,
			   CASE WHEN [s].category = 3 THEN [STATUS_DURATION] ELSE 0 END AS OperationalDownTime,
			   CASE WHEN [s].category = 4 THEN [STATUS_DURATION] ELSE 0 END AS ScheduledDownTime,
			   CASE WHEN [s].category IN (5, 8) THEN [STATUS_DURATION] ELSE 0 END AS UnscheduledDownTime,
			   CASE WHEN [s].category = 6 THEN [STATUS_DURATION] ELSE 0 END AS DelayTime,
			   CASE WHEN [s].category = 7 THEN [STATUS_DURATION] ELSE 0 END AS SpareTime,
			   CASE WHEN  [s].category = 9 THEN [STATUS_DURATION] ELSE 0 END AS ShiftChangeTime
		FROM [cli].[DRILL_UTILIZATION] [HOS] WITH (NOLOCK)
		LEFT JOIN [dbo].[LH_REASON] [s] WITH (NOLOCK)
		ON [s].[SHIFTINDEX] = [HOS].[SHIFTINDEX] AND [s].[SITE_CODE] = [HOS].[SITE_CODE]
			AND [s].[REASON] = [HOS].[MACHINESTATUSCODE]
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
			ELSE ROUND(([AE]/[Avail]) * 100, 0)
	   END AS [UofA],
	   0 [AETarget],
	   0 [AvailTarget],
	   0 [UofATarget]
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] [shift] WITH (NOLOCK)
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
on [drillAE].SHIFTINDEX = [shift].ShiftIndex

