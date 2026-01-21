CREATE VIEW [dbo].[CONOPS_LH_TRUCK_SHIFT_CHANGE_DIALOG_V] AS


CREATE VIEW [dbo].[CONOPS_LH_TRUCK_SHIFT_CHANGE_DIALOG_V]
AS

SELECT shiftflag,
	   siteflag,
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	   [DurationMinute],
	   Region
FROM [mor].[CONOPS_MOR_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
WHERE siteflag = 'MOR'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	   [DurationMinute],
	   Region
FROM [bag].[CONOPS_BAG_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
WHERE siteflag = 'BAG'



