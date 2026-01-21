CREATE VIEW [Arch].[CONOPS_ARCH_TP_AVG_PAYLOAD_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_TP_AVG_PAYLOAD_V]
AS

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   TRUCK,
	   COALESCE([AVG_Payload], 0) [AVG_Payload],
	   260 [Target]
FROM [dbo].[SHIFT_INFO_V] [shift]
LEFT JOIN (
	SELECT  SHIFTINDEX,
			SITE_CODE,
			TRUCK,
			AVG([payload].MEASURETON) [AVG_Payload]
	FROM [dbo].[lh_load] (NOLOCK) [payload]
	WHERE --site_code = '<SITECODE>'
		  --AND 
		  [payload].MEASURETON > 200
	GROUP BY SHIFTINDEX, SITE_CODE, TRUCK
) [AvgPayload]
on [AvgPayload].SHIFTINDEX = [shift].ShiftIndex
   AND [AvgPayload].SITE_CODE = [shift].[siteflag]
WHERE [shift].[siteflag] = '<SITECODE>'

