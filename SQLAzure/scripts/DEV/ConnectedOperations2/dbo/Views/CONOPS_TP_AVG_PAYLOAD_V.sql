CREATE VIEW [dbo].[CONOPS_TP_AVG_PAYLOAD_V] AS


CREATE VIEW [dbo].[CONOPS_TP_AVG_PAYLOAD_V]
AS

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   TRUCK,
	   UPPER([pl].Operator) as Operator,
	   [pl].OperatorImageURL,
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   Target,
	   StatusName [Status],
	   [truck].ReasonId,
	   [truck].ReasonDesc,
	   [truck].Location
FROM [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
LEFT JOIN [mor].[CONOPS_MOR_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
ON [pl].TRUCK = [truck].TruckID
   AND [pl].shiftflag = [truck].shiftflag AND [pl].siteflag = [truck].siteflag 
WHERE [pl].siteflag = 'MOR'

UNION ALL

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   TRUCK,
	   UPPER([truck].Operator) as Operator,
	   [truck].OperatorImageURL,
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   Target,
	   StatusName [Status],
	   [truck].ReasonId,
	   [truck].ReasonDesc,
	   [truck].Location
FROM [bag].[CONOPS_BAG_TP_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
LEFT JOIN [bag].[CONOPS_BAG_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
ON [pl].TRUCK = [truck].TruckID
   AND [pl].shiftflag = [truck].shiftflag AND [pl].siteflag = [truck].siteflag 
WHERE [pl].siteflag = 'BAG'


