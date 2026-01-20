# DRILLBLAST_DRILL_CYCLE_CT (baseline vs refactor)

This folder is a regression harness setup to refactor the **change tracking** load for Drillblast Drill Cycle.

## What’s here

- `baseline_ddl.sql`: creates sandbox **baseline** table + procedure (`*_BASE`).
- `refactor_ddl.sql`: creates sandbox **refactor** table + procedure (`*_REF`).
- `baseline.sql`: selects from the baseline table (for snowrefactor compare).
- `refactor.sql`: selects from the refactor table (for snowrefactor compare).
- `config.yml`: PK/order/ignore columns for regression.

## How to run (PowerShell)

From the repo root, use the Python 3.12 venv (`.venv312`) since Snowflake connector wheels are available there.

1) Deploy + run procedures in sandbox:

```powershell
Push-Location .\SQLRefactoring
C:/Users/ccarrill2/Documents/repos/FP/.venv312/Scripts/python.exe .\QUERIES\SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT\deploy_sandbox.py --days 5 --deploy --run
Pop-Location
```

2) Run regression compare:

```powershell
Push-Location .\SQLRefactoring
C:/Users/ccarrill2/Documents/repos/FP/.venv312/Scripts/snowrefactor.exe compare SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT
Pop-Location
```

Reports land under `SQLRefactoring/reports/`.

## Findings

Full writeup: [SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/FINDINGS.md](SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/FINDINGS.md)

- Baseline delta logic is built around a set operator (`MINUS` / `EXCEPT`). Snowflake docs: https://docs.snowflake.com/en/sql-reference/operators-query
- Refactor expresses change application as `MERGE` with optional `WHEN MATCHED ... AND <case_predicate>` gating. Snowflake docs: https://docs.snowflake.com/en/sql-reference/sql/merge
- Query cost in Snowflake is heavily influenced by micro-partition pruning and predicate shape. Snowflake docs: https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions
- Correctness guardrail: keep date-window semantics explicit for `TIMESTAMP_TZ` boundaries (don’t rely on implicit casts/timezone behavior).

## Performance (curve results)

Full report (winner-by-day + step breakdown):
[SQLRefactoring/reports/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT__curve__20260115_002530.md](SQLRefactoring/reports/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT__curve__20260115_002530.md)

Summary from that run (days 1..30, focused elapsed seconds):

- Wins: refactor 28/30 days; baseline 2/30 days.
- Average elapsed: baseline 10.829s vs refactor 8.359s.
- Median speedup: 1.297x (baseline/refactor).
- Best day (largest speedup): day 4 => baseline 17.460s vs refactor 6.272s (2.784x).
- Worst day: day 15 => baseline 9.120s vs refactor 11.244s (0.811x).

## Performance proof (Query History)

The refactor procedure prints per-step `query_id` + timing. To pull bytes/partitions/elapsed from Snowflake Query History, use:

- [SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/query_history_snippet.sql](SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/query_history_snippet.sql)

If you want a copy-paste summary message for Teams/email:

- [SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/teams_message.md](SQLRefactoring/QUERIES/SANDBOX_DATA_ENGINEER__CCARRILL2__DRILLBLAST_DRILL_CYCLE_CT/teams_message.md)

## Notes

- This harness validates **same inputs → same outputs** by comparing the resulting tables.
- `DW_LOAD_TS` and `DW_MODIFY_TS` are ignored in comparisons because they are expected to differ between runs.
