CREATE VIEW [dbo].[CONOPS_TRUCK_DETAIL_V] AS







-- SELECT * FROM [dbo].[CONOPS_TRUCK_DETAIL_V]
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
FROM [saf].[CONOPS_SAF_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
WHERE [t].siteflag = 'SAF'


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
FROM [sie].[CONOPS_SIE_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
WHERE [t].siteflag = 'SIE'

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
FROM [chi].[CONOPS_CHI_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
WHERE [t].siteflag = 'CHI'



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
FROM [cli].[CONOPS_CLI_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
WHERE [t].siteflag = 'CMX'



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
FROM [cer].[CONOPS_CER_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
WHERE [t].siteflag = 'CER'

