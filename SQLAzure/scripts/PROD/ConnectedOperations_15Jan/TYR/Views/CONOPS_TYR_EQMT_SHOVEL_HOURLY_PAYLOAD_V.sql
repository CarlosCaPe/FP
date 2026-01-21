CREATE VIEW [TYR].[CONOPS_TYR_EQMT_SHOVEL_HOURLY_PAYLOAD_V] AS

--SELECT * FROM [tyr].[CONOPS_TYR_EQMT_SHOVEL_HOURLY_PAYLOAD_V] WHERE shiftflag = 'prev' and equipment = 'S11'
CREATE VIEW [TYR].[CONOPS_TYR_EQMT_SHOVEL_HOURLY_PAYLOAD_V]
AS

WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Excav AS Equipment,
	FieldTons AS Payload,
	TimeFull_HOS AS HOS
FROM TYR.shift_load_detail_v
WHERE PayloadFilter = 1
)

SELECT 
	shiftflag,
	a.siteflag,
	Equipment,
	AVG(payload) as payload,
	DATEADD(HOUR, HOS, SHIFTSTARTDATETIME) AS TimeinHour
FROM TYR.CONOPS_TYR_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.SHIFTID = b.SHIFTID
GROUP BY shiftflag,
	a.siteflag,
	Equipment,
	HOS,
	SHIFTSTARTDATETIME

