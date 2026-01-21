CREATE VIEW [MOR].[CONOPS_MOR_OVERALL_AVG_PAYLOAD_V] AS


--select * from [mor].[CONOPS_MOR_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [mor].[CONOPS_MOR_OVERALL_AVG_PAYLOAD_V] 
AS

SELECT
	si.shiftflag,
	si.[siteflag],
	COALESCE([AVG_Payload], 0) [AVG_Payload],
	tgt.[PayloadTarget] [Target]
FROM mor.CONOPS_MOR_SHIFT_INFO_V si
LEFT JOIN (
	SELECT
		sl.SiteFlag,
		ShiftId,
		ShiftIndex,
		AVG(FieldTons) AS AVG_Payload
	FROM mor.shift_load_detail_v sl
	GROUP BY
		sl.SiteFlag,
		ShiftId,
		ShiftIndex
) p
	ON si.shiftid = p.shiftid
LEFT JOIN dbo.PAYLOAD_TARGET tgt WITH(NOLOCK)
	ON si.siteflag = tgt.siteflag



