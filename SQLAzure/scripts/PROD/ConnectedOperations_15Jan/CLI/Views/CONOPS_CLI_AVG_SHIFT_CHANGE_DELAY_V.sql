CREATE VIEW [CLI].[CONOPS_CLI_AVG_SHIFT_CHANGE_DELAY_V] AS



--select * from [cli].[CONOPS_CLI_AVG_SHIFT_CHANGE_DELAY_V] WITH (NOLOCK)
CREATE VIEW [cli].[CONOPS_CLI_AVG_SHIFT_CHANGE_DELAY_V]
AS

SELECT [shift].shiftflag,
	   [shift].siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	select site_code,
		   shiftindex,
		   CAST(coalesce(avg(duration)/60, 0) AS DECIMAL(2,0)) as avgduration
	from dbo.status_event (nolock)
	where site_code = 'CLI'
			and status = 4
			and reason = 439
			and unit = 1
	group by site_code, shiftindex
) [AvgShiftDelay]
on [AvgShiftDelay].SHIFTINDEX = [shift].ShiftIndex
   AND [shift].siteflag = 'CMX'
WHERE [shift].siteflag = 'CMX'


