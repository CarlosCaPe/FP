CREATE VIEW [SIE].[CONOPS_SIE_DAILY_EOS_LINEUP_SHOVEL_V] AS



-- SELECT * FROM [sie].[CONOPS_SIE_DAILY_EOS_LINEUP_SHOVEL_V]  WHERE [shiftflag] = 'CURR'
CREATE VIEW [sie].[CONOPS_SIE_DAILY_EOS_LINEUP_SHOVEL_V] 
AS

WITH ae AS (
	SELECT shiftid,
		   eqmt,
		   reasonidx,
		   reasons,
		   status,
		   statusidx
	FROM [SIE].[asset_efficiency] WITH (NOLOCK)
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
	FROM [SIE].[pit_excav_c] [s] WITH (NOLOCK)
	LEFT JOIN [SIE].[CONOPS_SIE_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)
		ON [s].shiftid = [shift].shiftid
) [s]
LEFT JOIN [ae] 
ON [s].shiftid = [ae].shiftid AND [s].ShovelID = [ae].eqmt 
   AND [s].FieldReason = [ae].reasonidx
WHERE [ae].[Status] = 'Ready'
	AND [StatusStart] < DATEADD(MINUTE,51,[s].[shiftstartdatetime])



