CREATE VIEW [SAF].[CONOPS_SAF_AVG_SHIFT_CHANGE_DELAY_V] AS





--select * from [saf].[CONOPS_SAF_AVG_SHIFT_CHANGE_DELAY_V] WITH (NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_AVG_SHIFT_CHANGE_DELAY_V]
AS

SELECT [shift].shiftflag,
	   [shift].siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	select site_code,
		   shiftindex,
		   CAST(coalesce(avg(duration)/60, 0) AS DECIMAL(2,0)) as avgduration
	from dbo.status_event (nolock)
	where site_code = 'SAF'
			and status = 4
			and reason = 439
			and unit = 1
	group by site_code, shiftindex
) [AvgShiftDelay]
on [AvgShiftDelay].SHIFTINDEX = [shift].ShiftIndex
   AND [AvgShiftDelay].site_code = [shift].siteflag
WHERE [shift].siteflag = 'SAF'

