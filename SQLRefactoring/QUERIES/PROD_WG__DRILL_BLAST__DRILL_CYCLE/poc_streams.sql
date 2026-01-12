-- POC: Change capture using Snowflake Streams + Tasks
-- Source: PROD_WG.DRILL_BLAST.DRILL_CYCLE
--
-- Objective:
-- - Replace truncate+load-every-5-min with incremental processing.
-- - Capture INSERT/UPDATE/DELETE changes and apply them downstream.
--
-- IMPORTANT:
-- 1) Verify whether the source object is a TABLE or a VIEW:
--    SHOW TABLES LIKE 'DRILL_CYCLE' IN SCHEMA PROD_WG.DRILL_BLAST;
--    SHOW VIEWS  LIKE 'DRILL_CYCLE' IN SCHEMA PROD_WG.DRILL_BLAST;
-- 2) Streams are most straightforward on TABLES.
--    If DRILL_CYCLE is a VIEW and stream-on-view is not supported/eligible,
--    create the stream on the underlying base table(s) instead.
--
-- Choose a DEV/SANDBOX database/schema for POC objects:
--   e.g. SANDBOX_DATA_ENGINEER.<you>.CDC_POC

-- ---------------------------------------------------------------------
-- 0) Set context (edit these)
-- ---------------------------------------------------------------------
-- USE ROLE <ROLE_WITH_PRIVS>;
-- USE WAREHOUSE <DEV_WAREHOUSE>;
-- USE DATABASE SANDBOX_DATA_ENGINEER;
-- USE SCHEMA <YOUR_SCHEMA>;

-- ---------------------------------------------------------------------
-- 1) Create a STREAM on the source
-- ---------------------------------------------------------------------
-- DRILL_CYCLE is a VIEW (pulled via GET_DDL). Try a stream on the view first.
-- If your Snowflake account/edition does not allow streams on this view, stream the base table(s)
-- (the DDL comments indicate: PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_C).
CREATE OR REPLACE STREAM CDC__DRILL_CYCLE__STRM
  ON VIEW PROD_WG.DRILL_BLAST.DRILL_CYCLE
  SHOW_INITIAL_ROWS = FALSE;

-- ---------------------------------------------------------------------
-- 2) Create a target table in DEV to hold the "current state"
-- ---------------------------------------------------------------------
-- NOTE: for a true MERGE we need a stable primary key.
-- The DRILL_CYCLE DDL comment documents the logical PK as:
--   (ORIG_SRC_ID, SITE_CODE, DRILL_HOLE_SHIFT_ID, SYSTEM_VERSION, DRILL_ID, DRILL_HOLE_ID)
--
-- Quick way to clone structure (no data):
CREATE OR REPLACE TABLE CDC__DRILL_CYCLE__CURRENT AS
SELECT *
FROM PROD_WG.DRILL_BLAST.DRILL_CYCLE
WHERE 1 = 0;

-- Optional: add metadata columns (kept separate to avoid impacting downstream consumers)
ALTER TABLE CDC__DRILL_CYCLE__CURRENT ADD COLUMN IF NOT EXISTS CDC_LAST_APPLIED_TS TIMESTAMP_NTZ;

-- ---------------------------------------------------------------------
-- 3) Create an append-only change log (recommended for downstream sync)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE CDC__DRILL_CYCLE__CHANGELOG AS
SELECT
  CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS load_ts,
  METADATA$ACTION::STRING          AS cdc_action,   -- INSERT/DELETE (updates appear as DELETE+INSERT)
  METADATA$ISUPDATE::BOOLEAN       AS cdc_isupdate,
  METADATA$ROW_ID::STRING          AS cdc_row_id,
  t.*
FROM CDC__DRILL_CYCLE__STRM t
WHERE 1 = 0;

-- ---------------------------------------------------------------------
-- 4) Apply changes: (a) write to changelog, (b) MERGE into current-state
-- ---------------------------------------------------------------------
-- 4a) Insert raw changes into changelog (cheap, auditable)
INSERT INTO CDC__DRILL_CYCLE__CHANGELOG
SELECT
  CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS load_ts,
  METADATA$ACTION::STRING          AS cdc_action,
  METADATA$ISUPDATE::BOOLEAN       AS cdc_isupdate,
  METADATA$ROW_ID::STRING          AS cdc_row_id,
  t.*
FROM CDC__DRILL_CYCLE__STRM t;

-- 4b) MERGE into current-state table
-- Join condition uses the logical composite PK documented in the view DDL.
--
-- IMPORTANT: In streams, an UPDATE typically surfaces as:
--   (1) DELETE row (METADATA$ACTION='DELETE', METADATA$ISUPDATE=TRUE)
--   (2) INSERT row (METADATA$ACTION='INSERT', METADATA$ISUPDATE=TRUE)
-- We apply deletes first, then upserts.

-- Delete pass
DELETE FROM CDC__DRILL_CYCLE__CURRENT tgt
USING CDC__DRILL_CYCLE__STRM src
WHERE src.METADATA$ACTION = 'DELETE'
  AND tgt.ORIG_SRC_ID = src.ORIG_SRC_ID
  AND tgt.SITE_CODE = src.SITE_CODE
  AND tgt.DRILL_HOLE_SHIFT_ID = src.DRILL_HOLE_SHIFT_ID
  AND tgt.SYSTEM_VERSION = src.SYSTEM_VERSION
  AND tgt.DRILL_ID = src.DRILL_ID
  AND tgt.DRILL_HOLE_ID = src.DRILL_HOLE_ID;

-- Upsert pass
MERGE INTO CDC__DRILL_CYCLE__CURRENT tgt
USING (
  SELECT *
  FROM CDC__DRILL_CYCLE__STRM
  WHERE METADATA$ACTION = 'INSERT'
) src
ON tgt.ORIG_SRC_ID = src.ORIG_SRC_ID
AND tgt.SITE_CODE = src.SITE_CODE
AND tgt.DRILL_HOLE_SHIFT_ID = src.DRILL_HOLE_SHIFT_ID
AND tgt.SYSTEM_VERSION = src.SYSTEM_VERSION
AND tgt.DRILL_ID = src.DRILL_ID
AND tgt.DRILL_HOLE_ID = src.DRILL_HOLE_ID
WHEN MATCHED THEN UPDATE SET
  -- NOTE: you must enumerate columns here; keeping as a placeholder for POC.
  -- col1 = src.col1,
  -- col2 = src.col2,
  CDC_LAST_APPLIED_TS = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
  -- col1,
  -- col2,
  CDC_LAST_APPLIED_TS
) VALUES (
  -- src.col1,
  -- src.col2,
  CURRENT_TIMESTAMP()::TIMESTAMP_NTZ
);

-- ---------------------------------------------------------------------
-- 5) Automate every 5 minutes with a TASK
-- ---------------------------------------------------------------------
-- NOTE: put the DML above into a stored procedure or a multi-statement task body.
-- This is a minimal example using a stored procedure stub.

-- CREATE OR REPLACE PROCEDURE CDC__APPLY_DRILL_CYCLE()
-- RETURNS STRING
-- LANGUAGE SQL
-- AS
-- $$
--   -- (1) insert into changelog
--   -- (2) delete pass
--   -- (3) merge pass
--   -- return status
-- $$;

-- CREATE OR REPLACE TASK CDC__DRILL_CYCLE__APPLY_TASK
--   WAREHOUSE = <DEV_WAREHOUSE>
--   SCHEDULE = '5 MINUTE'
-- AS
--   CALL CDC__APPLY_DRILL_CYCLE();

-- ALTER TASK CDC__DRILL_CYCLE__APPLY_TASK RESUME;

-- ---------------------------------------------------------------------
-- 6) Downstream to SQL Server
-- ---------------------------------------------------------------------
-- For the POC, the easiest handoff is usually:
-- - Pull from CDC__DRILL_CYCLE__CHANGELOG incrementally (WHERE load_ts > last_checkpoint)
-- - Apply in SQL Server (MERGE) keyed by your PK
--
-- This keeps Snowflake-side work minimal and avoids re-reading the entire source every 5 minutes.
