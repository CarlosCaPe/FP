CREATE VIEW [cer].[CONOPS_CER_SHOVEL_PAYLOAD_TARGET_V] AS




--select * from [cer].[CONOPS_CER_SHOVEL_PAYLOAD_TARGET_V] where shiftflag = 'prev'
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_PAYLOAD_TARGET_V]
AS

WITH CTE AS (
SELECT 
shiftflag,
shiftid,
truckid,
assignedShovel as shovelid
FROM [cer].[CONOPS_CER_TRUCK_DETAIL_V]),

TruckPayload AS (
SELECT
shiftflag,
shiftid,
truckid,
CASE WHEN truckid LIKE 'C1%' THEN '245'
WHEN truckid LIKE 'C3%' THEN '300'
WHEN truckid LIKE 'C4%' THEN '381'
WHEN truckid LIKE 'C5%' THEN '380' END AS TruckPayloadTarget
FROM CTE)


SELECT
a.shiftflag,
a.shiftid,
shovelid,
AVG(CAST(TruckPayloadTarget AS INT)) AS ShovelPayloadTarget
FROM CTE a
LEFT JOIN TruckPayload b ON a.shiftid = b.shiftid AND a.truckid = b.truckid
GROUP BY 
a.shiftflag,
a.shiftid,
shovelid


