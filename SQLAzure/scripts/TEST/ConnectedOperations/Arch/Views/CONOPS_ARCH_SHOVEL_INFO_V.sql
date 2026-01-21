CREATE VIEW [Arch].[CONOPS_ARCH_SHOVEL_INFO_V] AS




CREATE   VIEW [Arch].[CONOPS_ARCH_SHOVEL_INFO_V]
AS

WITH ae AS (
	SELECT shiftid
		   , eqmt
		   , reasonidx
		   , reasons
	FROM (
		SELECT shiftid,
			   eqmt,
			   reasonidx,
			   reasons,
			   ROW_NUMBER() OVER (PARTITION BY shiftid, eqmt  ORDER BY startdatetime DESC) AS rn
		FROM [Arch].[asset_efficiency] WITH (NOLOCK)
	) [a]
	WHERE rn = 1
)

SELECT [shift].shiftflag,
	   [shift].shiftindex,
	   [shift].shiftid,
	   [shift].[siteflag],
	   [ShovelID],
	   [Location],
	   Region,
	   [StatusCode],
	   [StatusName],
	   [StatusStart],
	   [s].FieldReason [ReasonId],
	   [ae].reasons [ReasonDesc],
	   [OperatorId],
	   [Operator],
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
	   ELSE concat('https://images.services.fmi.com/publishedimages/',
				   RIGHT('0000000000' + [OperatorId], 10),'.jpg') END as OperatorImageURL
FROM [Arch].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT [SHIFTINDEX],
		   [SHIFTID],
		   '<SITECODE>' [siteflag],
		   [s].[FieldId] [ShovelID],
		   [loc].[FieldId] AS [Location],
		   region.[FieldId] AS Region,
		   [enumStats].Idx AS [StatusCode],
		   [enumStats].Description AS [StatusName],
		   DATEADD(HH,-7,DATEADD(ss,[s].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
		   [w].FieldId AS [OperatorId],
		   COALESCE([w].FieldName, 'NONE') AS [Operator],
		   [s].FieldReason
	FROM [Arch].[pit_excav_c] [s] WITH (NOLOCK)
	LEFT JOIN [Arch].[enum] [enumStats] WITH (NOLOCK)
		ON [s].FieldStatus = [enumStats].Id
	LEFT JOIN [Arch].[pit_loc] [loc] WITH (NOLOCK)
		ON [loc].Id = [s].FieldLoc
	LEFT JOIN [Arch].[pit_loc] [region] WITH (NOLOCK)
		ON loc.FieldRegion = [region].Id
	LEFT JOIN [Arch].[pit_worker] [w] WITH (NOLOCK)
		ON [w].Id = [s].FieldCuroper
) [s]
ON [shift].shiftid = [s].SHIFTID
   AND [shift].[siteflag] = [s].[siteflag]
LEFT JOIN [ae] 
ON [shift].shiftid = [ae].shiftid AND [s].ShovelID = [ae].eqmt
   AND [s].FieldReason = [ae].reasonidx


