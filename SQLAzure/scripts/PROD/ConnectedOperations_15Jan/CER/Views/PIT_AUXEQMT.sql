CREATE VIEW [CER].[PIT_AUXEQMT] AS



--SELECT * FROM CER.PIT_AUXEQMT
CREATE VIEW CER.PIT_AUXEQMT
AS

SELECT
'CER' AS siteflag,
*
,'N' AS logical_delete_flag
,140 AS orig_src_id
,'CER' AS site_code
,GETUTCDATE() AS capture_ts_utc
,GETUTCDATE() AS integrate_ts_utc
FROM CVEOperational.dbo.PITAuxeqmt WITH(NOLOCK)



