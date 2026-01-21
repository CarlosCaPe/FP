CREATE VIEW [MOR].[CONOPS_MOR_OVERALL_AVG_PAYLOAD_V] AS

--select * from [mor].[CONOPS_MOR_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [mor].[CONOPS_MOR_OVERALL_AVG_PAYLOAD_V] 
AS

SELECT
	si.ShiftFlag,
	sl.SiteFlag,
	AVG(sl.FieldTons) AS AVG_Payload,
	AVG(sl.FieldLSizeTons) AS [Target]
FROM MOR.CONOPS_MOR_SHIFT_INFO_V si
LEFT JOIN MOR.shift_load_detail_v sl
	ON si.shiftid = sl.shiftid
WHERE sl.PayloadFilter = 1
GROUP BY 
	si.ShiftFlag,
	sl.SiteFlag

