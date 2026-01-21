CREATE VIEW [Arch].[CONOPS_ARCH_TRUCK_DETAIL_V] AS




CREATE     VIEW [Arch].[CONOPS_ARCH_TRUCK_DETAIL_V]
AS

WITH reason AS (
	SELECT SITE_CODE,
		   FIELDID,
		   FIELDNAME
	FROM [dbo].[pit_reason] WITH (NOLOCK)
	--WHERE site_code = '<SITECODE>'
)

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   [shift].shiftid,
	   [t].SHIFTINDEX,
	   [t].[TruckID],
	   [t].[StatusCode],
	   [t].[StatusName],
	   [t].FieldReason [ReasonId],
	   [reason].FIELDNAME [ReasonDesc],
	   [t].[StatusStart],
	   [t].[Location],
	   [t].Region,
	   [t].[Operator],
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
	   ELSE concat('https://images.services.fmi.com/publishedimages/',
				   RIGHT('0000000000' + [OperatorId], 10),'.jpg') END as OperatorImageURL,
	   [t].[AssignedShovel]
FROM [Arch].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT [t].SHIFTINDEX,
		   '<SITECODE>' AS [siteflag],
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
	FROM [Arch].[pit_truck_c] [t] WITH (NOLOCK)
	LEFT JOIN [Arch].[pit_excav_c] [s] WITH (NOLOCK)
	ON [t].fieldexcav = [s].Id AND [t].SHIFTINDEX = [s].SHIFTINDEX
	LEFT JOIN [Arch].[enum] [enumStats] WITH (NOLOCK)
	ON [t].FieldStatus = [enumStats].Id
	LEFT JOIN [Arch].[pit_loc] [loc] WITH (NOLOCK)
	ON [loc].Id = [t].FieldLoc
	LEFT JOIN [Arch].[pit_loc] [region] WITH (NOLOCK)
	ON [loc].FieldRegion = [region].Id
	LEFT JOIN [Arch].[pit_worker] [w] WITH (NOLOCK)
	ON [w].Id = [t].FieldCuroper
) [t]
on [t].SHIFTINDEX = [shift].ShiftIndex AND [t].siteflag = [shift].siteflag
LEFT JOIN reason 
ON [t].FieldReason = reason.FIELDID
   AND [shift].siteflag = reason.SITE_CODE

