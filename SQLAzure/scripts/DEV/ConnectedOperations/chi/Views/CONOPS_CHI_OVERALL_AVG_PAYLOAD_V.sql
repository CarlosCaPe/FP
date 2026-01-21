CREATE VIEW [chi].[CONOPS_CHI_OVERALL_AVG_PAYLOAD_V] AS

--select * from [chi].[CONOPS_CHI_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [chi].[CONOPS_CHI_OVERALL_AVG_PAYLOAD_V] 
AS

SELECT
	si.ShiftFlag,
	sl.SiteFlag,
	AVG(sl.FieldTons) AS AVG_Payload,
	AVG(sl.FieldLSizeTons) AS [Target]
FROM CHI.CONOPS_CHI_SHIFT_INFO_V si
LEFT JOIN CHI.shift_load_detail_v sl
	ON si.shiftid = sl.shiftid
WHERE sl.PayloadFilter = 1
GROUP BY 
	si.ShiftFlag,
	sl.SiteFlag

