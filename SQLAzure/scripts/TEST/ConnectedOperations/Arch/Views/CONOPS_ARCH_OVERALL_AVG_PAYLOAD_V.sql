CREATE VIEW [Arch].[CONOPS_ARCH_OVERALL_AVG_PAYLOAD_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_OVERALL_AVG_PAYLOAD_V]
AS

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   COALESCE([AVG_Payload], 0) [AVG_Payload],
	   260 [Target]
FROM [dbo].[SHIFT_INFO_V] [shift]
LEFT JOIN (
	SELECT SHIFTINDEX,
		   SITE_CODE,
		   AVG([load].MEASURETON) Avg_Payload
	FROM [dbo].[lh_load] [load] WITH (NOLOCK)
	WHERE [load].MEASURETON > 200 AND SITE_CODE = '<SITECODE>'
	GROUP BY SHIFTINDEX, SITE_CODE
) [AvgPayload]
on [AvgPayload].SHIFTINDEX = [shift].ShiftIndex
   AND [AvgPayload].SITE_CODE = [shift].[siteflag]
WHERE [shift].[siteflag] = '<SITECODE>'

