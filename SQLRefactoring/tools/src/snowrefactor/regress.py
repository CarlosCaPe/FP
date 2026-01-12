from __future__ import annotations

from pathlib import Path
from typing import Any

from snowrefactor.compare import compare_sql
from snowrefactor.ddl import get_view_ddl, normalize_view_ddl


def regress_views(
    *,
    baseline_fqn: str,
    sandbox_fqn: str,
    reports_dir: Path,
    max_fetch_rows: int,
    threads: int = 2,
    ignore_columns: list[str] | None = None,
) -> Path:
    base = get_view_ddl(baseline_fqn)
    sand = get_view_ddl(sandbox_fqn)

    ddl_base_norm = normalize_view_ddl(base.ddl)
    ddl_sand_norm = normalize_view_ddl(sand.ddl)

    ddl_info: dict[str, Any] = {
        "baseline_fqn": baseline_fqn,
        "sandbox_fqn": sandbox_fqn,
        "equal_normalized": ddl_base_norm == ddl_sand_norm,
        "normalized_baseline": ddl_base_norm,
        "normalized_sandbox": ddl_sand_norm,
    }

    baseline_sql = f"SELECT * FROM {baseline_fqn};"
    sandbox_sql = f"SELECT * FROM {sandbox_fqn};"

    return compare_sql(
        query_name=f"regress__{baseline_fqn}__vs__{sandbox_fqn}".replace(".", "_").replace(" ", "_"),
        baseline_sql=baseline_sql,
        refactor_sql=sandbox_sql,
        reports_dir=reports_dir,
        max_fetch_rows=max_fetch_rows,
        order_by=None,
        ignore_columns=ignore_columns,
        extra={"ddl": ddl_info},
        threads=threads,
    )
