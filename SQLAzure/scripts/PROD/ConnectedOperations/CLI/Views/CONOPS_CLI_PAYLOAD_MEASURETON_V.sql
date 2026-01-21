CREATE VIEW [CLI].[CONOPS_CLI_PAYLOAD_MEASURETON_V] AS

--select * from [CLI].[CONOPS_CLI_PAYLOAD_MEASURETON_V]
CREATE VIEW [CLI].[CONOPS_CLI_PAYLOAD_MEASURETON_V]
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	sl.Excav,
	sl.Truck,
	sl.FieldTons AS Measureton,
	sl.FieldLSizeTons AS PayloadTarget
FROM CLI.shift_load_detail_v sl
WHERE sl.PayloadFilter = 1

