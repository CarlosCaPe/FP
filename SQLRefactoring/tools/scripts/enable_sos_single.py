from __future__ import annotations

import argparse

from snowrefactor.snowflake_conn import connect


def _parse_table_fqn(table: str) -> tuple[str, str, str]:
    parts = [p for p in table.split(".") if p]
    if len(parts) != 3:
        raise ValueError(
            f"Expected fully-qualified table name DB.SCHEMA.TABLE, got: {table!r}"
        )
    return parts[0], parts[1], parts[2]


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Attempt to enable Snowflake Search Optimization Service (SOS) on a table."
    )
    parser.add_argument(
        "--role",
        default="_AR_GENERAL_DBO_DEV",
        help='Role to USE ROLE (default: "_AR_GENERAL_DBO_DEV").',
    )
    parser.add_argument(
        "--table",
        default="SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_MOR_B",
        help="Fully-qualified table name DB.SCHEMA.TABLE.",
    )
    parser.add_argument(
        "--equality-cols",
        default="SITE_CODE,SENSOR_ID",
        help="Comma-separated columns to include in EQUALITY(...)",
    )
    return parser.parse_args()


def main() -> None:
    args = _parse_args()
    role = args.role
    table = args.table
    db, schema, name = _parse_table_fqn(table)
    equality_cols = ",".join([c.strip() for c in args.equality_cols.split(",") if c.strip()])
    if not equality_cols:
        raise ValueError("--equality-cols must contain at least one column")

    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(f'USE ROLE "{role}"')
            cur.execute("SELECT CURRENT_ROLE()")
            print("CURRENT_ROLE:", cur.fetchone()[0])

            try:
                cur.execute(
                    "ALTER TABLE {t} ADD SEARCH OPTIMIZATION ON EQUALITY({cols})".format(
                        t=table,
                        cols=equality_cols,
                    )
                )
                print("ALTER SOS: OK")
            except Exception as e:  # noqa: BLE001
                print(f"ALTER SOS: ERROR: {type(e).__name__}: {e}")

            # Best-effort check: SHOW TABLES often includes search_optimization column
            try:
                cur.execute(f"SHOW TABLES LIKE '{name}' IN SCHEMA {db}.{schema}")
                rows = cur.fetchall()
                cols = [c[0] for c in cur.description]
                if rows:
                    d = dict(zip(cols, rows[0]))
                    if "search_optimization" in d:
                        print("search_optimization:", d.get("search_optimization"))
                    if "search_optimization_error" in d:
                        print("search_optimization_error:", d.get("search_optimization_error"))
            except Exception:
                pass

        finally:
            cur.close()


if __name__ == "__main__":
    main()
