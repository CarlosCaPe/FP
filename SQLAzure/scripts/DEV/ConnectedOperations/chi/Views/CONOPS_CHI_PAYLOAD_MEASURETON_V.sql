CREATE VIEW [chi].[CONOPS_CHI_PAYLOAD_MEASURETON_V] AS

--select * from [CHI].[CONOPS_CHI_PAYLOAD_MEASURETON_V]
CREATE VIEW [CHI].[CONOPS_CHI_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	sl.FieldLSizeTons AS PayloadTarget
FROM CHI.shift_load_detail_v sl
WHERE sl.PayloadFilter = 1

