CREATE VIEW [CER].[PIT_WORKER] AS



--SELECT * FROM CER.PIT_WORKER
CREATE VIEW CER.PIT_WORKER
AS

SELECT
'CER' AS siteflag,
*
,'N' AS logical_delete_flag
,140 AS orig_src_id
,'CER' AS site_code
,GETUTCDATE() AS capture_ts_utc
,GETUTCDATE() AS integrate_ts_utc
FROM CVEOperational.dbo.PITWorker WITH(NOLOCK)



