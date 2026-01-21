CREATE VIEW [bag].[CONOPS_BAG_AVG_SHIFT_CHANGE_DELAY_V] AS


--select * from [bag].[CONOPS_BAG_AVG_SHIFT_CHANGE_DELAY_V] WITH (NOLOCK)
CREATE VIEW [BAG].[CONOPS_BAG_AVG_SHIFT_CHANGE_DELAY_V]
AS

SELECT [shift].shiftflag,
	   [shift].siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT
		e.site_code,
		e.shiftindex,
		CAST(coalesce(avg(duration)/60, 0) AS DECIMAL(2,0)) AS AvgDuration
	FROM [bag].FLEET_EQUIPMENT_HOURLY_STATUS e WITH (NOLOCK)
	WHERE e.UNIT = 1
		--AND e.Status = 5
		AND e.Reason = 439
	GROUP BY e.site_code, e.shiftindex
) [AvgShiftDelay]
on [AvgShiftDelay].SHIFTINDEX = [shift].ShiftIndex
WHERE [shift].siteflag = 'BAG'






