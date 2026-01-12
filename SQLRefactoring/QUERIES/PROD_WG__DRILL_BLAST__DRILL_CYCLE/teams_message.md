Carrillo Pena, Carlos — I took a first look at `PROD_WG.DRILL_BLAST.DRILL_CYCLE` for the POC to stop truncate+reload every 5 minutes and only send changes to SQL Server.

## What I found (why CDC “on the view” is blocked)
`DRILL_CYCLE` is a view that depends on a Dynamic Table (`PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_DT`).

That Dynamic Table is currently running as FULL refresh, and Snowflake won’t allow change tracking / streams downstream of a view in this situation.

You can see the evidence in SQL:
```sql
SHOW DYNAMIC TABLES LIKE 'DRILLBLAST_DRILL_CYCLE_DT' IN SCHEMA PROD_TARGET.COLLECTIONS;
-- check refresh_mode + refresh_mode_reason
```

Observed output (key fields):
- `refresh_mode = FULL`
- `target_lag = 5 minutes`
- `warehouse = WH_BATCH_DE`
- `refresh_mode_reason = Input Dynamic Tables are FULL refresh without IMMUTABLE WHERE specified: [RCS_DRILL_CYCLE_DT, CAES_DRILL_CYCLE_DT]`

Current state:
- `refresh_mode = FULL`
- `refresh_mode_reason` indicates upstream inputs are FULL refresh without `IMMUTABLE WHERE`.

So: as long as those upstream DT inputs are FULL refresh (and don’t have a valid `IMMUTABLE WHERE`), enabling CDC directly on the view output isn’t supported.

## Two options going forward

### Option A (preferred if the requirement is “CDC on the view output”)
Ask the owning team to update the upstream Dynamic Tables so the chain is not forced into FULL refresh.

What they’d change (conceptually): define a valid immutable region on the upstream DT inputs using `IMMUTABLE WHERE ( <expr> )` so they can refresh incrementally.

What “IMMUTABLE” means here:
- `IMMUTABLE WHERE (<predicate>)` tells Snowflake that rows matching the predicate are in an “unchanging” region (no future updates/deletes).
- This must be based on real business rules (e.g., records older than X days and truly closed). If the data can still change, we should not mark it immutable.

Pros:
- Enables true CDC “on the view output” (stream on the view becomes possible).

Cons / risks:
- Requires owning-team changes + business confirmation of what is truly immutable.
- Not something we can safely do from our sandbox without ownership.

SQL evidence to share with the owner:
```sql
SHOW DYNAMIC TABLES LIKE 'DRILLBLAST_DRILL_CYCLE_DT' IN SCHEMA PROD_TARGET.COLLECTIONS;
-- refresh_mode_reason references missing IMMUTABLE WHERE on upstream inputs
```

### Option B (workaround that delivers deltas to SQL Server now)
Capture changes from the stable base table referenced by the view, then deliver those deltas to SQL Server.

Base table:
`PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_C`

Pros:
- Works now (no changes needed to PROD dynamic tables/views).
- Still eliminates truncate+reload by sending only deltas every 5 minutes.

Important (risk constraint):
- We are NOT altering the PROD base table. Creating a stream does not modify the table definition/data; the CDC objects (STREAM/TASK/CHANGELOG) live in our sandbox schema and require only `SELECT` on the PROD source.
- Any approach that requires `ALTER`/DDL changes on the PROD base table itself is considered high risk and is out of scope for this POC.

Cons:
- This is CDC on the base table, not strictly CDC on the final view output.
  If the view applies business logic (joins, filters, derived columns), SQL Server might need to replicate that logic, OR we expose a curated consumer contract from the changelog.

Limitation (important):
- If stakeholders require changes after the view logic, Option B may not be considered equivalent.
  It still solves the operational pain (no more truncate+reload), but it changes *where* the delta is captured (base table vs view output).

This is the recommended POC path while Option A is pending.

Minimal CDC pattern:
1) STREAM on the base table
2) TASK every 5 minutes consumes the stream into an append-only CHANGELOG
3) SQL Server reads only new rows since last watermark (`LOAD_TS`) and MERGEs

### Example SQL (sandbox)
```sql
-- 1) Stream on base table
CREATE OR REPLACE STREAM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__STRM
	ON TABLE PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_C
	SHOW_INITIAL_ROWS = FALSE;

-- 2) Changelog table
CREATE OR REPLACE TABLE <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__CHANGELOG AS
SELECT
	CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS LOAD_TS,
	METADATA$ACTION::STRING          AS CDC_ACTION,
	METADATA$ISUPDATE::BOOLEAN       AS CDC_ISUPDATE,
	METADATA$ROW_ID::STRING          AS CDC_ROW_ID,
	t.*
FROM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__STRM t
WHERE 1 = 0;

-- 3) Task (every 5 minutes)
CREATE OR REPLACE TASK <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__APPLY_TASK
	WAREHOUSE = "<WH>"
	SCHEDULE = '5 MINUTE'
AS
INSERT INTO <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__CHANGELOG
SELECT
	CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS LOAD_TS,
	METADATA$ACTION::STRING          AS CDC_ACTION,
	METADATA$ISUPDATE::BOOLEAN       AS CDC_ISUPDATE,
	METADATA$ROW_ID::STRING          AS CDC_ROW_ID,
	t.*
FROM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__STRM t;

ALTER TASK <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__APPLY_TASK RESUME;
```

SQL Server pull pattern:
```sql
SELECT *
FROM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__CHANGELOG
WHERE LOAD_TS > :last_successful_load_ts
ORDER BY LOAD_TS;
```

## Next steps / quick call
- Confirm whether we must propagate DELETEs to SQL Server (vs only inserts/updates).
- Confirm the business PK used for MERGE (the DT header suggests: `ORIG_SRC_ID, SITE_CODE, DRILL_HOLE_SHIFT_ID, SYSTEM_VERSION, DRILL_ID, DRILL_HOLE_ID`).
- If “CDC on the view output” is a hard requirement, we’ll need the owning team of the upstream Dynamic Tables to make them eligible (e.g., valid `IMMUTABLE WHERE` so they’re not forced into FULL refresh).
