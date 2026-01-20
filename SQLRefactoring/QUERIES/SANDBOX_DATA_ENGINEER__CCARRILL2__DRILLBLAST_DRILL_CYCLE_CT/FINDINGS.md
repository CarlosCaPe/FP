# Findings: DRILLBLAST_DRILL_CYCLE_CT

## SQL (baseline vs refactor)

1) Baseline: [SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/baseline.sql](SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/baseline.sql)
2) Refactor: [SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/refactor.sql](SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/refactor.sql)

## Overview (what was done)

This document summarizes a baseline-vs-refactor comparison for **DRILLBLAST_DRILL_CYCLE_CT**.

What we did:
- **SQL comparison**: compared the existing implementation (baseline) against a proposed alternative (refactor) that aims to produce the *same output* with better runtime characteristics.
- **Proposed SQL approach**: replaced the baseline “delta via set operator” pattern (e.g., `MINUS`) with a `MERGE`-driven upsert that matches on the business key and can optionally **update only when values changed**.
- **Performance testing across 30 days**: executed both versions across a 30-day sweep (days 1..30) and collected Snowflake Query History metrics. The full curve report includes day-by-day results and per-step breakdown.

How to interpret this refactor:
- The refactor is an **alternative candidate**: it is not assumed to be universally faster on every day, but it is designed to *often* perform better by reducing work (especially expensive wide-row set comparisons) and by minimizing unnecessary row rewrites.
- Correctness is treated as a guardrail first: date-window semantics are kept explicit to avoid timezone/casting boundary changes.

## DDL (baseline_ddl.sql vs refactor_ddl.sql)

1) Baseline DDL: [SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/baseline_ddl.sql](SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/baseline_ddl.sql)
2) Refactor DDL: [SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/refactor_ddl.sql](SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/refactor_ddl.sql)

### Size & LOC (measured locally)

| file | bytes | lines |
|---|---:|---:|
| baseline_ddl.sql | 26,675 | 731 |
| refactor_ddl.sql | 30,217 | 837 |

Diff stat (git no-index): `+298` insertions, `-186` deletions (net `+112` lines changed).

### Main DDL changes (what changed and why)

- **Target objects**: baseline creates `...DRILLBLAST_DRILL_CYCLE_CT_BASE` + SP `..._P_BASE`; refactor creates `...DRILLBLAST_DRILL_CYCLE_CT_REF` + SP `..._P_REF`.
- **Delta / upsert**: baseline builds the delta set using `MINUS` inside the `MERGE ... USING (...)`; refactor removes the set operator and lets `MERGE` do the matching directly on the business key.
- **“Update only if changed”**: refactor adds `WHEN MATCHED AND HASH(...) <> HASH(...) THEN UPDATE`, reducing unnecessary updates when rows are unchanged.
- **Retention (date-window)**: both use `START_HOLE_TS_LOCAL::DATE` to preserve date-window semantics; refactor centralizes the cutoff as `cutoff = DATEADD(day, -days, CURRENT_DATE)`.
- **Logical delete / archive step**: baseline contains an `UPDATE ... WHERE drill_cycle_sk IN ( )` placeholder (empty in the sandbox export); refactor implements an explicit `archive` step (anti-join / `NOT EXISTS`) scoped to the same window.
- **Observability / debugging**: refactor adds `snowrefactor_tag=... step=...` comments and captures `query_id`, `rows_affected`, and per-step timings (useful for Query History + perf triage).
- **Parameter robustness**: refactor clamps `NUMBER_OF_DAYS` to `[1..30]` and defaults to `5` if parsing fails.

## Findings (doc-backed)

### 1) Baseline relies on a set operator (`MINUS` / `EXCEPT`) for deltas

- Snowflake defines `MINUS` / `EXCEPT` as a **set operator** that returns the rows from the first query that aren’t returned by the second query.
- Doc: https://docs.snowflake.com/en/sql-reference/operators-query (section “Set operators”, “MINUS , EXCEPT”).

Why this matters for our workload:
- Using a set operator forces Snowflake to materialize/compare **two full intermediate result sets**.
- When the row is “wide” (many columns), the compare work tends to be expensive; our benchmarks show the delta step is a major contributor in baseline.

### 2) Refactor uses `MERGE` so matching happens on the PK, with optional conditional updates

- Snowflake’s `MERGE` statement is the canonical DML for “insert/update/delete based on a source”, and supports `WHEN MATCHED ... AND <case_predicate>`.
- Doc: https://docs.snowflake.com/en/sql-reference/sql/merge (see `matchedClause`, `WHEN MATCHED ... AND <case_predicate>`).

Why this matters for our workload:
- We can express “only update when changed” (via a predicate) to reduce unnecessary rewrites.
- The engine applies DML using micro-partition metadata (see next section).

### 3) Snowflake performance depends heavily on micro-partition pruning

- Snowflake stores per-micro-partition metadata (including value ranges) and uses it for **query pruning**.
- Snowflake notes that “not all predicate expressions can be used to prune”.
- Doc: https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions (section “Query Pruning”).

Why this matters for our workload:
- This job is fundamentally a rolling time-window process; predicates that map cleanly to a **range** on the time dimension tend to enable better pruning.

### 4) Correctness guardrail: keep date-window semantics explicit

`START_HOLE_TS_LOCAL` is `TIMESTAMP_TZ`. Changing from a date-based predicate (e.g. `...::DATE >= cutoff_date`) to a timestamp-based predicate (e.g. `... >= cutoff_date`) can change boundary semantics due to implicit casting/timezone.

For this refactor we kept the baseline date-window semantics aligned first, then optimize only with explicit, tested boundaries.

## Results (measured)

Performance evidence is based on Snowflake Query History metrics collected per run (days 1..30) and summarized here.

Summary:
- Refactor wins 28/30 days (baseline wins days 5 and 15).
- Average elapsed: baseline 10.829s vs refactor 8.359s.
- Median speedup: 1.297x (baseline/refactor).
- Best day: day 4 => baseline 17.460s vs refactor 6.272s (2.784x).
- Worst day: day 15 => baseline 9.120s vs refactor 11.244s (0.811x).

Winner by day (smaller elapsed wins):

| days | baseline_elapsed_s | refactor_elapsed_s | speedup (baseline/refactor) | winner |
|---:|---:|---:|---:|---|
| 1 | 5.360 | 4.818 | 1.112 | refactor |
| 2 | 5.261 | 4.391 | 1.198 | refactor |
| 3 | 8.725 | 8.664 | 1.007 | refactor |
| 4 | 17.460 | 6.272 | 2.784 | refactor |
| 5 | 7.768 | 8.650 | 0.898 | baseline |
| 6 | 10.824 | 7.836 | 1.381 | refactor |
| 7 | 9.280 | 8.668 | 1.071 | refactor |
| 8 | 10.792 | 8.950 | 1.206 | refactor |
| 9 | 8.649 | 7.613 | 1.136 | refactor |
| 10 | 9.559 | 6.997 | 1.366 | refactor |
| 11 | 10.156 | 7.283 | 1.394 | refactor |
| 12 | 9.989 | 9.153 | 1.091 | refactor |
| 13 | 11.927 | 9.803 | 1.217 | refactor |
| 14 | 9.988 | 8.662 | 1.153 | refactor |
| 15 | 9.120 | 11.244 | 0.811 | baseline |
| 16 | 12.360 | 9.577 | 1.291 | refactor |
| 17 | 13.923 | 10.359 | 1.344 | refactor |
| 18 | 11.702 | 8.168 | 1.433 | refactor |
| 19 | 11.907 | 8.857 | 1.344 | refactor |
| 20 | 11.096 | 8.960 | 1.238 | refactor |
| 21 | 10.802 | 7.809 | 1.383 | refactor |
| 22 | 9.350 | 7.408 | 1.262 | refactor |
| 23 | 11.671 | 7.930 | 1.472 | refactor |
| 24 | 11.122 | 9.092 | 1.223 | refactor |
| 25 | 13.477 | 10.343 | 1.303 | refactor |
| 26 | 11.677 | 8.168 | 1.430 | refactor |
| 27 | 12.779 | 8.922 | 1.432 | refactor |
| 28 | 13.520 | 10.290 | 1.314 | refactor |
| 29 | 13.782 | 7.574 | 1.820 | refactor |
| 30 | 10.857 | 8.300 | 1.308 | refactor |

Full report (including per-step breakdown):
- [SQLRefactoring/reports/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT__curve__20260115_002530.md](SQLRefactoring/reports/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT__curve__20260115_002530.md)
