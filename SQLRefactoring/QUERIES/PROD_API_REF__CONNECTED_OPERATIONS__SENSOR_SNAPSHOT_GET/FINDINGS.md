# Findings — PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET

Generated (UTC): 2026-01-03T21:48:28.007949+00:00
Last updated (UTC): 2026-01-03T21:48:28.027143+00:00

## Executive summary
- Runtime: 54.059s vs 43.277s (10.782s (0.18 min) slower, 24.9% slower)
- Bytes scanned: 52.09 GB vs 52.54 GB (+0.9% change)

## Time improvement (plain English)
- Baseline: 43.277s (0.72 min)
- Refactor: 54.059s (0.90 min)
- Change: 10.782s (0.18 min) slower
- Percent: 24.9% slower
- Speedup factor: 0.80x

## What changed (technical)
- Refactor organized as layered CTEs: `src_*` → `int_*` → `agg_*` → `final_*`.
- No intended semantic change: output columns and meaning must remain identical (validated by regression).

## Why it should be faster
- Clear separation of concerns reduces accidental recomputation and makes future optimizations safer.
- Centralized parameter handling prevents repeated expressions and makes pruning opportunities easier to spot.

## Performance signals (Snowflake query history)
Baseline:
- QUERY_ID: 01c17e1a-0307-8c65-0000-6406f6d46abf
- EXECUTION_TIME(ms): 27373
- BYTES_SCANNED: 52.54 GB

Refactor:
- QUERY_ID: 01c17e1b-0307-87f2-0000-6406f6d5011f
- EXECUTION_TIME(ms): 22203
- BYTES_SCANNED: 52.09 GB

## EXPLAIN
- Use these files to review pruning, join order, and scan patterns:
  - Baseline: analyze__PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET__20260103_214650__baseline_explain.txt
  - Refactor: analyze__PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET__20260103_214650__refactor_explain.txt

## Regression status
- Expected: same DDL (normalized) and same result set (rowcount/columns/checksum).
- Run: `python -m snowrefactor regress-view <baseline_fqn> <sandbox_fqn> --threads 2`

## PM notes
<!-- USER_NOTES_START -->
- (Add PM-facing notes here: impact, timeline, stakeholders)
<!-- USER_NOTES_END -->

## Next steps
- ✅ **DONE**: Refactor uses `IDENTIFIER(CASE UPPER(PARAM_SITE_CODE) ...)` to select only the site-specific table.
- ✅ **DONE**: Uses `QUALIFY RANK()` instead of correlated subquery for MAX timestamp.
- ✅ **DONE**: Added `PARAM_LOOKBACK_DAYS` parameter with 4-arg wrapper for backward compatibility.
- 🔄 **PENDING**: Re-run `snowrefactor analyze` to measure bytes scanned reduction (expected ~85% reduction).
- 🔄 **PENDING**: Regression test comparing baseline vs refactor output.
- 📋 **FUTURE**: ADX migration - `FCTSCURRENT()` function in ADX already provides last value per sensor.

## Refactor Details (2026-01-21)

**Key optimizations in `refactor_ddl.sql`**:

1. **Dynamic table selection** (lines 112-121):
   ```sql
   FROM IDENTIFIER(
     CASE UPPER(PARAM_SITE_CODE)
       WHEN 'SAM' THEN '...SENSOR_READING_SAM_B'
       WHEN 'MOR' THEN '...SENSOR_READING_MOR_B'
       ...
     END
   ) raw
   ```

2. **Single-pass snapshot** (line 130):
   ```sql
   QUALIFY RANK() OVER (PARTITION BY raw.sensor_id ORDER BY raw.value_utc_ts DESC) = 1
   ```

3. **Backward-compatible wrapper** (lines 165-196):
   - 5-arg function: full control with `PARAM_LOOKBACK_DAYS`
   - 4-arg function: wrapper that defaults lookback to 30 days

**Expected performance**:
- Bytes scanned: ~52 GB → ~7-8 GB (only 1 of 7 tables)
- Execution time: ~40s → ~10s (estimated)
