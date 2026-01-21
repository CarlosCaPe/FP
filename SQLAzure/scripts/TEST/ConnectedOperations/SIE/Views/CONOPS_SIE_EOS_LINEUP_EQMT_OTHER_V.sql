CREATE VIEW [SIE].[CONOPS_SIE_EOS_LINEUP_EQMT_OTHER_V] AS







-- SELECT * FROM [sie].[CONOPS_SIE_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [sie].[CONOPS_SIE_EOS_LINEUP_EQMT_OTHER_V]
AS

WITH SUPEQMT AS (
	SELECT 
		pax.[ShiftIndex],
		pax.[FieldId],
		( SELECT TOP 1 [DESCRIPTION] FROM [sie].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldEqmttype] ) AS [EquipmentType],
		( SELECT TOP 1 [DESCRIPTION] FROM [sie].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldUnit] ) AS [EquipmentGroup],
		pax.[FieldUnit],
		pax.[FieldStatus],
		pax.[FieldLoc],
		pax.[FieldCuroper],
		pax.[FieldReason],
		pax.[FieldLaststatustime]
	FROM [sie].[PIT_AUXEQMT_C] pax WITH (NOLOCK)
	WHERE pax.[FieldUnit] <> 246
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
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] [shift] WITH (NOLOCK)
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
	LEFT JOIN [sie].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].Id
) [se]
on [se].SHIFTINDEX = [shift].ShiftIndex
WHERE [se].[StatusName] = 'Ready'
AND [se].[StatusStart] < DATEADD(MINUTE,51,[shift].SHIFTSTARTDATETIME)



