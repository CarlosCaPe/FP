from __future__ import annotations

import argparse
from pathlib import Path

from snowrefactor.snowflake_conn import connect


HERE = Path(__file__).resolve().parent


def _exec_sql_file(conn, path: Path) -> None:
    sql = path.read_text(encoding="utf-8")
    # SnowflakeConnection.execute_string handles multi-statement scripts.
    conn.execute_string(sql)


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Deploy and run baseline/refactor procedures for DRILLBLAST_DRILL_CYCLE_CT in sandbox. "
            "Uses Snowrefactor .env credentials (externalbrowser recommended)."
        )
    )
    parser.add_argument("--days", default="5", help="Lookback window in days (1..30). Default: 5")
    parser.add_argument("--deploy", action="store_true", help="Run baseline_ddl.sql and refactor_ddl.sql")
    parser.add_argument("--run", action="store_true", help="CALL the baseline and refactor procedures")
    args = parser.parse_args()

    baseline_ddl = HERE / "baseline_ddl.sql"
    refactor_ddl = HERE / "refactor_ddl.sql"

    with connect() as conn:
        if args.deploy:
            print(f"Deploying: {baseline_ddl.name}")
            _exec_sql_file(conn, baseline_ddl)
            print(f"Deploying: {refactor_ddl.name}")
            _exec_sql_file(conn, refactor_ddl)

        if args.run:
            cur = conn.cursor()
            try:
                for proc in [
                    "SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_P_BASE",
                    "SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_P_REF",
                ]:
                    sql = f"CALL {proc}('{args.days}')"
                    print(f"Running: {sql}")
                    cur.execute(sql)
                    row = cur.fetchone()
                    if row:
                        print(row[0])
            finally:
                cur.close()

    print("Done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
