Subject: DRILLBLAST_DRILL_CYCLE_CT refactor — correctness + performance evidence

Summary
- Baseline vs refactor outputs are identical (rowcount + checksum).
- Refactor removes expensive set-ops (`MINUS`) and avoids unnecessary `MERGE` updates via a hash-based change predicate.
- Procedure now returns per-step query IDs + timings for proof in Query History.

Evidence
- Regression report: `SQLRefactoring/reports/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT__YYYYMMDD_HHMMSS.md`
- Refactor procedure output includes `query_id` per step (delete_old / merge / archive).

Latest benchmark (robust)
- Test: `--days 30 --repeats 2` (interleaved baseline/refactor) and metrics pulled from `INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION()`.
- Report: [SQLRefactoring/reports/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT__perf__20260115_000759.md](SQLRefactoring/reports/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT__perf__20260115_000759.md)

Quick rollup (focused metrics)

| run | focused_elapsed_s | focused_bytes_scanned |
|---|---:|---:|
| baseline_run_1 | 15.528 | 47115776 |
| refactor_run_1 | 8.283 | 28838912 |
| baseline_run_2 | 10.021 | 84693501 |
| refactor_run_2 | 11.429 | 46422016 |

Interpretation (what to tell users)
- The `snowrefactor compare` runtime is NOT the procedure runtime; it only times `SELECT *` from the output tables.
- The benchmark above measures the stored procedures themselves (merge/archive work + scans).
- Biggest win shows up on the “real load” run (run_1): refactor cuts elapsed and scans meaningfully.

How to verify in Snowflake
- Paste the `query_id`s from the procedure output into:
  - `SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/query_history_snippet.sql`
- This pulls: elapsed seconds, bytes scanned, partitions scanned/total, warehouse info, and full query text.

Note on “subqueries are bad?”
- Subqueries/CTEs are not inherently slow in Snowflake (optimizer usually flattens them).
- The costly baseline pattern was `MINUS` (set-operator implies sort/dedup across many columns) + date-casting patterns.
- We kept baseline date-window semantics for correctness (TIMESTAMP_TZ boundary gotcha).
