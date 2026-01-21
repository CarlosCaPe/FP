CREATE VIEW [dbo].[CONOPS_TRUCK_DETAIL_V] AS


CREATE VIEW [dbo].[CONOPS_TRUCK_DETAIL_V]
AS

SELECT [t].shiftflag,
       [t].siteflag,
	   [t].SHIFTINDEX,
	   [t].[TruckID],
	   [t].[StatusCode],
	   [t].[StatusName],
	   [t].[ReasonId],
	   [t].[ReasonDesc],
	   [t].[StatusStart],
	   [t].[Location],
	   [t].Region,
	   [t].[Operator],
	   [t].OperatorImageURL,
	   [t].[AssignedShovel]
FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
WHERE [t].siteflag = 'MOR'

UNION ALL

SELECT [t].shiftflag,
       [t].siteflag,
	   [t].SHIFTINDEX,
	   [t].[TruckID],
	   [t].[StatusCode],
	   [t].[StatusName],
	   [t].[ReasonId],
	   [t].[ReasonDesc],
	   [t].[StatusStart],
	   [t].[Location],
	   [t].Region,
	   [t].[Operator],
	   [t].OperatorImageURL,
	   [t].[AssignedShovel]
FROM [bag].[CONOPS_BAG_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
WHERE [t].siteflag = 'BAG'



