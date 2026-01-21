CREATE VIEW [dbo].[CONOPS_TP_AVG_PAYLOAD_V] AS





--select * from [dbo].[CONOPS_TP_AVG_PAYLOAD_V] WITH (NOLOCK) where shiftflag = 'prev'
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
FROM [saf].[CONOPS_SAF_TP_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
LEFT JOIN [saf].[CONOPS_SAF_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
ON [pl].TRUCK = [truck].TruckID
   AND [pl].shiftflag = [truck].shiftflag AND [pl].siteflag = [truck].siteflag 
WHERE [pl].siteflag = 'SAF'



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
FROM [sie].[CONOPS_SIE_TP_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
LEFT JOIN [sie].[CONOPS_SIE_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
ON [pl].TRUCK = [truck].TruckID
   AND [pl].shiftflag = [truck].shiftflag AND [pl].siteflag = [truck].siteflag 
WHERE [pl].siteflag = 'SIE'


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
FROM [cli].[CONOPS_CLI_TP_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
LEFT JOIN [cli].[CONOPS_CLI_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
ON [pl].TRUCK = [truck].TruckID
   AND [pl].shiftflag = [truck].shiftflag AND [pl].siteflag = [truck].siteflag 
WHERE [pl].siteflag = 'CMX'


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
FROM [cer].[CONOPS_CER_TP_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
LEFT JOIN [cer].[CONOPS_CER_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
ON [pl].TRUCK = [truck].TruckID
   AND [pl].shiftflag = [truck].shiftflag AND [pl].siteflag = [truck].siteflag 
WHERE [pl].siteflag = 'CER'

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
FROM [chi].[CONOPS_CHI_TP_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
LEFT JOIN [chi].[CONOPS_CHI_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
ON [pl].TRUCK = [truck].TruckID
   AND [pl].shiftfl