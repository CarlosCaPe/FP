from __future__ import annotations

import re
from pathlib import Path

from snowrefactor.snowflake_conn import load_snowflake_env, connect
from snowrefactor.ddl import extract_view_select_from_ddl


def _extract_view_columns(ddl_text: str) -> list[str] | None:
    # Very small parser for GET_DDL output like:
    # create or replace view VIEWNAME(
    #   COL1,
    #   COL2
    # ) as
    m = re.search(r"create\s+or\s+replace\s+view\s+[^\(]+\((.*?)\)\s+as\s", ddl_text, flags=re.I | re.S)
    if not m:
        return None

    block = m.group(1)
    cols: list[str] = []
    for line in block.splitlines():
        line = line.strip().rstrip(",")
        if not line:
            continue
        # strip surrounding quotes if present
        if line.startswith('"') and line.endswith('"'):
            line = line[1:-1]
        cols.append(line)

    return cols or None


def deploy_view_from_folder(*, folder_name: str, queries_dir: Path, target_name: str) -> str:
    folder = queries_dir / folder_name
    baseline_ddl_path = folder / "baseline_ddl.sql"
    refactor_sql_path = folder / "refactor.sql"

    if not baseline_ddl_path.exists():
        raise FileNotFoundError(f"Missing {baseline_ddl_path}")
    if not refactor_sql_path.exists():
        raise FileNotFoundError(f"Missing {refactor_sql_path}")

    ddl_text = baseline_ddl_path.read_text(encoding="utf-8")
    columns = _extract_view_columns(ddl_text)

    raw_refactor = refactor_sql_path.read_text(encoding="utf-8").strip().rstrip(";")

    def _is_trivial_select_star(sql: str) -> bool:
        # If refactor.sql is still just "SELECT * FROM <view/table>", deploy the
        # actual view body from baseline_ddl to keep DDL as close as possible.
        #
        # Important: do not use a DOTALL-greedy regex against the full file; a
        # multi-CTE query that happens to end with "SELECT * FROM <cte>" must not
        # be classified as trivial.
        meaningful_lines: list[str] = []
        for line in sql.splitlines():
            stripped = line.strip()
            if not stripped:
                continue
            if stripped.startswith("--"):
                continue
            meaningful_lines.append(stripped)

        compact = "\n".join(meaningful_lines).strip().rstrip(";")
        return re.fullmatch(r"(?is)select\s+\*\s+from\s+[^;]+", compact) is not None

    deployed_body = raw_refactor
    if _is_trivial_select_star(raw_refactor):
        extracted = extract_view_select_from_ddl(ddl_text)
        if extracted:
            deployed_body = extracted

    refactor_sql = deployed_body

    env = load_snowflake_env()
    if not env.database or not env.schema:
        raise RuntimeError(
            "Missing sandbox target database/schema. Set CONN_LIB_SNOWFLAKE_DATABASE and CONN_LIB_SNOWFLAKE_SCHEMA."
        )

    target_fqn = f"{env.database}.{env.schema}.{target_name}"

    if columns:
        cols_sql = ", ".join([f'"{c}"' for c in columns])
        create_sql = f"CREATE OR REPLACE VIEW {target_fqn} ({cols_sql}) AS\n{refactor_sql}"
    else:
        create_sql = f"CREATE OR REPLACE VIEW {target_fqn} AS\n{refactor_sql}"

    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(create_sql)
        finally:
            cur.close()

    # Persist the target for convenience
    (folder / "sandbox_view.txt").write_text(target_fqn + "\n", encoding="utf-8")
    return target_fqn
