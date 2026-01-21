CREATE VIEW [cer].[CONOPS_CER_EOS_LINEUP_EQMT_OTHER_V] AS










-- SELECT * FROM [cer].[CONOPS_CER_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [cer].[CONOPS_CER_EOS_LINEUP_EQMT_OTHER_V]
AS

WITH SUPEQMT AS (
	SELECT 
		pax.[ShiftIndex],
		pax.[FieldId],
		( SELECT TOP 1 [DESCRIPTION] FROM [cer].[Enum] WITH (NOLOCK) WHERE [enum_id] = pax.[FieldEqmttype] ) AS [EquipmentType],
		( SELECT TOP 1 [DESCRIPTION] FROM [cer].[Enum] WITH (NOLOCK) WHERE [enum_id] = pax.[FieldUnit] ) AS [EquipmentGroup],
		pax.[FieldUnit],
		pax.[FieldStatus],
		pax.[FieldLoc],
		pax.[FieldCuroper],
		pax.[FieldReason],
		pax.[FieldLaststatustime]
	FROM [cer].[PIT_AUXEQMT_C] pax WITH (NOLOCK)
	WHERE pax.[FieldStatus] NOT IN (14, 15, 17, 43) AND ( SELECT TOP 1 [DESCRIPTION] FROM [cer].[Enum] WITH (NOLOCK) WHERE [enum_id] = pax.[FieldUnit] ) NOT LIKE 'PR%'
)


SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   [shift].shiftid,
	   [se].SHIFTINDEX,
	   [se].SupportEquipmentId,
	   [se].SupportEquipment,
	   [se].[StatusCode],
	   [se].[StatusName],
	   [se].[StatusStart]
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN ( 
	SELECT [pax].SHIFTINDEX,
		[pax].FieldId AS SupportEquipmentId,
		[pax].EquipmentGroup AS SupportEquipment,
		[enumStats].Idx AS [StatusCode],
		[enumStats].Description AS [StatusName],
		DATEADD(HH,-7,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
		[pax].FieldReason
	FROM SUPEQMT [pax] WITH (NOLOCK)
	LEFT JOIN [cer].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].enum_id
) [se]
on [se].SHIFTINDEX = [shift].ShiftIndex
WHERE [se].[StatusName] = 'Operativo'
AND [se].[StatusStart] < DATEADD(MINUTE,51,[shift].SHIFTSTARTDATETIME)


