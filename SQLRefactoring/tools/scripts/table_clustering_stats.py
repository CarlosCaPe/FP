from __future__ import annotations

import argparse
import json
from typing import Any

from snowrefactor.snowflake_conn import connect

DEFAULT_TABLES = [
    "PROD_DATALAKE.FCTS.PI_AF_ATTRIBUTE",
    "PROD_DATALAKE.FCTS.PI_POINT",
    "PROD_DATALAKE.FCTS.SENSOR_READING_SAM_B",
    "PROD_DATALAKE.FCTS.SENSOR_READING_MOR_B",
    "PROD_DATALAKE.FCTS.SENSOR_READING_CMX_B",
    "PROD_DATALAKE.FCTS.SENSOR_READING_SIE_B",
    "PROD_DATALAKE.FCTS.SENSOR_READING_NMO_B",
    "PROD_DATALAKE.FCTS.SENSOR_READING_BAG_B",
    "PROD_DATALAKE.FCTS.SENSOR_READING_CVE_B",
]

# Heuristic: these are the filters that matter in this function.
DEFAULT_CLUSTER_EXPRS = [
    None,  # use table's defined clustering key (if any)
    "(SITE_CODE)",
    "(CAST(VALUE_UTC_TS AS DATE))",
    "(SITE_CODE, CAST(VALUE_UTC_TS AS DATE))",
    "(SITE_CODE, VALUE_UTC_TS)",
    "(SITE_CODE, SENSOR_ID, VALUE_UTC_TS)",
]


def _parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(
        description=(
            "Print SHOW TABLES key fields and SYSTEM$CLUSTERING_INFORMATION for one or more tables.\n"
            "By default it uses a curated list of PROD tables and a set of clustering expressions.\n"
            "Use --table and --expr to target specific sandbox clones / expressions."
        )
    )
    ap.add_argument(
        "--table",
        action="append",
        dest="tables",
        help=(
            "Fully-qualified table name (DB.SCHEMA.TABLE). Can be provided multiple times. "
            "If omitted, uses the default list."
        ),
    )
    ap.add_argument(
        "--expr",
        action="append",
        dest="exprs",
        help=(
            "Clustering expression string, e.g. '(SITE_CODE, SENSOR_ID, VALUE_UTC_TS)'. "
            "Can be provided multiple times. If omitted, uses default expressions."
        ),
    )
    ap.add_argument(
        "--no-table-key",
        action="store_true",
        help="Skip calling SYSTEM$CLUSTERING_INFORMATION(full_name) for the table's defined clustering key.",
    )
    return ap.parse_args()


def run_one(cur, sql: str) -> list[tuple[Any, ...]]:
    cur.execute(sql)
    try:
        return cur.fetchall()
    except Exception:
        # Some SHOW commands are not fetchall-compatible in some connector versions
        row = cur.fetchone()
        return [row] if row else []


def main() -> None:
    args = _parse_args()
    tables: list[str] = args.tables if args.tables else DEFAULT_TABLES
    exprs: list[str | None]
    if args.exprs:
        exprs = [e.strip() for e in args.exprs]
    else:
        exprs = DEFAULT_CLUSTER_EXPRS
    if args.no_table_key:
        exprs = [e for e in exprs if e is not None]

    with connect() as conn:
        cur = conn.cursor()
        try:
            for full_name in tables:
                db, schema, table = full_name.split(".")

                print("=" * 100)
                print(full_name)

                # SHOW TABLES gives basic stats + clustering_key when present
                show_sql = (
                    f"SHOW TABLES LIKE '{table}' IN SCHEMA {db}.{schema}"  # nosec B608 (internal tooling)
                )
                rows = run_one(cur, show_sql)
                if not rows:
                    print("SHOW TABLES: no rows returned")
                else:
                    # Print a subset of columns we care about. The SHOW TABLES output schema can vary slightly.
                    desc = [c[0] for c in cur.description]
                    row = rows[0]
                    def get(col: str):
                        try:
                            return row[desc.index(col)]
                        except Exception:
                            return None

                    print("SHOW TABLES key fields:")
                    print(f"- created_on: {get('created_on')}")
                    print(f"- name: {get('name')}")
                    print(f"- kind: {get('kind')}")
                    print(f"- rows: {get('rows')}")
                    print(f"- bytes: {get('bytes')}")
                    print(f"- retention_time: {get('retention_time')}")
                    print(f"- clustering_key: {get('clustering_key')}")
                    print(f"- is_external: {get('is_external')}")

                # SYSTEM$CLUSTERING_INFORMATION returns VARIANT(JSON)
                for expr in exprs:
                    if expr is None:
                        label = "(table clustering key)"
                        sql = f"SELECT SYSTEM$CLUSTERING_INFORMATION('{full_name}')"
                    else:
                        label = expr
                        sql = f"SELECT SYSTEM$CLUSTERING_INFORMATION('{full_name}', '{expr}')"

                    try:
                        cur.execute(sql)
                        info_raw = cur.fetchone()
                        if not info_raw:
                            print(f"CLUSTERING {label}: <no result>")
                            continue
                        info = info_raw[0]
                        # Connector may return a dict already, or a JSON string.
                        if isinstance(info, str):
                            try:
                                info = json.loads(info)
                            except Exception:
                                pass
                        print(f"\nCLUSTERING INFORMATION {label}:")
                        if isinstance(info, dict):
                            # Print common keys (not all will exist)
                            for k in [
                                "cluster_by_keys",
                                "total_partition_count",
                                "total_constant_partition_count",
                                "average_overlaps",
                                "average_depth",
                                "partition_depth_histogram",
                                "notes",
                            ]:
                                if k in info:
                                    v = info[k]
                                    if isinstance(v, (dict, list)):
                                        v = json.dumps(v, ensure_ascii=False)
                                    print(f"- {k}: {v}")
                        else:
                            print(info)
                    except Exception as e:
                        print(f"\nCLUSTERING INFORMATION {label}: ERROR: {type(e).__name__}: {e}")

        finally:
            cur.close()


if __name__ == "__main__":
    main()
