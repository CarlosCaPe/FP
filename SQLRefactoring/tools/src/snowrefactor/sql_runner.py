from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import pandas as pd


@dataclass(frozen=True)
class QueryResult:
    columns: list[str]
    rowcount: int
    dataframe: pd.DataFrame | None
    truncated: bool = False


def _wrap_as_subquery(sql: str) -> str:
    # Keep it simple: assume the .sql is a SELECT. If it's a WITH ... SELECT, still ok.
    return f"SELECT * FROM (\n{sql.strip().rstrip(';')}\n) q"


def fetch_dataframe(conn: Any, sql: str, max_rows: int) -> QueryResult:
    # Never download the full result accidentally; cap to max_rows+1.
    wrapped = _wrap_as_subquery(sql)
    capped = f"{wrapped}\nLIMIT {int(max_rows) + 1}"

    cur = conn.cursor()
    try:
        cur.execute(capped)
        df = cur.fetch_pandas_all()
    finally:
        cur.close()

    truncated = len(df) > max_rows
    if truncated:
        df = df.iloc[:max_rows].copy()
        return QueryResult(columns=list(df.columns), rowcount=len(df), dataframe=None, truncated=True)

    return QueryResult(columns=list(df.columns), rowcount=len(df), dataframe=df, truncated=False)


def fetch_rowcount(conn: Any, sql: str) -> int:
    cur = conn.cursor()
    try:
        cur.execute(f"SELECT COUNT(*) AS CNT FROM (\n{sql.strip().rstrip(';')}\n) q")
        (cnt,) = cur.fetchone()
        return int(cnt)
    finally:
        cur.close()


def get_columns(conn: Any, sql: str) -> list[str]:
    """Return output column names for the given SELECT query."""
    cur = conn.cursor()
    try:
        cur.execute(f"SELECT * FROM (\n{sql.strip().rstrip(';')}\n) q LIMIT 0")
        if not cur.description:
            return []
        return [d[0] for d in cur.description]
    finally:
        cur.close()


def in_db_profile(
    conn: Any,
    sql: str,
    *,
    max_columns: int = 200,
    ignore_columns: list[str] | None = None,
) -> dict[str, Any]:
    """Compute basic profiling metrics inside Snowflake without fetching data."""
    cols = get_columns(conn, sql)

    if ignore_columns:
        cols = [c for c in cols if c not in set(ignore_columns)]
    profile: dict[str, Any] = {"columns": cols}

    if not cols:
        return profile

    if len(cols) > max_columns:
        profile["skipped"] = f"Too many columns ({len(cols)}), max is {max_columns}."
        return profile

    # Null counts
    null_select = ",\n".join([f"COUNT_IF(\"{c}\" IS NULL) AS \"{c}__NULLS\"" for c in cols])
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT\n"
            + null_select
            + f"\nFROM (\n{sql.strip().rstrip(';')}\n) q"
        )
        row = cur.fetchone()
        nulls = {f"{c}": int(row[i]) for i, c in enumerate(cols)}
        profile["null_counts"] = nulls
    finally:
        cur.close()

    # Order-insensitive checksum over rows using HASH_AGG of a stable row representation.
    # Use OBJECT_CONSTRUCT_KEEP_NULL with explicit key/value pairs for determinism.
    pairs = ", ".join([f"'{c}', \"{c}\"" for c in cols])
    row_repr = f"OBJECT_CONSTRUCT_KEEP_NULL({pairs})"
    checksum_sql = (
        "SELECT TO_VARCHAR(HASH_AGG(TO_VARIANT(" + row_repr + "))) AS CHECKSUM "
        + f"FROM (\n{sql.strip().rstrip(';')}\n) q"
    )
    cur = conn.cursor()
    try:
        cur.execute(checksum_sql)
        (checksum,) = cur.fetchone()
        profile["checksum"] = str(checksum) if checksum is not None else None
    finally:
        cur.close()

    return profile
