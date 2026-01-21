CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TRUCK_HOURLY_PAYLOAD_V] AS

--SELECT * FROM [abr].[CONOPS_ABR_EQMT_TRUCK_HOURLY_PAYLOAD_V] WHERE shiftflag = 'curr'

CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TRUCK_HOURLY_PAYLOAD_V]
AS

WITH CTE AS (
SELECT
	ShiftId,
	Truck AS Equipment,
	FieldTons AS Payload,
	TimeFull_HOS AS HOS
FROM ABR.SHIFT_LOAD_DETAIL_V WITH (NOLOCK)
WHERE PayloadFilter = 1
)

SELECT 
	shiftflag,
	a.siteflag,
	Equipment,
	avg(payload) as payload,
	dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM ABR.CONOPS_ABR_SHIFT_INFO_V a
LEFT JOIN CTE b
	ON a.SHIFTID = b.SHIFTID
GROUP BY shiftflag,
	a.siteflag,
	Equipment,
	HOS,
	SHIFTSTARTDATETIME

