# Findings — PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL

Generated (UTC): 2026-01-03T20:52:22.747639+00:00
Last updated (UTC): 2026-01-03T20:52:22.751649+00:00

## Executive summary
- Runtime: 14.216s vs 48.280s (34.064s (0.57 min) faster, 70.6% faster)
- Bytes scanned: 7.24 GB vs 52.49 GB (+86.2% change)

## Time improvement (plain English)
- Baseline: 48.280s (0.80 min)
- Refactor: 14.216s (0.24 min)
- Change: 34.064s (0.57 min) faster
- Percent: 70.6% faster
- Speedup factor: 3.40x

## What changed (technical)
- Refactor organized as layered CTEs: `src_*` → `int_*` → `agg_*` → `final_*`.
- No intended semantic change: output columns and meaning must remain identical (validated by regression).

## Why it should be faster
- Clear separation of concerns reduces accidental recomputation and makes future optimizations safer.
- Centralized parameter handling prevents repeated expressions and makes pruning opportunities easier to spot.

## Performance signals (Snowflake query history)
Baseline:
- QUERY_ID: 01c17de3-0307-9106-0000-6406f6c96f0f
- EXECUTION_TIME(ms): 30815
- BYTES_SCANNED: 52.49 GB

Refactor:
- QUERY_ID: 01c17de4-0307-8f9b-0000-6406f6c98fa3
- EXECUTION_TIME(ms): 5244
- BYTES_SCANNED: 7.24 GB

## EXPLAIN
- Use these files to review pruning, join order, and scan patterns:
  - Baseline: analyze__PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL__20260103_205120__baseline_explain.txt
  - Refactor: analyze__PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL__20260103_205120__refactor_explain.txt

## Regression status
- Expected: same DDL (normalized) and same result set (rowcount/columns/checksum).
- Run: `python -m snowrefactor regress-view <baseline_fqn> <sandbox_fqn> --threads 2`

## PM notes
<!-- USER_NOTES_START -->
- (Add PM-facing notes here: impact, timeline, stakeholders)
<!-- USER_NOTES_END -->

## Next steps
- If regression passes, deploy the refactor to production via the owning team’s change process.
- If regression fails, inspect checksum/columns deltas and review the `final` projection.
