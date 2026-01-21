CREATE VIEW [CLI].[CONOPS_CLI_EOS_LINEUP_EQMT_OTHER_V] AS




-- SELECT * FROM [cli].[CONOPS_CLI_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'PREV'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [cli].[CONOPS_CLI_EOS_LINEUP_EQMT_OTHER_V]
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
			( SELECT TOP 1 [DESCRIPTION] FROM [cli].[Enum] WITH (NOLOCK) WHERE [Id] = tax.[FieldEqmttype] ) AS [EquipmentType],
			( SELECT TOP 1 [DESCRIPTION] FROM [cli].[Enum] WITH (NOLOCK) WHERE [Id] = tax.[FieldUnit] ) AS [EquipmentGroup],
			tax.[FieldUnit],
			tax.[FieldStatus],
			tax.[FieldLoc],
			tax.[FieldCuroper],
			tax.[FieldReason],
			tax.[FieldLaststatustime]
		FROM [cli].[PIT_TRUCK_C] tax WITH (NOLOCK)
	) as tse
	WHERE tse.EquipmentType NOT LIKE ('CAT 789%')

	UNION

	SELECT 
		pax.[ShiftIndex],
		pax.[FieldId],
		( SELECT TOP 1 [DESCRIPTION] FROM [cli].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldEqmttype] ) AS [EquipmentType],
		( SELECT TOP 1 [DESCRIPTION] FROM [cli].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldUnit] ) AS [EquipmentGroup],
		pax.[FieldUnit],
		pax.[FieldStatus],
		pax.[FieldLoc],
		pax.[FieldCuroper],
		pax.[FieldReason],
		pax.[FieldLaststatustime]
	FROM [cli].[PIT_AUXEQMT_C] pax WITH (NOLOCK)
	WHERE pax.[FieldUnit] <> 227
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
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN ( 
	SELECT [pax].SHIFTINDEX,
		[pax].FieldId AS SupportEquipmentId,
		CASE WHEN [pax].EquipmentGroup = 'Grader'
				THEN 'Motor Grader'
			WHEN [pax].EquipmentGroup = 'RTD'
				THEN 'Rubber Tire Dozer'
			ELSE [pax].EquipmentGroup
		END AS SupportEquipment,
		[enumStats].Idx AS [StatusCode],
		[enumStats].Description AS [StatusName],
		DATEADD(HH,-7,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01')) AS [StatusStart]
	FROM SUPEQMT [pax] WITH (NOLOCK)
	LEFT JOIN [cli].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].Id
) [se]
on [se].SHIFTINDEX = [shift].ShiftIndex
WHERE [se].[StatusName] = 'Ready'
AND [se].[StatusStart] < DATEADD(MINUTE,51,[shift].SHIFTSTARTDATETIME)



