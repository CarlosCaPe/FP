CREATE VIEW [chi].[CONOPS_CHI_EOS_LINEUP_EQMT_OTHER_V] AS










-- SELECT * FROM [chi].[CONOPS_CHI_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [chi].[CONOPS_CHI_EOS_LINEUP_EQMT_OTHER_V]
AS

WITH SUPEQMT AS (
	SELECT ShiftIndex, 
		FieldId,
		[EquipmentType],
		[EquipmentGroup],
		[FieldUnit],
		[FieldStatus],
		[FieldLoc],
		[FieldCuroper],
		[FieldReason],
		[FieldLaststatustime]
	FROM (
		SELECT
			tax.[ShiftIndex],
			tax.[FieldId],
			( SELECT TOP 1 [DESCRIPTION] FROM [chi].[Enum] WITH (NOLOCK) WHERE [Id] = tax.[FieldEqmttype] ) AS [EquipmentType],
			( SELECT TOP 1 [DESCRIPTION] FROM [chi].[Enum] WITH (NOLOCK) WHERE [Id] = tax.[FieldUnit] ) AS [EquipmentGroup],
			tax.[FieldUnit],
			tax.[FieldStatus],
			tax.[FieldLoc],
			tax.[FieldCuroper],
			tax.[FieldReason],
			tax.[FieldLaststatustime]
		FROM [chi].[PIT_TRUCK_C] tax WITH (NOLOCK)
	) as tse
	WHERE tse.EquipmentType NOT LIKE ('CAT 793%')

	UNION

	SELECT 
		pax.[ShiftIndex],
		pax.[FieldId],
		( SELECT TOP 1 [DESCRIPTION] FROM [chi].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldEqmttype] ) AS [EquipmentType],
		( SELECT TOP 1 [DESCRIPTION] FROM [chi].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldUnit] ) AS [EquipmentGroup],
		pax.[FieldUnit],
		pax.[FieldStatus],
		pax.[FieldLoc],
		pax.[FieldCuroper],
		pax.[FieldReason],
		pax.[FieldLaststatustime]
	FROM [chi].[PIT_AUXEQMT_C] pax WITH (NOLOCK)
	WHERE pax.[FieldUnit] <> 227
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
		CASE WHEN [pax].EquipmentGroup = 'Grader'
				THEN 'Motor Grader'
			WHEN [pax].EquipmentGroup = 'RTD'
				THEN 'Rubber Tire Dozer'
			ELSE [pax].EquipmentGroup
		END AS SupportEquipment,
		[enumStats].Idx AS [StatusCode],
		[enumStats].Description AS [StatusName],
		DATEADD(HH,current_utc_offset,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
		[pax].FieldReason
	FROM SUPEQMT [pax] WITH (NOLOCK)
	LEFT JOIN [CHI].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].Id
	LEFT JOIN [CHI].[CONOPS_CHI_SHIFT_INFO_V] [shift]
		ON [pax].SHIFTINDEX = [shift].ShiftIndex
) [se]
WHERE [se].[StatusName] = 'Ready'
AND [se].[StatusStart] < DATEADD(MINUTE,51,[se].shiftstartdatetime)


