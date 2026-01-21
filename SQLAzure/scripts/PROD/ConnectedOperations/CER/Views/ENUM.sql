CREATE VIEW [CER].[ENUM] AS


--SELECT * FROM CER.ENUM
CREATE VIEW CER.ENUM
AS

SELECT
	'CER' AS SITEFLAG,
	Id AS enum_id,
	EnumTypeId,
	Idx,
	Description,
	Abbreviation,
	Flags,
	'N' AS logical_delete_flag,
	140 AS orig_src_id,
	'CER' AS site_code,
	GETUTCDATE() AS capture_ts_utc,
	GETUTCDATE() AS integrate_ts_utc
FROM CVEOperational.dbo.enum WITH(NOLOCK)


