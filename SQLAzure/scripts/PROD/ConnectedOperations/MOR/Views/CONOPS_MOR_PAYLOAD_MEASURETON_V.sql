CREATE VIEW [MOR].[CONOPS_MOR_PAYLOAD_MEASURETON_V] AS

--select * from [mor].[CONOPS_MOR_PAYLOAD_MEASURETON_V]
CREATE VIEW [mor].[CONOPS_MOR_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	sl.FieldLSizeTons AS PayloadTarget
FROM mor.shift_load_detail_v sl
WHERE sl.PayloadFilter = 1

