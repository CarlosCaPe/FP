# PROD_WG.DRILL_BLAST.DRILL_CYCLE — CDC/Delta POC (SQL-only)

Goal: stop doing truncate+reload every 5 minutes, and instead pull only changes (inserts/updates/deletes) from Snowflake and apply them downstream (SQL Server MERGE).

Audience: BI developers / SQL users. This runbook is 100% SQL.

## Part 1 — Prove what is blocked (CDC on the view output)

### 1) Confirm what `PROD_WG.DRILL_BLAST.DRILL_CYCLE` is

```sql
SHOW VIEWS LIKE 'DRILL_CYCLE' IN SCHEMA PROD_WG.DRILL_BLAST;
SHOW TABLES LIKE 'DRILL_CYCLE' IN SCHEMA PROD_WG.DRILL_BLAST;
```

### 2) Identify the Dynamic Table dependency (why the view can’t be streamed)

This query is the simplest “show me what the view depends on” using Snowflake account usage.

```sql
SELECT
	REFERENCING_DATABASE,
	REFERENCING_SCHEMA,
	REFERENCING_OBJECT_NAME,
	REFERENCING_OBJECT_DOMAIN,
	REFERENCED_DATABASE,
	REFERENCED_SCHEMA,
	REFERENCED_OBJECT_NAME,
	REFERENCED_OBJECT_DOMAIN
FROM SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
WHERE 1=1
	AND REFERENCING_DATABASE = 'PROD_WG'
	AND REFERENCING_SCHEMA = 'DRILL_BLAST'
	AND REFERENCING_OBJECT_NAME = 'DRILL_CYCLE'
ORDER BY REFERENCED_OBJECT_DOMAIN, REFERENCED_DATABASE, REFERENCED_SCHEMA, REFERENCED_OBJECT_NAME;
```

In our case, the chain includes:
- `PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_V` (VIEW)
- `PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_DT` (DYNAMIC TABLE)

### 3) Show the Dynamic Table refresh mode and the exact reason

```sql
SHOW DYNAMIC TABLES LIKE 'DRILLBLAST_DRILL_CYCLE_DT' IN SCHEMA PROD_TARGET.COLLECTIONS;
```

Look at:
- `refresh_mode`
- `refresh_mode_reason`

In our current state:
- `refresh_mode = FULL`
- `refresh_mode_reason` indicates upstream inputs are FULL refresh without `IMMUTABLE WHERE`.

### 4) Attempt a stream on the view (expected failure with this dependency)

This is what we *wanted* (CDC on view output):

```sql
CREATE OR REPLACE VIEW <SANDBOX_DB>.<SANDBOX_SCHEMA>.DRILL_CYCLE_CDC_V AS
SELECT *
FROM PROD_WG.DRILL_BLAST.DRILL_CYCLE;

CREATE OR REPLACE STREAM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__STRM
	ON VIEW <SANDBOX_DB>.<SANDBOX_SCHEMA>.DRILL_CYCLE_CDC_V
	SHOW_INITIAL_ROWS = FALSE;
```

With the current upstream DT forced into FULL refresh, this fails due to change tracking limitations.

## Part 2 — Working POC (send only deltas to SQL Server)

Even though CDC on the view output is blocked, we can still deliver “only changes” by capturing deltas from the stable base table referenced by the view.

Base table:
`PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_C`

### 1) Stream on the base table

```sql
CREATE OR REPLACE STREAM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__STRM
	ON TABLE PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_C
	SHOW_INITIAL_ROWS = FALSE;
```

### 2) Append-only changelog table

```sql
CREATE OR REPLACE TABLE <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__CHANGELOG AS
SELECT
	CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS LOAD_TS,
	METADATA$ACTION::STRING          AS CDC_ACTION,
	METADATA$ISUPDATE::BOOLEAN       AS CDC_ISUPDATE,
	METADATA$ROW_ID::STRING          AS CDC_ROW_ID,
	t.*
FROM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__STRM t
WHERE 1 = 0;
```

### 3) Task every 5 minutes to consume the stream

```sql
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

### 4) Consumer contract view for SQL Server

PK (from DT header comment):
`ORIG_SRC_ID, SITE_CODE, DRILL_HOLE_SHIFT_ID, SYSTEM_VERSION, DRILL_ID, DRILL_HOLE_ID`

```sql
CREATE OR REPLACE VIEW <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__CONSUMER_V AS
SELECT
	ORIG_SRC_ID,
	SITE_CODE,
	DRILL_HOLE_SHIFT_ID,
	SYSTEM_VERSION,
	DRILL_ID,
	DRILL_HOLE_ID,
	CDC_ACTION,
	CDC_ISUPDATE,
	LOAD_TS,
	* EXCLUDE (
			ORIG_SRC_ID,
			SITE_CODE,
			DRILL_HOLE_SHIFT_ID,
			SYSTEM_VERSION,
			DRILL_ID,
			DRILL_HOLE_ID,
			CDC_ACTION,
			CDC_ISUPDATE,
			LOAD_TS,
			CDC_ROW_ID
		)
FROM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__CHANGELOG;
```

### 5) Validate

```sql
SHOW STREAMS LIKE 'CDC__DRILL_CYCLE__STRM' IN SCHEMA <SANDBOX_DB>.<SANDBOX_SCHEMA>;
SELECT SYSTEM$STREAM_HAS_DATA('<SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__STRM');

SHOW TASKS LIKE 'CDC__DRILL_CYCLE__APPLY_TASK' IN SCHEMA <SANDBOX_DB>.<SANDBOX_SCHEMA>;

SELECT *
FROM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__CHANGELOG
ORDER BY LOAD_TS DESC
LIMIT 100;
```

### 6) SQL Server extraction pattern (watermark)

```sql
SELECT *
FROM <SANDBOX_DB>.<SANDBOX_SCHEMA>.CDC__DRILL_CYCLE__CONSUMER_V
WHERE LOAD_TS > :last_successful_load_ts
ORDER BY LOAD_TS;
```

## Part 3 — What would unblock CDC on the view output (future)

To enable CDC on the view output, the owning team would need to address upstream Dynamic Tables so the dependency chain is not forced into FULL refresh.

In practice, this usually means upstream DT inputs defining a valid immutable region:
`IMMUTABLE WHERE ( <expr> )`

This is an owning-team change and must be based on real business rules (the “immutable” region must truly never change).
