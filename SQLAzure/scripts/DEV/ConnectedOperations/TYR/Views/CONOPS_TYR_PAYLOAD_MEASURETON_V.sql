CREATE VIEW [TYR].[CONOPS_TYR_PAYLOAD_MEASURETON_V] AS

--select * from [TYR].[CONOPS_TYR_PAYLOAD_MEASURETON_V]
CREATE VIEW [TYR].[CONOPS_TYR_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	sl.FieldLSizeTons AS PayloadTarget
FROM TYR.shift_load_detail_v sl
WHERE sl.PayloadFilter = 1

