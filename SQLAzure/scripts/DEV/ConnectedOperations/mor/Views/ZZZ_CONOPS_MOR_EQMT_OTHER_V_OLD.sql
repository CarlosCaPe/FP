CREATE VIEW [mor].[ZZZ_CONOPS_MOR_EQMT_OTHER_V_OLD] AS



-- SELECT * FROM [mor].[CONOPS_MOR_EQMT_OTHER_V_OLD] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [mor].[CONOPS_MOR_EQMT_OTHER_V_OLD]
AS

WITH REASONDESC AS (
	SELECT [FIELDCATEGORY]
		,[FIELDNAME]
		,CASE WHEN LEFT([FIELDID], 1) = 0 then SUBSTRING([FIELDID], 2, LEN(FIELDID-1) )
			ELSE [FIELDID]
		END AS FieldId
	FROM dbo.[pit_reason] [pr] WITH (NOLOCK)
	WHERE SITE_CODE = 'MOR'
)

SELECT [shift].shiftflag,
	   [siteflag],
	   [shift].shiftid,
	   [se].SHIFTINDEX,
	   [se].SupportEquipmentId,
	   [se].SupportEquipment,
	   [se].[StatusCode],
	   [se].[StatusName],
	   [se].FieldReason [ReasonId],
	   [se].[FieldName] AS [ReasonDesc],
	   [se].[StatusStart],
	   [se].[Location],
	   [se].Region,
	   [se].[Operator],
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
	   ELSE concat('https://images.services.fmi.com/publishedimages/',
				   RIGHT('0000000000' + [OperatorId], 10),'.jpg') END as OperatorImageURL,
	   [shift].ShiftDuration as Duration
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN ( 
	SELECT [pax].SHIFTINDEX,
		[pax].FieldId AS SupportEquipmentId,
		CASE 
			WHEN [pax].[FieldUnit] = 23 THEN 'Aux loader'
			WHEN [pax].[FieldUnit] = 280 THEN 'Water Truck'
			WHEN [pax].[FieldUnit] = 275 THEN 'Dozer'
			WHEN [pax].[FieldUnit] = 276 THEN 'Motor Grader'
			WHEN [pax].[FieldUnit] = 277 THEN 'Rubber Tire Dozer'
		END AS SupportEquipment,
		[enumStats].Idx AS [StatusCode],
		[enumStats].Description AS [StatusName],
		DATEADD(HH,-7,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
		[loc].[FieldId] AS [Location],
		[rdc].[FieldName],
		region.[FieldId] AS Region,
		[w].FieldId AS [OperatorId],
		COALESCE([w].FieldName, 'NONE') AS [Operator],
		[pax].FieldReason
	FROM [mor].[pit_auxeqmt_c] [pax] WITH (NOLOCK)
	LEFT JOIN [mor].[pit_excav_c] [s] WITH (NOLOCK)
		ON [pax].fieldexcav = [s].Id AND [pax].SHIFTINDEX = [s].SHIFTINDEX
	LEFT JOIN [mor].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].Id
	LEFT JOIN [mor].[pit_loc] [loc] WITH (NOLOCK)
		ON [loc].Id = [pax].FieldLoc
	LEFT JOIN [mor].[pit_loc] [region] WITH (NOLOCK)
		ON [loc].FieldRegion = [region].Id
	LEFT JOIN [mor].[pit_worker] [w] WITH (NOLOCK)
		ON [w].Id = [pax].FieldCuroper
	LEFT JOIN REASONDESC [rdc]
		ON [pax].[FieldReason] = [rdc].[FieldId]
	WHERE [pax].FieldUnit IN (23, 280, 275, 276, 277)
) [se]
on [se].SHIFTINDEX = [shift].ShiftIndex

