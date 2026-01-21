CREATE VIEW [bag].[CONOPS_BAG_EOS_LINEUP_EQMT_OTHER_V] AS








-- SELECT * FROM [bag].[CONOPS_BAG_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [bag].[CONOPS_BAG_EOS_LINEUP_EQMT_OTHER_V]
AS

WITH SUPEQMT AS (
	SELECT 
		pax.[ShiftIndex],
		pax.[FieldId],
		( SELECT TOP 1 [DESCRIPTION] FROM [bag].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldEqmttype] ) AS [EquipmentType],
		( SELECT TOP 1 [DESCRIPTION] FROM [bag].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldUnit] ) AS [EquipmentGroup],
		pax.[FieldUnit],
		pax.[FieldStatus],
		pax.[FieldLoc],
		pax.[FieldCuroper],
		pax.[FieldReason],
		pax.[FieldLaststatustime]
	FROM [bag].[PIT_AUXEQMT_C] pax WITH (NOLOCK)
	WHERE pax.[FieldUnit] IN (294, 296, 295, 300, 305, 297)
)


SELECT [se].shiftflag,
	   [se].[siteflag],
	   [se].shiftid,
	   [se].SHIFTINDEX,
	   [se].SupportEquipmentId,
	   [se].SupportEquipment,
	   [se].[StatusCode],
	   [se].[StatusName],
	   [se].[StatusStart]
FROM( 
	SELECT 
		[shift].shiftflag,
		[shift].[siteflag],
		[shift].shiftid,
		[pax].SHIFTINDEX,
		[shift].shiftstartdatetime,
		[pax].FieldId AS SupportEquipmentId,
		[pax].EquipmentGroup AS SupportEquipment,
		[enumStats].Idx AS [StatusCode],
		[enumStats].Description AS [StatusName],
		DATEADD(HH,current_utc_offset,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
		[pax].FieldReason
	FROM SUPEQMT [pax] WITH (NOLOCK)
	LEFT JOIN [bag].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].Id
	LEFT JOIN [bag].[CONOPS_BAG_SHIFT_INFO_V] [shift]
		ON [pax].SHIFTINDEX = [shift].ShiftIndex
) [se]
WHERE [se].[StatusName] = 'Ready'
AND [se].[StatusStart] < DATEADD(MINUTE,51,[se].shiftstartdatetime)


