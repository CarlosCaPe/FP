CREATE VIEW [sie].[CONOPS_SIE_OVERALL_AVG_PAYLOAD_V] AS

--select * from [saf].[CONOPS_SAF_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [sie].[CONOPS_SIE_OVERALL_AVG_PAYLOAD_V] 
AS

SELECT
	si.ShiftFlag,
	sl.SiteFlag,
	AVG(sl.FieldTons) AS AVG_Payload,
	AVG(sl.FieldLSizeTons) AS [Target]
FROM SIE.CONOPS_SIE_SHIFT_INFO_V si
LEFT JOIN SIE.shift_load_detail_v sl
	ON si.shiftid = sl.shiftid
WHERE sl.PayloadFilter = 1
GROUP BY 
	si.ShiftFlag,
	sl.SiteFlag

