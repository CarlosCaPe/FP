CREATE VIEW [cer].[ZZZ_CONOPS_CER_OVERALL_AVG_PAYLOAD_V_OLD] AS



--select * from [cer].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [cer].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V_OLD]
AS

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   COALESCE([AVG_Payload], 0) [AVG_Payload],
	   260 [Target]
FROM [CER].[CONOPS_CER_SHIFT_INFO_V] [shift]
LEFT JOIN (
	SELECT SHIFTINDEX,
		   SITE_CODE,
		   AVG([load].MEASURETON) Avg_Payload
	FROM [dbo].[lh_load] [load] WITH (NOLOCK)
	WHERE [load].MEASURETON > 200 AND SITE_CODE = 'CER'
	GROUP BY SHIFTINDEX, SITE_CODE
) [AvgPayload]
on [AvgPayload].SHIFTINDEX = [shift].ShiftIndex
   AND [AvgPayload].SITE_CODE = [shift].[siteflag]

