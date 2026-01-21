CREATE VIEW [TYR].[CONOPS_TYR_EQMT_ALARM_SHOVEL_DOWN_V] AS


-- SELECT * FROM [tyr].[CONOPS_TYR_EQMT_ALARM_SHOVEL_DOWN_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [TYR].[CONOPS_TYR_EQMT_ALARM_SHOVEL_DOWN_V]
AS

	SELECT [a].SHIFTFLAG,
		   [a].siteflag,
		   'SHOVEL DOWN' AS [AlertType],
		   CONCAT('SHOVEL DOWN - ', reasonidx) AS [AlertName],
		   eqmt AS EQUIPMENTNUMBER,
		   EndDateTime AS END_TIME_TS,
		   CONVERT(varchar, DATEADD(ss, Duration, 0), 108) AS STATUS_DURATION,
		   [s].FieldCuroper AS OPERATORID,
		   CASE WHEN [s].FieldCuroper IS NULL OR [s].FieldCuroper = -1 THEN NULL
				ELSE concat([img].[value],
			 				RIGHT('0000000000' + [s].FieldCuroper, 10),'.jpg') END as OperatorImageURL,
		   COALESCE([w].FieldName, 'NONE') AS OperatorName
	FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a (NOLOCK)
	LEFT JOIN [tyr].[asset_efficiency] [ae] (NOLOCK)
	ON [a].SHIFTID = [ae].shiftid
	LEFT JOIN [tyr].[PIT_EXCAV_C] [s] (NOLOCK)
	ON [s].FieldId = [ae].eqmt and [s].SHIFTID = [ae].shiftid
	LEFT JOIN [tyr].[PIT_WORKER_C] [w] (NOLOCK)
	ON [w].FieldId = [s].FieldCuroper and [w].SHIFTID = [s].SHIFTID
	LEFT JOIN [dbo].[LOOKUPS] img WITH (NOLOCK)
	ON [img].[TableCode] = 'IMGURL'
	WHERE UnitType = 'Shovel'
		  AND StatusIdx = 1
		  AND CategoryIdx = 4


