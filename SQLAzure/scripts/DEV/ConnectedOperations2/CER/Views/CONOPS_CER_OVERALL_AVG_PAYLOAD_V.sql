CREATE VIEW [CER].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V] AS





--select * from [cer].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [cer].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V]
AS

WITH CTE AS (
SELECT SHIFTINDEX,
		   SITE_CODE,
		   AVG([load].MEASURETON) Avg_Payload
	FROM [dbo].[lh_load] [load] WITH (NOLOCK)
	WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CER')
	AND SITE_CODE = 'CER'
	GROUP BY SHIFTINDEX, SITE_CODE),

PayloadTarget AS (
SELECT
shiftindex,
truckid,
CASE WHEN truckid LIKE 'C1%' THEN '245'
		WHEN truckid LIKE 'C3%' THEN '300'
		WHEN truckid LIKE 'C4%' THEN '381'
		WHEN truckid LIKE 'C5%' THEN '380' END AS TruckPayloadTarget
FROM [CER].[CONOPS_CER_TRUCK_DETAIL_V])

SELECT
a.shiftflag,
a.siteflag,
COALESCE([AVG_Payload], 0) [AVG_Payload],
AVG(CAST(TruckPayloadTarget AS INT)) AS [Target]
FROM [CER].[CONOPS_CER_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftindex = b.shiftindex 
LEFT JOIN PayloadTarget c ON a.shiftindex = c.shiftindex 

GROUP BY 
a.shiftflag,
a.siteflag,
AVG_Payload


