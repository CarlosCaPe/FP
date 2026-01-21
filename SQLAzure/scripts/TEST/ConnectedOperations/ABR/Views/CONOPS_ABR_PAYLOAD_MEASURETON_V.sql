CREATE VIEW [ABR].[CONOPS_ABR_PAYLOAD_MEASURETON_V] AS

--select * from [ABR].[CONOPS_ABR_PAYLOAD_MEASURETON_V]
CREATE VIEW [ABR].[CONOPS_ABR_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	sl.FieldLSizeTons AS PayloadTarget
FROM ABR.shift_load_detail_v sl
WHERE sl.PayloadFilter = 1

