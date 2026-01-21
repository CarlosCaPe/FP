CREATE VIEW [BAG].[CONOPS_BAG_TRUCK_SHIFT_CHANGE_DIALOG_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_TRUCK_SHIFT_CHANGE_DIALOG_V]
CREATE VIEW [bag].[CONOPS_BAG_TRUCK_SHIFT_CHANGE_DIALOG_V] 
AS

SELECT
	[shiftflag],
	[siteflag],
	[ChangeDuration].TruckID,
	[ChangeDuration].Operator,
	[ChangeDuration].OperatorImageURL,
	LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	[ChangeDuration].[DurationMinute],
	[ChangeDuration].Region
FROM (
	SELECT
		td.shiftflag,
		td.siteflag,
		ae.ShiftId,
		ae.eqmt [TruckID],
		COALESCE(td.Operator, 'NONE') AS [Operator],
		td.OperatorImageURL,
		StartDateTime AS ChangeDuration,
		ae.duration / 60 [DurationMinute],
		td.Region
	FROM bag.asset_efficiency ae
	INNER JOIN [BAG].[CONOPS_BAG_TRUCK_DETAIL_V] td
		ON ae.shiftid = td.shiftid
		AND ae.EQMT = td.TruckId
	LEFT JOIN [bag].[CONOPS_BAG_SHIFT_INFO_V] [si]
		ON td.shiftid = si.shiftid
	WHERE REASONIDX = '439'
		AND UNITTYPE = 'Truck'
) [ChangeDuration]
WHERE [ChangeDuration].[DurationMinute] > 1



