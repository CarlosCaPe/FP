CREATE VIEW [saf].[CONOPS_SAF_PAYLOAD_MEASURETON_V] AS

--select * from [SAF].[CONOPS_SAF_PAYLOAD_MEASURETON_V]
CREATE VIEW [SAF].[CONOPS_SAF_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	sl.FieldLSizeTons AS PayloadTarget
FROM SAF.shift_load_detail_v sl
WHERE sl.PayloadFilter = 1

