CREATE VIEW [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] AS





--select * from [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] 
AS

SELECT 
	SHIFTFLAG,
    SITEFLAG, 
	SHIFTID,
    Unit AS EqmtUnit, 
    EQMT AS Equipment, 
    HOS + 1 AS HOS,
    DATEADD(HOUR, HOS, ShiftStartDateTime) AS Hr,
    CASE WHEN TotalTime = 0 THEN 0 
        ELSE ((TotalTime - ScheduledDownTime - UnscheduledDownTime) / TotalTime) * 100 
		END AS Avail,
    CASE WHEN TotalTime = 0 OR ReadyTime = 0 THEN 0 
        ELSE (ReadyTime / (TotalTime - ScheduledDownTime - UnscheduledDownTime)) * 100 
		END AS UofA,
    CASE WHEN TotalTime = 0 OR ReadyTime = 0 THEN 0 
        ELSE (ReadyTime / TotalTime) * 100 
		END AS AE
FROM [MOR].[CONOPS_MOR_SHIFT_INFO_V] [shift]
LEFT JOIN
(
    SELECT 
		SHIFTINDEX,
        unit, 
        EQMT, 
        HOS, 
        SUM(CASE WHEN category IN (1, 2) THEN duration ELSE 0 END) / 3600.0000 AS ReadyTime,
        SUM(CASE WHEN category = 3 THEN duration ELSE 0 END) / 3600.0000 AS OperationalDownTime,
        SUM(CASE WHEN category = 4 THEN duration ELSE 0 END) / 3600.0000 AS ScheduledDownTime,
        SUM(CASE WHEN category IN (5, 8) THEN duration ELSE 0 END) / 3600.0000 AS UnscheduledDownTime,
        SUM(CASE WHEN category = 6 THEN duration ELSE 0 END) / 3600.0000 AS DelayTime,
        SUM(CASE WHEN category = 7 THEN duration ELSE 0 END) / 3600.0000 AS SpareTime,
        SUM(CASE WHEN category = 7 AND reason = 300 THEN duration ELSE 0 END) / 3600.0000 AS NoOperatorTime, -- Spare code 300 
        SUM(CASE WHEN category = 9 THEN duration ELSE 0 END) / 3600.0000 AS ShiftChangeTime,
        SUM(CASE WHEN reason = 439 THEN duration ELSE 0 END) / 3600.0000 AS ShiftChangeDelayTime, -- Delay code 439
        SUM(CASE WHEN category = 6 AND reason = 414 THEN duration ELSE 0 END) / 3600.0000 AS Fueling, -- Delay code 414
        SUM(CASE WHEN category = 6 AND reason = 414 THEN 1 ELSE 0 END) AS FuelEvents,
        SUM(duration) / 3600.0000 AS TotalTime
    FROM [MOR].[EQUIPMENT_HOURLY_STATUS] [HOS] (NOLOCK)
	WHERE UNIT IN (1,2,12)
    GROUP BY 
        SHIFTINDEX,
        unit, 
        EQMT, 
        HOS
) calc
ON [calc].SHIFTINDEX = [shift].ShiftIndex 