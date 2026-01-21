CREATE VIEW [BAG].[CONOPS_BAG_HOURLY_DRILL_ASSET_EFFICIENCY_V] AS

--select * from [bag].[CONOPS_BAG_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [bag].[CONOPS_BAG_HOURLY_DRILL_ASSET_EFFICIENCY_V]
AS

WITH EqCategory AS(
SELECT DISTINCT
	EquipmentID AS EQMT,
	EQMTTYPE
FROM BAG.FLEET_PIT_MACHINE_C WITH(NOLOCK)
WHERE EquipmentCategory = 'Track Drill'
),

TimesDetails AS (
	SELECT SHIFTINDEX,
		   SITE_CODE,
		   'AC' + RIGHT(CONCAT('00', SUBSTRING(EQMT, CHARINDEX('C', EQMT)+1, len(EQMT))) , 2) as Equipment,
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
		SELECT SHIFTINDEX,
			   SITE_CODE,
			   SHIFTDATE,
			   hos.EQMT,
			   ct.EQMTTYPE,
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
		FROM [bag].[EQUIPMENT_HOURLY_STATUS] [HOS] WITH (NOLOCK)
		LEFT JOIN EqCategory ct 
			ON hos.EQMT = ct.EQMT
		WHERE UNIT = 12 
	) [AE]
	GROUP BY SHIFTINDEX, SITE_CODE, EQMT, eqmttype, HOS
),

EqmtStatus AS (
	SELECT SHIFTINDEX,
		site_code,
		DRILL_ID AS eqmt,
		[status] AS eqmtcurrstatus,
		[MODEL] AS eqmttype,
		ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID
			ORDER BY startdatetime DESC) num
	FROM [bag].[drill_asset_efficiency_v] WITH (NOLOCK)  
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
	   [t].DRILLASSETEFFICIENCY [AETarget],
	   [t].DRILLAVAILABILITY [AvailTarget],
	   [t].DRILLUTILIZATION [UofATarget]
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT  TimesDetails.shiftindex ,
			SITE_CODE [siteflag],
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
LEFT JOIN [bag].[CONOPS_BAG_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]  WITH (NOLOCK)
	ON LEFT([shift].shiftid, 4) = [t].ShiftId
LEFT JOIN EqmtStatus [es]
	ON [drillAe].SHIFTINDEX = [es].SHIFTINDEX
	AND [drillAe].Equipment = [es].eqmt
	AND [es].num = 1

