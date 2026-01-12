from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from snowrefactor.snowflake_conn import connect


@dataclass(frozen=True)
class PulledFunction:
    fqn: str  # DB.SCHEMA.NAME (no args)
    signature: str  # DB.SCHEMA.NAME(<args types...>)
    ddl: str
    is_table_function: bool


def _safe_folder_name(fqn: str) -> str:
    return fqn.strip().replace(".", "__").replace(" ", "_")


def _fetch_all_as_dicts(cur) -> list[dict[str, Any]]:
    cols = [d[0] for d in (cur.description or [])]
    rows = cur.fetchall() or []
    out: list[dict[str, Any]] = []
    for r in rows:
        out.append({cols[i]: r[i] for i in range(min(len(cols), len(r)))})
    return out


def _parse_fqn(fqn: str) -> tuple[str, str, str]:
    parts = [p.strip() for p in fqn.strip().split(".") if p.strip()]
    if len(parts) != 3:
        raise ValueError("Function name must be fully-qualified: <database>.<schema>.<function>")
    return parts[0], parts[1], parts[2]


def _choose_best_signature(rows: list[dict[str, Any]], func_name: str) -> tuple[str, bool]:
    """Pick a signature string suitable for GET_DDL.

    SHOW FUNCTIONS returns an "arguments" column with types. For table functions, it may include
    RETURNS TABLE / is_table_function flags depending on account/version.
    """
    # Prefer table functions first if info present.
    def _is_table(r: dict[str, Any]) -> bool:
        # column names vary; handle best-effort.
        for k in ("is_table_function", "IS_TABLE_FUNCTION"):
            if k in r and r[k] is not None:
                return str(r[k]).strip().lower() in ("true", "yes", "1", "y")
        for k in ("type", "TYPE"):
            if k in r and r[k] is not None:
                return "table" in str(r[k]).lower()
        for k in ("returns", "RETURNS", "return_type", "RETURN_TYPE"):
            if k in r and r[k] is not None:
                return "table" in str(r[k]).lower()
        return False

    def _arg_count(r: dict[str, Any]) -> int:
        args = r.get("arguments") or r.get("ARGUMENTS")
        if not args:
            return 0
        # count commas at top-level; this is approximate but fine for sorting.
        return str(args).count(",") + 1 if str(args).strip() else 0

    sorted_rows = sorted(rows, key=lambda r: (not _is_table(r), _arg_count(r)))
    chosen = sorted_rows[0]
    args = str(chosen.get("arguments") or chosen.get("ARGUMENTS") or "").strip()

    # Example returned by SHOW FUNCTIONS:
    #   SENSOR_SNAPSHOT_GET(VARCHAR, BOOLEAN, ARRAY, ARRAY) RETURN TABLE (...)
    # We need a GET_DDL signature like:
    #   <db>.<schema>.SENSOR_SNAPSHOT_GET(VARCHAR, BOOLEAN, ARRAY, ARRAY)

    # If SHOW FUNCTIONS includes the function name, strip it and keep only the "(types...)" part.
    base_name = func_name.split(".")[-1]
    m = re.match(rf"(?is)^\s*{re.escape(base_name)}\s*(\(.*)\s*$", args)
    if m:
        args = m.group(1).strip()

    # Remove trailing return metadata like " RETURN TABLE (...)" / " RETURNS <type>".
    # Keep the argument list up to the first closing paren.
    if args:
        # If args starts with '(', keep through the matching ')' at the end of the args list.
        if args.lstrip().startswith("("):
            # Best-effort: take everything through the first ')' (args list has no nested parens in types).
            close_idx = args.find(")")
            if close_idx != -1:
                args = args[: close_idx + 1]
        # If there is explicit RETURN/RETURNS, truncate at it.
        args = re.split(r"(?is)\s+return\s+", args, maxsplit=1)[0].strip()
        args = re.split(r"(?is)\s+returns\s+", args, maxsplit=1)[0].strip()

    # Ensure we have parentheses.
    if args and not args.lstrip().startswith("("):
        args = f"({args})"

    signature = f"{func_name}{args}" if args else func_name
    return signature, _is_table(chosen)


def get_function_ddl(fqn: str) -> PulledFunction:
    db, schema, name = _parse_fqn(fqn)
    base = f"{db}.{schema}.{name}"

    with connect() as conn:
        cur = conn.cursor()
        try:
            # SHOW FUNCTIONS is usually the easiest way to discover arg types.
            cur.execute(f"SHOW FUNCTIONS LIKE %s IN SCHEMA {db}.{schema}", (name,))
            rows = _fetch_all_as_dicts(cur)
        finally:
            cur.close()

    if not rows:
        raise RuntimeError(f"No functions found (or insufficient privileges): {base}")

    signature, is_table = _choose_best_signature(rows, base)

    # GET_DDL needs the signature including arg types.
    sql = "SELECT GET_DDL('FUNCTION', %s)"
    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(sql, (signature,))
            row = cur.fetchone()
        finally:
            cur.close()

    if not row or row[0] is None:
        raise RuntimeError(f"GET_DDL returned no result for: {signature}")

    ddl = str(row[0]).strip().rstrip(";") + "\n"
    return PulledFunction(fqn=base, signature=signature, ddl=ddl, is_table_function=is_table)


def pull_function_baseline(*, fqn: str, queries_dir: Path, force: bool) -> Path:
    pulled = get_function_ddl(fqn)

    queries_dir.mkdir(parents=True, exist_ok=True)
    folder = queries_dir / _safe_folder_name(pulled.fqn)
    folder.mkdir(parents=True, exist_ok=True)

    baseline_ddl = folder / "baseline_ddl.sql"
    baseline_sql = folder / "baseline.sql"
    refactor_sql = folder / "refactor.sql"
    config_yml = folder / "config.yml"

    if not force:
        for p in [baseline_ddl, baseline_sql, refactor_sql]:
            if p.exists():
                raise FileExistsError(f"File already exists: {p}. Use --force to overwrite.")

    baseline_ddl.write_text(pulled.ddl, encoding="utf-8")

    # Provide an executable example for *this* table function, based on the current view usage.
    # Users can edit it for other sites/tags.
    if pulled.is_table_function:
        example_call = (
            f"SELECT *\nFROM TABLE({pulled.fqn}(\n"
            "  'MOR',\n"
            "  FALSE,\n"
            "  ARRAY_CONSTRUCT(''),\n"
            "  ARRAY_CONSTRUCT(\n"
            "    'CR03_CRUSH_OUT_TIME',\n"
            "    'PE_MOR_CC_MflPileTonnage',\n"
            "    'PE_MOR_CC_MillPileTonnage'\n"
            "  )\n"
            "));\n"
        )
        baseline_sql.write_text("-- Baseline example call for this table function\n" + example_call, encoding="utf-8")
        if not refactor_sql.exists() or force:
            refactor_sql.write_text(
                "-- Refactor (initially same as baseline)\n" + example_call,
                encoding="utf-8",
            )
    else:
        # Non-table function: we still scaffold but require user to craft a call.
        baseline_sql.write_text(
            "-- TODO: add an executable SELECT that exercises this function\n" f"-- Function: {pulled.fqn}\n",
            encoding="utf-8",
        )
        if not refactor_sql.exists() or force:
            refactor_sql.write_text(
                "-- TODO: add an executable SELECT that exercises this function\n" f"-- Function: {pulled.fqn}\n",
                encoding="utf-8",
            )

    if not config_yml.exists():
        config_yml.write_text(
            "# Optional settings for comparisons\n"
            "# order_by: []\n"
            "# primary_key: []\n"
            "# max_fetch_rows: 200000\n",
            encoding="utf-8",
        )

    # Persist the signature we used.
    (folder / "signature.txt").write_text(pulled.signature + "\n", encoding="utf-8")
    return folder
