CREATE VIEW [SIE].[CONOPS_SIE_PAYLOAD_MEASURETON_V] AS

--select * from [SIE].[CONOPS_SIE_PAYLOAD_MEASURETON_V]
CREATE VIEW [SIE].[CONOPS_SIE_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	sl.FieldLSizeTons AS PayloadTarget
FROM SIE.shift_load_detail_v sl
WHERE sl.PayloadFilter = 1

