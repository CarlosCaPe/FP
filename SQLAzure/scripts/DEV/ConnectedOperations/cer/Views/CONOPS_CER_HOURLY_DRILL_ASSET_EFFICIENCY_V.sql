CREATE VIEW [cer].[CONOPS_CER_HOURLY_DRILL_ASSET_EFFICIENCY_V] AS




--select * from [cer].[CONOPS_CER_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_HOURLY_DRILL_ASSET_EFFICIENCY_V]
AS

WITH TimesDetails AS (
	SELECT [AE].SHIFTINDEX,
		   SHIFTDATE,
		   SHIFT_CODE as ShiftNr,
		   SHIFT,
		   EQMT as Equipment,
		   [MODEL] AS eqmttype,
		   HOS + 1 as Hr,
		   UNIT as EqmtUnit,
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
			   SHIFTDATE,
			   SHIFT_CODE,
			   SHIFT,
			   EQMT,
			   HOS,
			   CASE WHEN [HOS].UNIT = 43
					THEN 14
					ELSE [HOS].UNIT
			   END UNIT,
			   HOS.Duration AS TotalTime,
			   CASE WHEN HOS.category IN (1, 2) THEN HOS.duration ELSE 0 END AS ReadyTime,
			   CASE WHEN HOS.category = 3 THEN HOS.duration ELSE 0 END AS OperationalDownTime,
			   CASE WHEN HOS.category = 4 THEN HOS.duration ELSE 0 END AS ScheduledDownTime,
			   CASE WHEN HOS.category IN (5, 8) THEN HOS.duration ELSE 0 END AS UnscheduledDownTime,
			   CASE WHEN HOS.category = 6 THEN HOS.duration ELSE 0 END AS DelayTime,
			   CASE WHEN HOS.category = 7 THEN HOS.duration ELSE 0 END AS SpareTime,
			   CASE WHEN HOS.category = 9 THEN HOS.duration ELSE 0 END AS ShiftChangeTime
		FROM [cer].[EQUIPMENT_HOURLY_STATUS] [HOS] WITH (NOLOCK)
		WHERE UNIT IN (14,43)
	) [AE]
	LEFT JOIN [cer].[DRILL_ASSET_EFFICIENCY_V] [DT]
		ON [AE].SHIFTINDEX = [DT].SHIFTINDEX
		AND [AE].EQMT = [DT].DRILL_ID
	GROUP BY [AE].SHIFTINDEX, SHIFTDATE, SHIFT_CODE, SHIFT, EQMT, MODEL, HOS, UNIT
),

EqmtStatus AS (
	SELECT SHIFTINDEX,
	       site_code,
	       Drill_ID AS eqmt,
	       [status] AS eqmtcurrstatus,
		   [MODEL] AS eqmttype,
	       ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID
	                          ORDER BY startdatetime DESC) num
	FROM [cer].[drill_asset_efficiency_v] WITH (NOLOCK)
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
	   CASE WHEN [Avail] = 0
				 THEN 0
				 ELSE ROUND(([AE]/[Avail]) * 100, 0)
		    END AS [UofA],
	   [t].DRILLASSETEFFICIENCY [AETarget],
	   [t].DRILLAVAILABILITY [AvailTarget],
	   [t].DRILLUTILIZATION [UofATarget]
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT  TimesDetails.shiftindex ,
			'CER' [siteflag],
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
on [drillAE].SHIFTINDEX = [shift].ShiftIndex AND [drillAE].[siteflag] = [shift].[siteflag]
LEFT JOIN [cer].[CONOPS_CER_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]
	ON LEFT([shift].shiftid, 4) = [t].ShiftId
LEFT JOIN Eqmt