CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SP_AVG_PAYLOAD_V_OLD] AS





--select * from [mor].[CONOPS_MOR_SP_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [mor].[CONOPS_MOR_SP_AVG_PAYLOAD_V_OLD] 
AS

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   EXCAV,
	   COALESCE([AVG_Payload], 0) [AVG_Payload],
	   267 [Target]
FROM [dbo].[SHIFT_INFO_V] [shift]
LEFT JOIN (
	SELECT SHIFTINDEX,
		   SITE_CODE,
		   EXCAV,
		   AVG([load].MEASURETON) Avg_Payload
	FROM [dbo].[lh_load] [load] WITH (NOLOCK)
	WHERE [load].MEASURETON > 200
	GROUP BY SHIFTINDEX, SITE_CODE, EXCAV
) [AvgPayload]
on [AvgPayload].SHIFTINDEX = [shift].ShiftIndex
   AND [AvgPayload].SITE_CODE = [shift].[siteflag]
WHERE [shift].[siteflag] = 'MOR'

