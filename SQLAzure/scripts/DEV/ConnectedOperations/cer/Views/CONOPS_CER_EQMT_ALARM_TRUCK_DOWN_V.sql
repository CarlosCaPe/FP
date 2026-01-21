CREATE VIEW [cer].[CONOPS_CER_EQMT_ALARM_TRUCK_DOWN_V] AS

-- SELECT * FROM [cer].[CONOPS_CER_EQMT_ALARM_TRUCKL_DOWN_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [cer].[CONOPS_CER_EQMT_ALARM_TRUCK_DOWN_V]
AS

	SELECT [a].SHIFTFLAG,
		   [a].siteflag,
		   'TRUCK DOWN' AS [AlertType],
		   CONCAT('TRUCK DOWN - ', reasonidx) AS [AlertName],
		   eqmt AS EQUIPMENTNUMBER,
		   EndDateTime AS END_TIME_TS,
		   CONVERT(varchar, DATEADD(ss, Duration, 0), 108) AS STATUS_DURATION,
		   [s].FieldCuroper AS OPERATORID,
		   CASE WHEN [s].FieldCuroper IS NULL OR [s].FieldCuroper = -1 THEN NULL
				ELSE concat('https://images.services.fmi.com/publishedimages/',
			 				RIGHT('0000000000' + [s].FieldCuroper, 10),'.jpg') END as OperatorImageURL,
		   COALESCE([w].FieldName, 'NONE') AS OperatorName
	FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a (NOLOCK)
	LEFT JOIN [cer].[asset_efficiency] [ae] (NOLOCK)
	ON [a].SHIFTID = [ae].shiftid
	LEFT JOIN [cer].[PIT_EXCAV_C] [s] (NOLOCK)
	ON [s].FieldId = [ae].eqmt and [s].SHIFTID = [ae].shiftid
	LEFT JOIN [cer].[PIT_WORKER_C] [w] (NOLOCK)
	ON [w].FieldId = [s].FieldCuroper and [w].SHIFTID = [s].SHIFTID
	WHERE UnitType = 'Camion'
		  AND StatusIdx = 1
		  AND CategoryIdx = 4

