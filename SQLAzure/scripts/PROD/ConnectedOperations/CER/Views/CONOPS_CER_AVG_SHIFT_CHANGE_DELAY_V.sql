CREATE VIEW [CER].[CONOPS_CER_AVG_SHIFT_CHANGE_DELAY_V] AS



CREATE VIEW [cer].[CONOPS_CER_AVG_SHIFT_CHANGE_DELAY_V]
AS

SELECT [shift].shiftflag,
	   [shift].siteflag,
	   CAST((avg(duration)/60) AS DECIMAL(2,0)) AS [Actual],
	   tg.ShiftChangeTarget [Target]
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	select site_code,
		   shiftindex,
		   eqmt,
		   SUM(duration) as duration
	from dbo.status_event (nolock)
	where site_code = 'CER'
			--and status = 4
			and reason = 439
			and unit = 1
	group by site_code, shiftindex,eqmt
) [AvgShiftDelay]
on [AvgShiftDelay].SHIFTINDEX = [shift].ShiftIndex
   AND [AvgShiftDelay].site_code = [shift].siteflag
CROSS JOIN (
SELECT TOP 1
ShiftChangeTarget
FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V]
ORDER BY shiftid DESC) tg
WHERE [shift].siteflag = 'CER'
group by shiftflag,shift.siteflag,tg.ShiftChangeTarget

