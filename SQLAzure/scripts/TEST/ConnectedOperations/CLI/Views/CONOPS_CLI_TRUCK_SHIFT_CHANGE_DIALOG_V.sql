CREATE VIEW [CLI].[CONOPS_CLI_TRUCK_SHIFT_CHANGE_DIALOG_V] AS


-- SELECT * FROM [cli].[CONOPS_CLI_TRUCK_SHIFT_CHANGE_DIALOG_V]
CREATE VIEW [cli].[CONOPS_CLI_TRUCK_SHIFT_CHANGE_DIALOG_V] 
AS

SELECT [shiftflag],
	   [siteflag],
	   [ChangeDuration].TruckID,
	   [ChangeDuration].Operator,
	   [ChangeDuration].OperatorImageURL,
	   LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	   [ChangeDuration].[DurationMinute],
	   [ChangeDuration].Region
FROM (
	SELECT [TruckDetail].shiftflag,
		   [TruckDetail].siteflag,
		   [se].shiftindex,
		   [se].eqmt [TruckID],
		   COALESCE([w].FieldName, 'NONE') AS [Operator],
		   [TruckDetail].OperatorImageURL,
		   dateadd(second, [se].starttime + duration, CAST([se].shiftdate AS DATETIME)) [ChangeDuration],
		   [se].duration / 60 [DurationMinute],
		   [TruckDetail].Region
	FROM [dbo].[status_event] [se] WITH (NOLOCK)
	LEFT JOIN [CLI].[CONOPS_CLI_TRUCK_DETAIL_V] [TruckDetail] WITH (NOLOCK)
	ON [se].eqmt = [TruckDetail].TruckID
	   AND [se].shiftindex = [TruckDetail].SHIFTINDEX
	LEFT JOIN [CLI].[pit_worker] [w] WITH (NOLOCK)
	ON [w].FieldId = [se].operid
	WHERE [se].reason = 439 AND
		  [se].site_code = 'CLI' AND
		  [se].unit = 1 AND
		  [w].FieldName IS NOT NULL
) [ChangeDuration]
WHERE shiftflag IS NOT NULL 


