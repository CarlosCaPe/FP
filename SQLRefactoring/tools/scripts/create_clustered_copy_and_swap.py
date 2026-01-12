from __future__ import annotations

import argparse
import datetime as dt
import sys
from typing import Iterable

from snowrefactor.snowflake_conn import connect


def _utc_stamp() -> str:
    return dt.datetime.now(tz=dt.timezone.utc).strftime("%Y%m%d_%H%M%S")


def _parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(
        description=(
            "Create a PERMANENT clustered copy of a table and swap it into place by name.\n\n"
            "This is intended for sandbox experiments where the existing table is a TRANSIENT clone\n"
            "and you want a PERMANENT table with a CLUSTER BY key without modifying downstream SQL."
        )
    )
    ap.add_argument(
        "--db",
        default="SANDBOX_DATA_ENGINEER",
        help="Database name (default: SANDBOX_DATA_ENGINEER)",
    )
    ap.add_argument(
        "--schema",
        default="CCARRILL2",
        help="Schema name (default: CCARRILL2)",
    )
    ap.add_argument(
        "--table",
        default="FCTS_SENSOR_READING_MOR_B",
        help="Table name to replace (default: FCTS_SENSOR_READING_MOR_B)",
    )
    ap.add_argument(
        "--cluster-by",
        default="SITE_CODE, SENSOR_ID, VALUE_UTC_TS",
        help=(
            "Comma-separated clustering keys (default: SITE_CODE, SENSOR_ID, VALUE_UTC_TS). "
            "Do not include parentheses."
        ),
    )
    ap.add_argument(
        "--keep-old",
        action="store_true",
        help="Do not drop the old transient table after swapping (keeps a backup).",
    )
    return ap.parse_args()


def _csv_to_keys(s: str) -> list[str]:
    keys = [k.strip() for k in s.split(",") if k.strip()]
    if not keys:
        raise ValueError("--cluster-by must contain at least one key")
    return keys


def _run(cur, sql: str) -> None:
    # nosec B608 - internal tooling, SQL is controlled by args
    cur.execute(sql)


def _run_fetchone(cur, sql: str):
    # nosec B608 - internal tooling, SQL is controlled by args
    cur.execute(sql)
    return cur.fetchone()


def _print_show_table(cur, db: str, schema: str, table: str) -> None:
    sql = f"SHOW TABLES LIKE '{table}' IN SCHEMA {db}.{schema}"  # nosec B608
    _run(cur, sql)
    row = cur.fetchone()
    if not row:
        print(f"SHOW TABLES: {db}.{schema}.{table}: <no rows>")
        return
    desc = [c[0] for c in cur.description]

    def get(col: str):
        try:
            return row[desc.index(col)]
        except Exception:
            return None

    print(f"SHOW TABLES: {db}.{schema}.{table}")
    print(f"- kind: {get('kind')}")
    print(f"- rows: {get('rows')}")
    print(f"- bytes: {get('bytes')}")
    print(f"- retention_time: {get('retention_time')}")
    print(f"- clustering_key: {get('clustering_key')}")


def _print_clustering_info(cur, full_name: str, expr: str) -> None:
    sql = f"SELECT SYSTEM$CLUSTERING_INFORMATION('{full_name}', '{expr}')"  # nosec B608
    row = _run_fetchone(cur, sql)
    if not row:
        print(f"CLUSTERING INFORMATION {expr}: <no rows>")
        return
    print(f"CLUSTERING INFORMATION {expr}: {row[0]}")


def main() -> int:
    args = _parse_args()
    keys = _csv_to_keys(args.cluster_by)

    db = args.db
    schema = args.schema
    table = args.table

    full_name = f"{db}.{schema}.{table}"
    stamp = _utc_stamp()
    tmp_table = f"{table}__CLUSTERED_TMP_{stamp}"
    old_table = f"{table}__OLD_{stamp}"

    cluster_expr = f"({', '.join(keys)})"

    print("=" * 100)
    print("Target table:")
    print(f"- original: {full_name}")
    print(f"- tmp:      {db}.{schema}.{tmp_table}")
    print(f"- old:      {db}.{schema}.{old_table}")
    print(f"- cluster:  {cluster_expr}")

    with connect() as conn:
        cur = conn.cursor()
        try:
            print("\nBefore:")
            _print_show_table(cur, db, schema, table)
            _print_clustering_info(cur, full_name, cluster_expr)

            print("\nCreating PERMANENT clustered copy (CTAS)...")
            create_sql = (
                f"CREATE OR REPLACE TABLE {db}.{schema}.{tmp_table} "
                f"CLUSTER BY {cluster_expr} AS "
                f"SELECT * FROM {full_name}"
            )
            _run(cur, create_sql)

            print("\nAfter create:")
            _print_show_table(cur, db, schema, tmp_table)
            _print_clustering_info(cur, f"{db}.{schema}.{tmp_table}", cluster_expr)

            print("\nSwapping into place...")
            _run(cur, f"ALTER TABLE {full_name} RENAME TO {old_table}")
            _run(cur, f"ALTER TABLE {db}.{schema}.{tmp_table} RENAME TO {table}")

            print("\nAfter swap:")
            _print_show_table(cur, db, schema, table)
            _print_clustering_info(cur, full_name, cluster_expr)

            if args.keep_old:
                print(f"\nKeeping old table as {db}.{schema}.{old_table}")
            else:
                print(f"\nDropping old table {db}.{schema}.{old_table}...")
                _run(cur, f"DROP TABLE {db}.{schema}.{old_table}")

            print("\nDone.")
            return 0
        finally:
            cur.close()


if __name__ == "__main__":
    raise SystemExit(main())
