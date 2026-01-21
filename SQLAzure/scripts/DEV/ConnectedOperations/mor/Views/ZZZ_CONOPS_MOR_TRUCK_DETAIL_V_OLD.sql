CREATE VIEW [mor].[ZZZ_CONOPS_MOR_TRUCK_DETAIL_V_OLD] AS






-- SELECT * FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [mor].[CONOPS_MOR_TRUCK_DETAIL_V_OLD] 
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
		FROM [mor].[asset_efficiency] WITH (NOLOCK)
	) [a]
	WHERE rn = 1
)

SELECT [shift].shiftflag,
	   [siteflag],
	   [shift].shiftid,
	   [t].SHIFTINDEX,
	   [t].[TruckID],
	   [t].[StatusCode],
	   [t].[StatusName],
	   [t].FieldReason [ReasonId],
	   [ae].reasons [ReasonDesc],
	   --CAST([t].FieldReason as varchar(10)) + ':' + [ae].reasons [StatusDesc],
	   [t].[StatusStart],
	   [t].[Location],
	   [t].Region,
	   [t].[Operator],
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
	   ELSE concat('https://images.services.fmi.com/publishedimages/',
				   RIGHT('0000000000' + [OperatorId], 10),'.jpg') END as OperatorImageURL,
	   [t].[AssignedShovel]
FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT [t].SHIFTINDEX,
		   [t].FieldId AS [TruckID],
		   [enumStats].Idx AS [StatusCode],
		   [enumStats].Description AS [StatusName],
		   DATEADD(HH,-7,DATEADD(ss,[t].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
		   [loc].[FieldId] AS [Location],
		   region.[FieldId] AS Region,
		   [w].FieldId AS [OperatorId],
		   COALESCE([w].FieldName, 'NONE') AS [Operator],
		   [s].FieldId [AssignedShovel],
		   [t].FieldReason
	FROM [mor].[pit_truck_c] [t] WITH (NOLOCK)
	LEFT JOIN [mor].[pit_excav_c] [s] WITH (NOLOCK)
	ON [t].fieldexcav = [s].Id AND [t].SHIFTINDEX = [s].SHIFTINDEX
	LEFT JOIN [mor].[enum] [enumStats] WITH (NOLOCK)
	ON [t].FieldStatus = [enumStats].Id
	LEFT JOIN [mor].[pit_loc] [loc] WITH (NOLOCK)
	ON [loc].Id = [t].FieldLoc
	LEFT JOIN [mor].[pit_loc] [region] WITH (NOLOCK)
	ON [loc].FieldRegion = [region].Id
	LEFT JOIN [mor].[pit_worker] [w] WITH (NOLOCK)
	ON [w].Id = [t].FieldCuroper
) [t]
on [t].SHIFTINDEX = [shift].ShiftIndex
LEFT JOIN [ae] 
ON [shift].shiftid = [ae].shiftid AND [t].TruckID = [ae].eqmt 
   AND [t].FieldReason = [ae].reasonidx
WHERE siteflag = 'MOR'
