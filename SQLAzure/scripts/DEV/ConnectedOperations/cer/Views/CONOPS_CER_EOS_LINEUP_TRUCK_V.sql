CREATE VIEW [cer].[CONOPS_CER_EOS_LINEUP_TRUCK_V] AS






-- SELECT * FROM [cer].[CONOPS_CER_EOS_LINEUP_TRUCK_V]  WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [cer].[CONOPS_CER_EOS_LINEUP_TRUCK_V] 
AS

WITH ae AS (
	SELECT shiftid,
		   eqmt,
		   reasonidx,
		   reasons
		FROM [CER].[asset_efficiency] WITH (NOLOCK)
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
	FROM [CER].[pit_truck_c] [t] WITH (NOLOCK)
	LEFT JOIN [CER].[enum] [enumStats] WITH (NOLOCK)
		ON [t].FieldStatus = [enumStats].enum_id
	LEFT JOIN [CER].[CONOPS_CER_SHIFT_INFO_V] [shift] WITH (NOLOCK)
		ON [t].SHIFTINDEX = [shift].ShiftIndex
) [t]
LEFT JOIN [ae] 
ON [t].shiftid = [ae].shiftid AND [t].TruckID = [ae].eqmt 
   AND [t].FieldReason = [ae].reasonidx
WHERE [t].[StatusName] = 'Operativo'
AND [StatusStart] < DATEADD(MINUTE,51,[t].[shiftstartdatetime])





