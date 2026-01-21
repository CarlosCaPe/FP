CREATE VIEW [MOR].[CONOPS_MOR_PAYLOAD_MEASURETON_V] AS

--select * from [mor].[CONOPS_MOR_PAYLOAD_MEASURETON_V] where shiftflag = 'curr'
CREATE VIEW [mor].[CONOPS_MOR_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	tgt.PayloadTarget
FROM mor.shift_load_detail_v sl
LEFT JOIN dbo.PAYLOAD_TARGET tgt WITH(NOLOCK)
	ON sl.siteflag = tgt.siteflag

