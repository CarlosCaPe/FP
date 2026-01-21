CREATE VIEW [sie].[CONOPS_SIE_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] AS




--select * from [sie].[CONOPS_SIE_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
CREATE VIEW [SIE].[CONOPS_SIE_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] 
AS

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   [shift].[shiftid],
	   eqmt,
	   availability_pct,
	   use_of_availability_pct,
	   Ops_efficient_pct
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	select shiftid,eqmt
	, CASE WHEN TotalTime = 0 THEN 0 ELSE((TotalTime - ScheduledDownTime - UnscheduledDownTime) / TotalTime) * 100 END as availability_pct
	, CASE WHEN TotalTime = 0 OR ReadyTime = 0 THEN 0 ELSE(ReadyTime  / (TotalTime - ScheduledDownTime - UnscheduledDownTime)) * 100 END as use_of_availability_pct
	, CASE WHEN TotalTime = 0 OR ReadyTime = 0 THEN 0 ELSE(ReadyTime / TotalTime) * 100 END as Ops_efficient_pct
	from
	(
		select shiftid,unittype, eqmt,
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
		from [sie].[asset_efficiency] WITH (NOLOCK)
		group by shiftid,eqmt,unittype
	) calc
	where unittype = 'truck'
) [ta]
ON [ta].shiftid = [shift].shiftid
   



