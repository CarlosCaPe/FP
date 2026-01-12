from __future__ import annotations

import argparse

from snowrefactor.snowflake_conn import connect, load_snowflake_env


def _is_dynamic_table_change_tracking_error(msg: str) -> bool:
    m = msg.lower()
    return (
        "change tracking is not supported" in m
        and "dynamic tables" in m
        and "refresh_mode" in m
        and "full" in m
    )


def _fq(db: str | None, schema: str | None, name: str) -> str:
    if db and schema:
        return f"{db}.{schema}.{name}"
    if schema:
        return f"{schema}.{name}"
    return name


def main() -> int:
    ap = argparse.ArgumentParser(
        description=(
            "Create a sandbox CDC pipeline for PROD_WG.DRILL_BLAST.DRILL_CYCLE using a STREAM on a sandbox view "
            "and a TASK that appends change rows into a changelog table. Uses .env via snowrefactor.snowflake_conn."
        )
    )
    ap.add_argument(
        "--source-view",
        default="PROD_WG.DRILL_BLAST.DRILL_CYCLE",
        help="Source view to CDC (default: PROD_WG.DRILL_BLAST.DRILL_CYCLE)",
    )
    ap.add_argument(
        "--stream-mode",
        choices=["view", "table"],
        default="view",
        help=(
            "Where to create the stream. 'view' creates a stream on the sandbox view (preferred). "
            "'table' creates a stream on --source-table (fallback when view CDC is blocked)."
        ),
    )
    ap.add_argument(
        "--source-table",
        default="PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_C",
        help=(
            "Fallback source table to stream on when --stream-mode=table (default: "
            "PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_C)"
        ),
    )
    ap.add_argument(
        "--target-view",
        default="DRILL_CYCLE_CDC_V",
        help="Sandbox view name to create in env database/schema (default: DRILL_CYCLE_CDC_V)",
    )
    ap.add_argument(
        "--stream",
        default="CDC__DRILL_CYCLE__STRM",
        help="Stream name to create in env database/schema (default: CDC__DRILL_CYCLE__STRM)",
    )
    ap.add_argument(
        "--changelog",
        default="CDC__DRILL_CYCLE__CHANGELOG",
        help="Changelog table name to create in env database/schema (default: CDC__DRILL_CYCLE__CHANGELOG)",
    )
    ap.add_argument(
        "--task",
        default="CDC__DRILL_CYCLE__APPLY_TASK",
        help="Task name to create in env database/schema (default: CDC__DRILL_CYCLE__APPLY_TASK)",
    )
    ap.add_argument(
        "--consumer-view",
        default="CDC__DRILL_CYCLE__CONSUMER_V",
        help=(
            "Consumer-contract view name to create in env database/schema (default: CDC__DRILL_CYCLE__CONSUMER_V). "
            "Exposes PK + CDC fields + row columns for downstream ingestion."
        ),
    )
    ap.add_argument(
        "--schedule",
        default="5 MINUTE",
        help="Task schedule (default: 5 MINUTE)",
    )
    ap.add_argument(
        "--resume",
        action="store_true",
        help="Resume the task after creation (default: false)",
    )
    args = ap.parse_args()

    env = load_snowflake_env()

    with connect() as conn:
        cur = conn.cursor()
        try:
            # Ensure we operate in the sandbox database/schema from env (if set)
            if env.role:
                cur.execute(f'USE ROLE "{env.role}"')
            if env.warehouse:
                cur.execute(f'USE WAREHOUSE "{env.warehouse}"')
            if env.database:
                cur.execute(f'USE DATABASE "{env.database}"')
            if env.schema:
                cur.execute(f'USE SCHEMA "{env.schema}"')

            cur.execute("SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA()")
            role, wh, db, schema = cur.fetchone()
            print("Context:")
            print("  role     =", role)
            print("  warehouse=", wh)
            print("  database =", db)
            print("  schema   =", schema)

            target_view_fqn = _fq(env.database, env.schema, args.target_view)
            stream_fqn = _fq(env.database, env.schema, args.stream)
            changelog_fqn = _fq(env.database, env.schema, args.changelog)
            task_fqn = _fq(env.database, env.schema, args.task)
            consumer_view_fqn = _fq(env.database, env.schema, args.consumer_view)

            print("\n1) Create sandbox view (owned by us)")
            # IMPORTANT: Avoid setting CHANGE_TRACKING explicitly here because it can lock underlying objects.
            # Creating a stream on the view is the least intrusive way to attempt enabling change tracking.
            cur.execute(f"CREATE OR REPLACE VIEW {target_view_fqn} AS SELECT * FROM {args.source_view}")
            print("  created:", target_view_fqn)

            print("\n2) Create stream")
            stream_source_fqn = target_view_fqn
            stream_source_desc = f"sandbox view {target_view_fqn}"
            create_stream_sql = f"CREATE OR REPLACE STREAM {stream_fqn} ON VIEW {target_view_fqn} SHOW_INITIAL_ROWS = FALSE"

            if args.stream_mode == "table":
                stream_source_fqn = args.source_table
                stream_source_desc = f"source table {args.source_table}"
                create_stream_sql = f"CREATE OR REPLACE STREAM {stream_fqn} ON TABLE {args.source_table} SHOW_INITIAL_ROWS = FALSE"

            try:
                cur.execute(create_stream_sql)
            except Exception as e:
                # Provide a clear message for the known blocker when the view depends on FULL-refresh dynamic tables.
                msg = str(e)
                if args.stream_mode == "view" and _is_dynamic_table_change_tracking_error(msg):
                    print("\nERROR: Unable to create a stream on the view due to dynamic table change tracking limitations.")
                    print("Details:")
                    print("  " + msg)
                    print("\nNext steps:")
                    print("- Stream CDC cannot be enabled on this view while it depends on FULL-refresh dynamic tables without an IMMUTABLE constraint.")
                    print("- Options:")
                    print("  1) Ask the owning team to adjust the dynamic table(s) to support change tracking (e.g., IMMUTABLE constraint / supported refresh strategy).")
                    print("  2) Run this script with --stream-mode=table to stream from a stable base table instead (POC for downstream delta flow).")
                    return 2
                raise

            print("  created:", stream_fqn)
            print("  stream source:", stream_source_desc)

            print("\n3) Create changelog table (append-only)")
            cur.execute(
                "CREATE OR REPLACE TABLE "
                + changelog_fqn
                + " AS\n"
                + "SELECT\n"
                + "  CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS LOAD_TS,\n"
                + "  METADATA$ACTION::STRING          AS CDC_ACTION,\n"
                + "  METADATA$ISUPDATE::BOOLEAN       AS CDC_ISUPDATE,\n"
                + "  METADATA$ROW_ID::STRING          AS CDC_ROW_ID,\n"
                + "  t.*\n"
                + f"FROM {stream_fqn} t\n"
                + "WHERE 1 = 0"
            )
            print("  created:", changelog_fqn)

            print("\n4) Create task to consume stream every", args.schedule)
            if not wh:
                raise RuntimeError(
                    "No warehouse set in session. Set CONN_LIB_SNOWFLAKE_WAREHOUSE in .env or USE WAREHOUSE before running."
                )

            insert_sql = (
                "INSERT INTO "
                + changelog_fqn
                + "\nSELECT\n"
                + "  CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS LOAD_TS,\n"
                + "  METADATA$ACTION::STRING          AS CDC_ACTION,\n"
                + "  METADATA$ISUPDATE::BOOLEAN       AS CDC_ISUPDATE,\n"
                + "  METADATA$ROW_ID::STRING          AS CDC_ROW_ID,\n"
                + "  t.*\n"
                + f"FROM {stream_fqn} t"
            )

            cur.execute(
                f"CREATE OR REPLACE TASK {task_fqn}\n"
                + f"  WAREHOUSE = \"{wh}\"\n"
                + f"  SCHEDULE = '{args.schedule}'\n"
                + "AS\n"
                + insert_sql
            )
            print("  created:", task_fqn)

            if args.resume:
                cur.execute(f"ALTER TASK {task_fqn} RESUME")
                print("  resumed:", task_fqn)
            else:
                print("  task left SUSPENDED (pass --resume to start it)")

            print("\n5) Create consumer contract view (for SQL Server ingestion)")
            # Contract: flat columns (faster than JSON/VARIANT for typical MERGE workloads in SQL Server).
            # Notes:
            # - PK comes from the documented logical PK in the view header comment.
            # - We exclude CDC_ROW_ID (Snowflake internal row identifier) from the consumer contract.
            cur.execute(
                "CREATE OR REPLACE VIEW "
                + consumer_view_fqn
                + " AS\n"
                + "SELECT\n"
                + "  ORIG_SRC_ID,\n"
                + "  SITE_CODE,\n"
                + "  DRILL_HOLE_SHIFT_ID,\n"
                + "  SYSTEM_VERSION,\n"
                + "  DRILL_ID,\n"
                + "  DRILL_HOLE_ID,\n"
                + "  CDC_ACTION,\n"
                + "  CDC_ISUPDATE,\n"
                + "  LOAD_TS,\n"
                + "  * EXCLUDE (\n"
                + "      ORIG_SRC_ID,\n"
                + "      SITE_CODE,\n"
                + "      DRILL_HOLE_SHIFT_ID,\n"
                + "      SYSTEM_VERSION,\n"
                + "      DRILL_ID,\n"
                + "      DRILL_HOLE_ID,\n"
                + "      CDC_ACTION,\n"
                + "      CDC_ISUPDATE,\n"
                + "      LOAD_TS,\n"
                + "      CDC_ROW_ID\n"
                + "    )\n"
                + "FROM "
                + changelog_fqn
            )
            print("  created:", consumer_view_fqn)

            print("\n6) Quick health checks")
            cur.execute(f"SHOW STREAMS LIKE '{args.stream}'")
            print("  show streams rows:", len(cur.fetchall()))

            # This call also helps keep empty streams from becoming stale.
            cur.execute("SELECT SYSTEM$STREAM_HAS_DATA(%s)", (stream_fqn,))
            has_data = cur.fetchone()[0]
            print("  SYSTEM$STREAM_HAS_DATA:", has_data)

            print("\nDone.")
            print("Next: generate some changes in the source, then query the changelog table.")
            print("  SELECT * FROM " + changelog_fqn + " ORDER BY LOAD_TS DESC LIMIT 100;")
            print("Consumer view (recommended for SQL Server):")
            print("  SELECT * FROM " + consumer_view_fqn + " ORDER BY LOAD_TS DESC LIMIT 100;")

        finally:
            cur.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
