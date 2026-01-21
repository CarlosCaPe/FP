CREATE VIEW [Arch].[CONOPS_ARCH_TRUCK_SHIFT_CHANGE_DIALOG_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_TRUCK_SHIFT_CHANGE_DIALOG_V]
AS

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   [ChangeDuration].TruckID,
	   [ChangeDuration].Operator,
	   [ChangeDuration].OperatorImageURL,
	   [ChangeDuration].[ChangeDuration],
	   [ChangeDuration].[DurationMinute],
	   [ChangeDuration].Region
FROM [dbo].[SHIFT_INFO_V] [shift]
LEFT JOIN (
	SELECT [se].shiftindex,
		   [se].site_code [siteflag],
		   [se].eqmt [TruckID],
		   COALESCE([w].FieldName, 'NONE') AS [Operator],
		   [TruckDetail].OperatorImageURL,
		   dateadd(second, [se].starttime + duration, CAST([se].shiftdate AS DATETIME)) [ChangeDuration],
		   [se].duration / 60 [DurationMinute],
		   [TruckDetail].Region
	FROM [dbo].[status_event] [se] WITH (NOLOCK)
	LEFT JOIN [Arch].[CONOPS_ARCH_TRUCK_DETAIL_V] [TruckDetail] WITH (NOLOCK)
	ON [se].eqmt = [TruckDetail].TruckID
	   AND [se].shiftindex = [TruckDetail].SHIFTINDEX
	LEFT JOIN [Arch].[pit_worker] [w] WITH (NOLOCK)
	ON [w].FieldId = [se].operid
	WHERE [se].reason = 439 AND
		  [se].site_code = '<SITECODE>' AND
		  [se].unit = 1 AND
		  [w].FieldName IS NOT NULL
) [ChangeDuration]
on [ChangeDuration].SHIFTINDEX = [shift].ShiftIndex
   AND [ChangeDuration].[siteflag] = [shift].[siteflag]
WHERE [shift].[siteflag] = '<SITECODE>'

