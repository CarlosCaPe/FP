CREATE VIEW [mor].[CONOPS_MOR_DAILY_EOS_LINEUP_EQMT_OTHER_V] AS









-- SELECT * FROM [mor].[CONOPS_MOR_DAILY_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [mor].[CONOPS_MOR_DAILY_EOS_LINEUP_EQMT_OTHER_V]
AS

SELECT [se].shiftflag,
	   [se].[siteflag],
	   [se].shiftid,
	   [se].SHIFTINDEX,
	   [se].SupportEquipmentId,
	   [se].SupportEquipment,
	   [se].[StatusCode],
	   [se].[StatusName],
	   [se].[StatusStart]
FROM ( 
	SELECT 
		[shift].shiftflag,
		[pax].[siteflag],
		[shift].shiftid,
		[pax].SHIFTINDEX,
		[shift].shiftstartdatetime,
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
		DATEADD(HH,current_utc_offset,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01')) AS [StatusStart]
	FROM [mor].[pit_auxeqmt_c] [pax] WITH (NOLOCK)
	LEFT JOIN [mor].[pit_excav_c] [s] WITH (NOLOCK)
		ON [pax].fieldexcav = [s].Id AND [pax].SHIFTINDEX = [s].SHIFTINDEX
	LEFT JOIN [mor].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].Id
	LEFT JOIN [mor].[CONOPS_MOR_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)
		ON [pax].SHIFTINDEX = [shift].ShiftIndex
	WHERE [pax].FieldUnit IN (23, 280, 275, 276, 277)
) [se]
WHERE [se].[StatusName] = 'Ready'
AND [se].[StatusStart] < DATEADD(MINUTE,51,[se].shiftstartdatetime)



