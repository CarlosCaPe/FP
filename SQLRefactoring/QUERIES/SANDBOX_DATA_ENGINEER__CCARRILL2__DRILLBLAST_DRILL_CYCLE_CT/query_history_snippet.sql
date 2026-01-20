-- Use this to pull proof (timing + scan metrics) for one procedure run.
--
-- Option A (recommended): paste the exact QUERY_IDs returned by the procedure output.
-- Option B: search by the embedded SQL comment tag (slower / may require higher retention).

-- =============================================
-- A) By QUERY_ID (best / exact)
-- =============================================

-- Replace with the IDs printed by DRILLBLAST_DRILL_CYCLE_CT_P_REF output:
WITH qids AS (
  SELECT column1::string AS query_id
  FROM VALUES
    ('01c1bc81-0307-9a3e-0000-640702b2def3'), -- delete_old
    ('01c1bc81-0307-9a3e-0000-640702b2defb'), -- merge
    ('01c1bc81-0307-9a3e-0000-640702b2df0b')  -- archive
)
SELECT
  q.query_id,
  q.query_text,
  q.execution_status,
  q.start_time,
  q.end_time,
  q.total_elapsed_time/1000.0 AS elapsed_seconds,
  q.rows_produced,
  q.bytes_scanned,
  q.partitions_scanned,
  q.partitions_total,
  q.warehouse_name,
  q.warehouse_size,
  q.warehouse_type,
  q.cluster_number,
  q.error_code,
  q.error_message
FROM snowflake.account_usage.query_history q
JOIN qids USING (query_id)
ORDER BY q.start_time;

-- =============================================
-- B) By embedded tag comment (fallback)
-- =============================================

-- Paste the tag from SP output:
-- Example: snowrefactor:DRILLBLAST_DRILL_CYCLE_CT_P_REF:days=5:ts=2026-01-15T00:01:32.139Z
--
-- Notes:
-- - This searches query text, so it’s best to keep the time window tight.
-- - ACCOUNT_USAGE is delayed; if you need immediate results, use INFORMATION_SCHEMA.QUERY_HISTORY()
--   (permissions-dependent).

-- set tag = 'snowrefactor:DRILLBLAST_DRILL_CYCLE_CT_P_REF:days=5:ts=2026-01-15T00:01:32.139Z';
--
-- SELECT
--   query_id,
--   query_text,
--   start_time,
--   end_time,
--   total_elapsed_time/1000.0 AS elapsed_seconds,
--   bytes_scanned,
--   partitions_scanned,
--   partitions_total,
--   warehouse_name
-- FROM snowflake.account_usage.query_history
-- WHERE start_time >= DATEADD('hour', -6, CURRENT_TIMESTAMP())
--   AND query_text ILIKE '%' || $tag || '%'
-- ORDER BY start_time;
