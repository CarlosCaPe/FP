CREATE VIEW [ABR].[CONOPS_ABR_OVERALL_AVG_PAYLOAD_V] AS

--select * from [abr].[CONOPS_ABR_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [ABR].[CONOPS_ABR_OVERALL_AVG_PAYLOAD_V] 
AS

SELECT
	si.ShiftFlag,
	sl.SiteFlag,
	AVG(sl.FieldTons) AS AVG_Payload,
	AVG(sl.FieldLSizeTons) AS [Target]
FROM ABR.CONOPS_ABR_SHIFT_INFO_V si
LEFT JOIN ABR.shift_load_detail_v sl
	ON si.shiftid = sl.shiftid
WHERE sl.PayloadFilter = 1
GROUP BY 
	si.ShiftFlag,
	sl.SiteFlag

