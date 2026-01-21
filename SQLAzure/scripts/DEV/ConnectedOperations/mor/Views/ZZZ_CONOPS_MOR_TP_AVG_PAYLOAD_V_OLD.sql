CREATE VIEW [mor].[ZZZ_CONOPS_MOR_TP_AVG_PAYLOAD_V_OLD] AS








--select * from [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V] WITH (NOLOCK) where shiftflag = 'curr'  ORDER BY shiftflag, siteflag, TRUCK
CREATE VIEW [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V_OLD] 
AS

SELECT SHIFTINDEX,
	   TRUCK,
	   [Operator],
	   OperatorImageURL,
	   COALESCE([AVG_Payload], 0) [AVG_Payload],
	   267 [Target]
FROM (
	SELECT  [payload].SHIFTINDEX,
			[payload].SITE_CODE,
			[t].FieldId [TRUCK],
			COALESCE([w].FieldName, 'NONE') AS [Operator],
			CASE WHEN [w].FieldId IS NULL OR [w].FieldId = -1 THEN NULL
 		    ELSE concat('https://images.services.fmi.com/publishedimages/',
			 		    RIGHT('0000000000' + [w].FieldId, 10),'.jpg') END as OperatorImageURL,
			AVG([payload].MEASURETON) [AVG_Payload]
	FROM [mor].[pit_truck_c] (NOLOCK) [t]
	LEFT JOIN [dbo].[lh_load] (NOLOCK) [payload]
	ON [payload].TRUCK = [t].FieldId
	AND [payload].SHIFTINDEX = [t].SHIFTINDEX
	LEFT JOIN [mor].[pit_worker] [w] WITH (NOLOCK)
	ON [w].Id = [t].FieldCuroper
	WHERE [payload].SITE_CODE = 'MOR'
		  AND [payload].MEASURETON > 200
	GROUP BY [payload].SHIFTINDEX,[payload]. SITE_CODE, [t].FieldId, [w].FieldName, [w].FieldId
) [AvgPayload]


