CREATE VIEW [TYR].[CONOPS_TYR_DAILY_EOS_LINEUP_SHOVEL_V] AS


-- SELECT * FROM [tyr].[CONOPS_TYR_DAILY_EOS_LINEUP_SHOVEL_V]  WHERE [shiftflag] = 'CURR'
CREATE VIEW [TYR].[CONOPS_TYR_DAILY_EOS_LINEUP_SHOVEL_V] 
AS

WITH ae AS (
	SELECT shiftid,
		   eqmt,
		   reasonidx,
		   reasons,
		   status,
		   statusidx
	FROM [TYR].[asset_efficiency] WITH (NOLOCK)
)

SELECT DISTINCT
	   [s].shiftflag,
	   [s].shiftid,
	   [s].[siteflag],
	   [s].[shiftstartdatetime],
	   [s].[ShovelID],
	   [ae].[StatusIdx] AS [StatusCode],
	   [ae].[Status] AS [StatusName],
	   [s].[StatusStart]
FROM (
	SELECT [shift].shiftflag,
	       [shift].siteflag,
	       [shift].shiftid,
		   [shift].shiftstartdatetime,
		   [s].FieldId AS [ShovelID],
		   DATEADD(HH,current_utc_offset,DATEADD(ss,[s].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
		   [s].FieldReason
	FROM [TYR].[pit_excav_c] [s] WITH (NOLOCK)
	LEFT JOIN [TYR].[CONOPS_TYR_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)
		ON [s].shiftid = [shift].shiftid
) [s]
LEFT JOIN [ae] 
ON [s].shiftid = [ae].shiftid AND [s].ShovelID = [ae].eqmt 
   AND [s].FieldReason = [ae].reasonidx
WHERE [ae].[Status] = 'Ready'
	AND [StatusStart] < DATEADD(MINUTE,51,[s].[shiftstartdatetime])



