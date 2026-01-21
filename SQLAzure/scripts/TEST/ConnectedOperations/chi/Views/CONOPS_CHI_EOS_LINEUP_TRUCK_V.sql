CREATE VIEW [chi].[CONOPS_CHI_EOS_LINEUP_TRUCK_V] AS







-- SELECT * FROM [chi].[CONOPS_CHI_EOS_LINEUP_TRUCK_V]  WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [chi].[CONOPS_CHI_EOS_LINEUP_TRUCK_V] 
AS

WITH ae AS (
	SELECT shiftid,
		   eqmt,
		   reasonidx,
		   reasons
		FROM [CHI].[asset_efficiency] WITH (NOLOCK)
		WHERE EQMT NOT IN ('897','898')
)

SELECT DISTINCT
	   [t].[shiftflag],
	   [t].[siteflag],
	   [t].[shiftid],
	   [t].[TruckID],
	   [t].[StatusCode],
	   [t].[StatusName],
	   [t].[StatusStart]
FROM (
	SELECT [t].SHIFTINDEX,
		   [shift].shiftflag,
	       [shift].[siteflag],
	       [shift].shiftid,
		   [shift].shiftstartdatetime,
		   [t].FieldId AS [TruckID],
		   [enumStats].Idx AS [StatusCode],
		   [enumStats].Description AS [StatusName],
		   DATEADD(HH,current_utc_offset,DATEADD(ss,[t].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
		   [t].FieldReason
	FROM [CHI].[pit_truck_c] [t] WITH (NOLOCK)
	LEFT JOIN [CHI].[enum] [enumStats] WITH (NOLOCK)
		ON [t].FieldStatus = [enumStats].Id
	LEFT JOIN [CHI].[CONOPS_CHI_SHIFT_INFO_V] [shift] WITH (NOLOCK)
		ON [t].SHIFTINDEX = [shift].ShiftIndex
	WHERE [t].FieldId NOT IN ('897','898')
) [t]
LEFT JOIN [ae] 
ON [t].shiftid = [ae].shiftid AND [t].TruckID = [ae].eqmt 
   AND [t].FieldReason = [ae].reasonidx
WHERE [t].[StatusName] = 'Ready'
AND [StatusStart] < DATEADD(MINUTE,51,[t].[shiftstartdatetime])







