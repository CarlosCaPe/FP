CREATE VIEW [CER].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V] AS



--select * from [cer].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V]
AS

WITH TimesDetails AS (
	SELECT SHIFTINDEX,
		   SHIFTDATE,
		   SHIFT_CODE as ShiftNr,
		   SHIFT,
		   EQMT as Equipment,
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
		SELECT SHIFTINDEX,
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
			   CASE WHEN  HOS.category = 9 THEN HOS.duration ELSE 0 END AS ShiftChangeTime
		FROM [cer].[EQUIPMENT_HOURLY_STATUS] [HOS] WITH (NOLOCK)
		WHERE UNIT IN (1,2,14,43)
	) [AE]
	GROUP BY SHIFTINDEX, SHIFTDATE, SHIFT_CODE, SHIFT, EQMT, HOS, UNIT
)

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   [shift].shiftid,
	   EqmtUnit,
	   Equipment,
	   Hr [hos],
	   DATEADD(HOUR, Hr - 1, ShiftStartDateTime) Hr,
	   AE,
	   Avail,
	   [UofA]
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT  TimesDetails.shiftindex ,
			TimesDetails.ShiftDate ,
			TimesDetails.ShiftNr ,
			TimesDetails.Shift ,
			--'CER' [siteflag],
			TimesDetails.Hr AS Hr ,
			TimesDetails.Equipment ,
			'' AS EqmtType,
			CAST(TimesDetails.EqmtUnit AS INT) AS EqmtUnit
			, CASE WHEN TotalTime = 0 THEN 0 
				ELSE((TotalTime - ScheduledDownTime - UnscheduledDownTime) / TotalTime) * 100 END as Avail
			, CASE WHEN TotalTime = 0 OR ReadyTime = 0 THEN 0 
				ELSE(ReadyTime  / (TotalTime - ScheduledDownTime - UnscheduledDownTime)) * 100 END as UofA
			, CASE WHEN TotalTime = 0 OR ReadyTime = 0 THEN 0 
				ELSE(ReadyTime / TotalTime) * 100 END as AE
	FROM    TimesDetails
) [truckAE]
on [truckAE].SHIFTINDEX = [shift].ShiftIndex 


