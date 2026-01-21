CREATE VIEW [CHI].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_PAYLOAD_V] AS

--SELECT * FROM [chi].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_PAYLOAD_V] WHERE shiftflag = 'prev' and equipment = '35'
CREATE VIEW [chi].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_PAYLOAD_V]
AS

WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Excav AS Equipment,
	FieldTons AS Payload,
	TimeFull_HOS AS HOS
FROM CHI.shift_load_detail_v
WHERE PayloadFilter = 1
)

SELECT 
	shiftflag,
	a.siteflag,
	Equipment,
	AVG(payload) as payload,
	DATEADD(HOUR, HOS, SHIFTSTARTDATETIME) AS TimeinHour
FROM CHI.CONOPS_CHI_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.SHIFTID = b.SHIFTID
GROUP BY shiftflag,
	a.siteflag,
	Equipment,
	HOS,
	SHIFTSTARTDATETIME

