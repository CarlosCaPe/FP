CREATE VIEW [MOR].[CONOPS_MOR_EQMT_SHOVEL_HOURLY_PAYLOAD_V] AS

--SELECT * FROM [mor].[CONOPS_MOR_EQMT_SHOVEL_HOURLY_PAYLOAD_V] WHERE shiftflag = 'curr'  
CREATE VIEW [mor].[CONOPS_MOR_EQMT_SHOVEL_HOURLY_PAYLOAD_V]  
AS  

WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Excav AS Equipment,
	FieldTons AS Payload,
	TimeLoad_TS AS LoadTime
FROM mor.shift_load_detail_v
)

SELECT 
	shiftflag,
	a.siteflag,
	Equipment,
	avg(payload) as payload,
	DATEADD(HOUR, DATEDIFF(HOUR, SHIFTSTARTDATETIME, LoadTime), SHIFTSTARTDATETIME) AS TimeinHour
FROM MOR.CONOPS_MOR_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.SHIFTID = b.SHIFTID
GROUP BY shiftflag,
	a.siteflag,
	Equipment,
	DATEDIFF(HOUR, SHIFTSTARTDATETIME, LoadTime),
	SHIFTSTARTDATETIME

