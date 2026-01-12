from __future__ import annotations

import argparse
import time

from snowrefactor.snowflake_conn import connect


def _parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(
        description=(
            "Create a TRANSIENT clustered copy of a table (CTAS) and atomically swap names so downstream code "
            "keeps using the original name.\n\n"
            "WARNING: CTAS on multi-TB tables can be very expensive and slow. Use --confirm to proceed."
        )
    )
    ap.add_argument(
        "--table",
        required=True,
        help="Fully-qualified target table name to replace (DB.SCHEMA.TABLE)",
    )
    ap.add_argument(
        "--cluster-by",
        default="(SITE_CODE, SENSOR_ID, VALUE_UTC_TS)",
        help="Clustering expression for CLUSTER BY, e.g. '(SITE_CODE, SENSOR_ID, VALUE_UTC_TS)'.",
    )
    ap.add_argument(
        "--tmp-suffix",
        default="__CLUST_TMP",
        help="Suffix used for temporary build tables.",
    )
    ap.add_argument(
        "--role",
        default=None,
        help="Optional role to USE ROLE before running DDL.",
    )
    ap.add_argument(
        "--warehouse",
        default=None,
        help=(
            "Optional warehouse to USE WAREHOUSE before running CTAS. "
            "Recommended for multi-TB builds (e.g. WH_ADHOC_BI, WH_BATCH_DE)."
        ),
    )
    ap.add_argument(
        "--statement-timeout-seconds",
        type=int,
        default=None,
        help=(
            "Optional ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS=<n> before CTAS. "
            "Use 0 for no timeout (if allowed)."
        ),
    )
    ap.add_argument(
        "--confirm",
        action="store_true",
        help="Actually run the CTAS + swap. Without this flag, prints what would be done.",
    )
    ap.add_argument(
        "--sleep-seconds",
        type=int,
        default=0,
        help="Optional sleep between CTAS and swap (debug/ops).",
    )
    return ap.parse_args()


def main() -> None:
    args = _parse_args()

    full_name = args.table
    if full_name.count(".") != 2:
        raise SystemExit("--table must be fully-qualified as DB.SCHEMA.TABLE")

    db, schema, table = full_name.split(".")
    tmp_table = f"{db}.{schema}.{table}{args.tmp_suffix}"
    old_table = f"{db}.{schema}.{table}__OLD"

    statements: list[str] = []
    statements.append(f"SHOW TABLES LIKE '{table}' IN SCHEMA {db}.{schema}")
    statements.append(
        "-- Build new clustered TRANSIENT copy (CTAS)"
        f"\nCREATE OR REPLACE TRANSIENT TABLE {tmp_table} CLUSTER BY {args.cluster_by} AS\n"
        f"SELECT * FROM {full_name}"
    )
    statements.append("-- Swap names (minimize time without the expected name)")
    statements.append(f"ALTER TABLE {full_name} RENAME TO {old_table}")
    statements.append(f"ALTER TABLE {tmp_table} RENAME TO {full_name}")
    statements.append(f"DROP TABLE {old_table}")

    if not args.confirm:
        print("DRY RUN (no changes). To execute, re-run with --confirm\n")
        for s in statements:
            print(s)
            print()
        return

    with connect() as conn:
        cur = conn.cursor()
        try:
            if args.role:
                cur.execute(f'USE ROLE "{args.role}"')

            if args.warehouse:
                cur.execute(f'USE WAREHOUSE "{args.warehouse}"')

            if args.statement_timeout_seconds is not None:
                cur.execute(
                    f"ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = {int(args.statement_timeout_seconds)}"
                )

            # Print current size/type
            cur.execute(f"SHOW TABLES LIKE '{table}' IN SCHEMA {db}.{schema}")
            row = cur.fetchone()
            if row:
                desc = [c[0] for c in cur.description]

                def get(col: str):
                    try:
                        return row[desc.index(col)]
                    except Exception:
                        return None

                print("Current table:")
                print(f"- name: {get('name')}")
                print(f"- kind: {get('kind')}")
                print(f"- rows: {get('rows')}")
                print(f"- bytes: {get('bytes')}")
                print(f"- clustering_key: {get('clustering_key')}")
                print()

            print(f"Creating clustered transient copy: {tmp_table}")

            # Clean up from a previous failed attempt (timeout/cancel).
            cur.execute(f"DROP TABLE IF EXISTS {tmp_table}")
            cur.execute(f"DROP TABLE IF EXISTS {old_table}")

            cur.execute(
                f"CREATE OR REPLACE TRANSIENT TABLE {tmp_table} CLUSTER BY {args.cluster_by} AS "
                f"SELECT * FROM {full_name}"
            )

            if args.sleep_seconds:
                time.sleep(args.sleep_seconds)

            print("Swapping names...")
            cur.execute(f"ALTER TABLE {full_name} RENAME TO {old_table}")
            cur.execute(f"ALTER TABLE {tmp_table} RENAME TO {full_name}")
            cur.execute(f"DROP TABLE {old_table}")

            # Confirm new kind/clustering key
            cur.execute(f"SHOW TABLES LIKE '{table}' IN SCHEMA {db}.{schema}")
            row2 = cur.fetchone()
            if row2:
                desc2 = [c[0] for c in cur.description]

                def get2(col: str):
                    try:
                        return row2[desc2.index(col)]
                    except Exception:
                        return None

                print("\nAfter swap:")
                print(f"- name: {get2('name')}")
                print(f"- kind: {get2('kind')}")
                print(f"- rows: {get2('rows')}")
                print(f"- bytes: {get2('bytes')}")
                print(f"- clustering_key: {get2('clustering_key')}")

        finally:
            cur.close()


if __name__ == "__main__":
    main()
