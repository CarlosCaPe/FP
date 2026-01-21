CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_LINEUP_EQMT_OTHER_V] AS





-- SELECT * FROM [abr].[CONOPS_ABR_DAILY_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_LINEUP_EQMT_OTHER_V]
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
			WHEN [pax].[FieldUnit] = 199 THEN 'Bulldozer'
			WHEN [pax].[FieldUnit] = 201 THEN 'Motoniveladora'
			WHEN [pax].[FieldUnit] = 200 THEN 'Pato'
			--WHEN [pax].[FieldUnit] = 276 THEN 'Motor Grader'
			--WHEN [pax].[FieldUnit] = 277 THEN 'Rubber Tire Dozer'
		END AS SupportEquipment,
		[enumStats].Idx AS [StatusCode],
		[enumStats].Description AS [StatusName],
		DATEADD(HH,current_utc_offset,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01')) AS [StatusStart]
	FROM [ABR].[pit_auxeqmt_c] [pax] WITH (NOLOCK)
	LEFT JOIN [ABR].[pit_excav_c] [s] WITH (NOLOCK)
		ON [pax].fieldexcav = [s].Id AND [pax].SHIFTINDEX = [s].SHIFTINDEX
	LEFT JOIN [ABR].[enum] [enumStats] WITH (NOLOCK)
		ON [pax].FieldStatus = [enumStats].Id
	LEFT JOIN [ABR].[CONOPS_ABR_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)
		ON [pax].SHIFTINDEX = [shift].ShiftIndex
	WHERE [pax].FieldUnit IN (199, 201, 200)
) [se]
WHERE [se].[StatusName] = 'Operativo'
AND [se].[StatusStart] < DATEADD(MINUTE,51,[se].shiftstartdatetime)




