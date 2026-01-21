CREATE VIEW [CHI].[CONOPS_CHI_EQMT_TRUCK_HOURLY_PAYLOAD_V] AS

--SELECT * FROM [chi].[CONOPS_CHI_EQMT_TRUCK_HOURLY_PAYLOAD_V] WHERE shiftflag = 'curr'
CREATE VIEW [chi].[CONOPS_CHI_EQMT_TRUCK_HOURLY_PAYLOAD_V]
AS

WITH CTE AS (
SELECT
	ShiftId,
	Truck AS Equipment,
	FieldTons AS Payload,
	TimeFull_HOS AS HOS
FROM CHI.SHIFT_LOAD_DETAIL_V WITH (NOLOCK)
WHERE PayloadFilter = 1
)

SELECT 
	shiftflag,
	a.siteflag,
	Equipment,
	avg(payload) as payload,
	dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM CHI.CONOPS_CHI_SHIFT_INFO_V a
LEFT JOIN CTE b
	ON a.SHIFTID = b.SHIFTID
GROUP BY shiftflag,
	a.siteflag,
	Equipment,
	HOS,
	SHIFTSTARTDATETIME
