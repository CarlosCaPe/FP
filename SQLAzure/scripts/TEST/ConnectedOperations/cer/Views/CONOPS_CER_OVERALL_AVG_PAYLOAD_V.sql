CREATE VIEW [cer].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V] AS

--select * from [cer].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [cer].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V]
AS

SELECT
	si.ShiftFlag,
	sl.SiteFlag,
	AVG(sl.FieldTons) AS AVG_Payload,
	AVG(sl.FieldLSizeTons) AS [Target]
FROM CER.CONOPS_CER_SHIFT_INFO_V si
LEFT JOIN CER.shift_load_detail_v sl
	ON si.shiftid = sl.shiftid
WHERE sl.PayloadFilter = 1
GROUP BY 
	si.ShiftFlag,
	sl.SiteFlag

