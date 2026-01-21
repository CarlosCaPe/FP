CREATE VIEW [CER].[CONOPS_CER_PAYLOAD_MEASURETON_V] AS

--select * from [CER].[CONOPS_CER_PAYLOAD_MEASURETON_V]
CREATE VIEW [CER].[CONOPS_CER_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	sl.FieldLSizeTons AS PayloadTarget
FROM CER.shift_load_detail_v sl
WHERE sl.PayloadFilter = 1

