CREATE VIEW [MOR].[CONOPS_MOR_DAILY_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] AS

 
--select * from [mor].[CONOPS_MOR_DAILY_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V]  
CREATE VIEW [mor].[CONOPS_MOR_DAILY_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V]  
AS  
  
WITH TimesDetails AS (
	SELECT
		SHIFTINDEX,
		EQMT as Equipment,
		COALESCE(SUM(TotalTime), 0) as TotalTime,
		COALESCE(SUM(ReadyTime), 0) as ReadyTime,
		COALESCE(SUM(OperationalDownTime), 0) as OperationalDownTime,
		COALESCE(SUM(ScheduledDownTime), 0) as ScheduledDownTime,
		COALESCE(SUM(UnscheduledDownTime), 0) as UnscheduledDownTime,
		COALESCE(SUM(DelayTime), 0) as DelayTime,
		COALESCE(SUM(SpareTime), 0) as SpareTime,
		COALESCE(SUM(ShiftChangeTime), 0) as ShiftChangeTime
	FROM (
		SELECT [HOS].SHIFTINDEX,
			   REPLACE([HOS].EQMT, ' ','') AS EQMT,
			   HOS,
			   [DURATION] AS TotalTime,
			   CASE WHEN [hos].category IN (1, 2) THEN [DURATION] ELSE 0 END AS ReadyTime,
			   CASE WHEN [hos].category = 3 THEN [DURATION] ELSE 0 END AS OperationalDownTime,
			   CASE WHEN [hos].category = 4 THEN [DURATION] ELSE 0 END AS ScheduledDownTime,
			   CASE WHEN [hos].category IN (5, 8) THEN [DURATION] ELSE 0 END AS UnscheduledDownTime,
			   CASE WHEN [hos].category = 6 THEN [DURATION] ELSE 0 END AS DelayTime,
			   CASE WHEN [hos].category = 7 THEN [DURATION] ELSE 0 END AS SpareTime,
			   CASE WHEN [hos].category = 9 THEN [DURATION] ELSE 0 END AS ShiftChangeTime
		FROM [mor].[equipment_hourly_status] [HOS] WITH (NOLOCK)
		WHERE unit = '12'
	) [AE]
	--WHERE EQMT NOT IN ('19R','30R', '31R')
	GROUP BY SHIFTINDEX, EQMT
)

SELECT 
	[shift].shiftflag,  
	[shift].[siteflag],  
	[shift].ShiftIndex,  
	[shift].shiftid,  
	[shift].ShiftStartDateTime,  
	Equipment,  
	AE,  
	Avail,  
	CASE WHEN [Avail] = 0 THEN 0  
		 ELSE ROUND(([AE]/[Avail]) * 100, 0)  
	END AS [UofA],  
	CAST(DrillEfficiencyTarget AS DECIMAL(5,2)) AS [AETarget],
	CAST(DrillAvailabilityTarget AS DECIMAL(5,2)) AS [AvailTarget],
	CAST(DrillUtilizationTarget AS DECIMAL(5,2)) AS [UofATarget] 
FROM [mor].[CONOPS_MOR_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
LEFT JOIN (  
	SELECT  
		TimesDetails.shiftindex,  
		TimesDetails.Equipment,  
		CASE WHEN TimesDetails.TotalTime = 0 THEN 0   
			 ELSE CAST((TimesDetails.ReadyTime + TimesDetails.DelayTime + TimesDetails.SpareTime + TimesDetails.ShiftChangeTime) AS FLOAT)  
				  / CAST(TimesDetails.TotalTime AS FLOAT) * 100  
		END AS Avail,  
		CASE WHEN TimesDetails.TotalTime = 0 THEN 0  
			 ELSE CAST(TimesDetails.ReadyTime AS FLOAT) / CAST(TimesDetails.TotalTime AS FLOAT) * 100  
		END AS AE,  
		CASE WHEN TimesDetails.ReadyTime + TimesDetails.DelayTime + TimesDetails.SpareTime + TimesDetails.ShiftChangeTime = 0 THEN 0  
			 ELSE CAST(TimesDetails.ReadyTime AS FLOAT) / CAST(TimesDetails.ReadyTime + TimesDetails.DelayTime + TimesDetails.SpareTime + TimesDetails.ShiftChangeTime AS FLOAT) * 100  
		END AS UofA  
	FROM TimesDetails  
) [drillAE]  
ON [drillAE].SHIFTINDEX = [shift].ShiftIndex
CROSS JOIN mor.CONOPS_MOR_EQMT_ASSET_EFFICIENCY_TARGET_V aet 
  


