CREATE VIEW [MOR].[CONOPS_MOR_EQMT_STATUS_DURATION_V] AS



-- SELECT * FROM [MOR].[CONOPS_MOR_EQMT_STATUS_DURATION_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [MOR].[CONOPS_MOR_EQMT_STATUS_DURATION_V] 
AS

WITH LatestStatus AS(
SELECT
	EQMT,
	SHIFTID,
	STATUS AS EqmtCurrStatus
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY SHIFTID, EQMT ORDER BY STARTDATETIME DESC) AS rn
    FROM MOR.asset_efficiency WITH(NOLOCK)
) AS ranked
WHERE rn = 1
)

SELECT 
	[shift].SITEFLAG,
	SHIFTFLAG,
	ae.shiftid,
	ae.eqmt,
	unittype,
	eqmttype,
	EqmtCurrStatus,
	Autonomous,
	SUM(CASE WHEN categoryidx IN (1, 2) THEN duration ELSE 0 END) /3600.0000 AS ReadyTime,
	SUM(CASE WHEN categoryidx = 3 THEN duration ELSE 0 END) /3600.0000 AS OperationalDownTime,
	SUM(CASE WHEN categoryidx = 4 THEN duration ELSE 0 END) /3600.0000 AS ScheduledDownTime,
	SUM(CASE WHEN categoryidx IN (5, 8) THEN duration ELSE 0 END) /3600.0000 AS UnscheduledDownTime,
	SUM(CASE WHEN categoryidx = 6 THEN duration ELSE 0 END) /3600.0000 AS DelayTime,
	SUM(CASE WHEN categoryidx = 7 THEN duration ELSE 0 END) /3600.0000 AS SpareTime,
	SUM(CASE WHEN categoryidx = 7 and reasonidx = 300 THEN duration ELSE 0 END) /3600.0000 AS NoOperatorTime,-- Spare code 300 
	SUM(CASE WHEN categoryidx = 9 THEN duration ELSE 0 END) /3600.0000 AS ShiftChangeTime,
	SUM(CASE WHEN reasonidx = 439 THEN duration ELSE 0 END) /3600.0000 AS ShiftChangeDelayTime,-- Delay code  439
	SUM(CASE WHEN categoryidx = 6 and reasonidx = 414 THEN duration Else 0 END) /3600.0000 AS Fueling, -- Delay code 414
	SUM(CASE WHEN categoryidx = 6 and reasonidx = 414 THEN 1 else 0 End) AS FuelEvents,
	SUM(duration)/3600.0000 as TotalTime
FROM [MOR].[asset_efficiency] [ae] (NOLOCK)
RIGHT JOIN [MOR].[CONOPS_MOR_SHIFT_INFO_V] [shift] WITH (NOLOCK)
	ON [ae].SHIFTID = [shift].SHIFTID
LEFT JOIN [MOR].[CONOPS_MOR_AUTONOMOUS_TRUCK_V] aut
	ON ae.eqmt = aut.truckid
LEFT JOIN LatestStatus ls
	ON ls.eqmt = ae.eqmt
	AND ls.shiftid = ae.shiftid
GROUP BY 
	[shift].SITEFLAG,
	SHIFTFLAG,
	ae.shiftid,
	ae.eqmt,
	unittype,
	eqmttype,
	EqmtCurrStatus,
	Autonomous

