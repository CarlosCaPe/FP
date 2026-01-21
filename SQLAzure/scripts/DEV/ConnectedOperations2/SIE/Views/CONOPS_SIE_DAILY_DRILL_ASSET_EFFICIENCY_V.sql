CREATE VIEW [SIE].[CONOPS_SIE_DAILY_DRILL_ASSET_EFFICIENCY_V] AS




--select * from [sie].[CONOPS_SIE_DAILY_DRILL_ASSET_EFFICIENCY_V]
CREATE VIEW [SIE].[CONOPS_SIE_DAILY_DRILL_ASSET_EFFICIENCY_V] 
AS

WITH CTE AS (
select SITEFLAG, SHIFTFLAG
, CASE WHEN TotalTime = 0 THEN 0 ELSE((TotalTime - ScheduledDownTime - UnscheduledDownTime) / TotalTime) * 100 END as availability_pct
, CASE WHEN TotalTime = 0 OR ReadyTime = 0 THEN 0 ELSE(ReadyTime  / (TotalTime - ScheduledDownTime - UnscheduledDownTime)) * 100 END as use_of_availability_pct
, CASE WHEN TotalTime = 0 OR ReadyTime = 0 THEN 0 ELSE(ReadyTime / TotalTime) * 100 END as Ops_efficient_pct
from
(
	select [shift].SITEFLAG, SHIFTFLAG,
	SUM (CASE WHEN categoryidx IN (1, 2) THEN duration ELSE 0 END) /3600.0000 AS ReadyTime,
	SUM (CASE WHEN categoryidx = 3 THEN duration ELSE 0 END) /3600.0000 AS OperationalDownTime,
	SUM (CASE WHEN categoryidx = 4 THEN duration ELSE 0 END) /3600.0000 AS ScheduledDownTime,
	SUM (CASE WHEN categoryidx IN (5, 8) THEN duration ELSE 0 END) /3600.0000 AS UnscheduledDownTime,
	SUM (CASE WHEN categoryidx = 6 THEN duration ELSE 0 END) /3600.0000 AS DelayTime,
	SUM (CASE WHEN categoryidx = 7 THEN duration ELSE 0 END) /3600.0000 AS SpareTime,
	SUM (CASE WHEN categoryidx = 7 and reasonidx = 300 THEN duration ELSE 0 END) /3600.0000 AS NoOperatorTime,-- Spare code 300 
	SUM (CASE WHEN categoryidx = 9 THEN duration ELSE 0 END) /3600.0000 AS ShiftChangeTime,
	SUM (CASE WHEN reasonidx = 439 THEN duration ELSE 0 END) /3600.0000 AS ShiftChangeDelayTime,-- Delay code  439
	SUM (CASE WHEN categoryidx = 6 and reasonidx = 414 THEN duration Else 0 END) /3600.0000 AS Fueling, -- Delay code 414
	SUM (CASE WHEN categoryidx = 6 and reasonidx = 414 THEN 1 else 0 End) AS FuelEvents,
	SUM(duration)/3600.0000 as TotalTime
	from [SIE].[DRILL_ASSET_EFFICIENCY_V] [ae] (NOLOCK)
	RIGHT JOIN [SIE].[CONOPS_SIE_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)
		ON [ae].SHIFTINDEX = [shift].SHIFTINDEX
	group by [shift].SITEFLAG, SHIFTFLAG
) calc
)

SELECT shiftflag,
	   [siteflag],
	   FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency],
	   FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 2), '##0.##') [efficiency],
	   FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability],
	   FORMAT(ROUND(ISNULL(use_of_availability_pct, 0), 2), '##0.##') [use_of_availability]	   
FROM CTE



