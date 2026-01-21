CREATE VIEW [CER].[CONOPS_CER_PAYLOAD_MEASURETON_V] AS






--select * from [CER].[CONOPS_CER_PAYLOAD_MEASURETON_V] where shiftflag = 'curr'
CREATE VIEW [CER].[CONOPS_CER_PAYLOAD_MEASURETON_V]
AS

WITH PayloadTarget AS (
SELECT
	shiftid,
	truckid,
	CASE WHEN truckid LIKE 'C1%' THEN 245
		WHEN truckid LIKE 'C3%' THEN 300
		WHEN truckid LIKE 'C4%' THEN 381
		WHEN truckid LIKE 'C5%' THEN 380 END AS TruckPayloadTarget
FROM [CER].[CONOPS_CER_TRUCK_DETAIL_V]
)

SELECT
	s.SITEFLAG,
	s.SHIFTID,
	TRUCK,
	EXCAV,
	MEASURETON,
	TruckPayloadTarget AS PayloadTarget
FROM [dbo].[lh_load] [load] WITH (NOLOCK)
LEFT JOIN [CER].[CONOPS_CER_SHIFT_INFO_V] [s]
	ON [load].SHIFTINDEX = [s].SHIFTINDEX
LEFT JOIN PayloadTarget t
	ON s.shiftid = t.shiftid
	AND load.TRUCK = t.TruckId
WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CER')
	AND SITE_CODE = 'CER'
	AND s.shiftid IS NOT NULL

