CREATE VIEW [dbo].[CONOPS_LH_TRUCK_SHIFT_CHANGE_DIALOG_V] AS



-- SELECT * FROM [dbo].[CONOPS_LH_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
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

UNION ALL

SELECT shiftflag,
	   siteflag,
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	   [DurationMinute],
	   Region
FROM [saf].[CONOPS_SAF_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
WHERE siteflag = 'SAF'


UNION ALL

SELECT shiftflag,
	   siteflag,
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	   [DurationMinute],
	   Region
FROM [sie].[CONOPS_SIE_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
WHERE siteflag = 'SIE'


UNION ALL

SELECT shiftflag,
	   siteflag,
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	   [DurationMinute],
	   Region
FROM [cli].[CONOPS_CLI_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
WHERE siteflag = 'CMX'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	   [DurationMinute],
	   Region
FROM [chi].[CONOPS_CHI_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
WHERE siteflag = 'CHI'


UNION ALL 

SELECT shiftflag,
	   siteflag,
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   LEFT(CAST([ChangeDuration] AS TIME(0)), 5) [ChangeDuration],
	   [DurationMinute],
	   Region
FROM [cer].[CONOPS_CER_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
WHERE siteflag = 'CER'

