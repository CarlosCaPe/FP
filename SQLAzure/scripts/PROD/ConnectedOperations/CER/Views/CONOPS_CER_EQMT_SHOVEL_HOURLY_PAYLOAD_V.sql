CREATE VIEW [CER].[CONOPS_CER_EQMT_SHOVEL_HOURLY_PAYLOAD_V] AS

--SELECT * FROM [cer].[CONOPS_CER_EQMT_SHOVEL_HOURLY_PAYLOAD_V] WHERE shiftflag = 'prev' and equipment = 'CF24'
CREATE VIEW [cer].[CONOPS_CER_EQMT_SHOVEL_HOURLY_PAYLOAD_V]
AS

WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Excav AS Equipment,
	FieldTons AS Payload,
	TimeFull_HOS AS HOS
FROM CER.shift_load_detail_v
WHERE PayloadFilter = 1
)

SELECT 
	shiftflag,
	a.siteflag,
	Equipment,
	avg(payload) as payload,
	DATEADD(HOUR, HOS, SHIFTSTARTDATETIME) AS TimeinHour
FROM CER.CONOPS_CER_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.SHIFTID = b.SHIFTID
GROUP BY shiftflag,
	a.siteflag,
	Equipment,
	HOS,
	SHIFTSTARTDATETIME

