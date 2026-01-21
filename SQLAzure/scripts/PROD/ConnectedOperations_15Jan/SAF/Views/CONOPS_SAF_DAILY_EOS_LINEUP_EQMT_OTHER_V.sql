CREATE VIEW [SAF].[CONOPS_SAF_DAILY_EOS_LINEUP_EQMT_OTHER_V] AS








-- SELECT * FROM [saf].[CONOPS_SAF_DAILY_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [saf].[CONOPS_SAF_DAILY_EOS_LINEUP_EQMT_OTHER_V]
AS

WITH SUPEQMT AS (
	SELECT 
		pax.[ShiftIndex],
		pax.[FieldId],
		( SELECT TOP 1 [DESCRIPTION] FROM [saf].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldEqmttype] ) AS [EquipmentType],
		( SELECT TOP 1 [DESCRIPTION] FROM [saf].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldUnit] ) AS [EquipmentGroup],
		pax.[FieldUnit],
		pax.[FieldStatus],
		pax.[FieldLoc],
		pax.[FieldCuroper],
		pax.[FieldReason],
		pax.[FieldLaststatustime]
	FROM [saf].[PIT_AUXEQMT_C] pax WITH (NOLOCK)
	WHERE pax.[FieldUnit] <> 292
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
	LEFT JOIN [SAF].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].Id
	LEFT JOIN [SAF].[CONOPS_SAF_EOS_SHIFT_INFO_V] [shift]
		ON [pax].SHIFTINDEX = [shift].ShiftIndex
) [se]
WHERE [se].[StatusName] = 'Ready'
AND [se].[StatusStart] < DATEADD(MINUTE,51,[se].shiftstartdatetime)


