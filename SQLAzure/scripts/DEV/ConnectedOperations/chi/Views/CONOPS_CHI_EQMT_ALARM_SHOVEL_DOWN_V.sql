CREATE VIEW [chi].[CONOPS_CHI_EQMT_ALARM_SHOVEL_DOWN_V] AS


-- SELECT * FROM [chi].[CONOPS_CHI_EQMT_ALARM_SHOVEL_DOWN_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [chi].[CONOPS_CHI_EQMT_ALARM_SHOVEL_DOWN_V]
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
				ELSE concat('https://images.services.fmi.com/publishedimages/',
			 				RIGHT('0000000000' + [s].FieldCuroper, 10),'.jpg') END as OperatorImageURL,
		   COALESCE([w].FieldName, 'NONE') AS OperatorName
	FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a (NOLOCK)
	LEFT JOIN [chi].[asset_efficiency] [ae] (NOLOCK)
	ON [a].SHIFTID = [ae].shiftid
	LEFT JOIN [chi].[PIT_EXCAV_C] [s] (NOLOCK)
	ON [s].FieldId = [ae].eqmt and [s].SHIFTID = [ae].shiftid
	LEFT JOIN [chi].[PIT_WORKER_C] [w] (NOLOCK)
	ON [w].FieldId = [s].FieldCuroper and [w].SHIFTID = [s].SHIFTID
	WHERE UnitType = 'Shovel'
		  AND StatusIdx = 1
		  AND CategoryIdx = 4

