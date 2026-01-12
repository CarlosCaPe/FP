from __future__ import annotations

from snowrefactor.snowflake_conn import connect

CANDIDATES = [
    "WH_BATCH_DE_NONPROD",
    "WH_BATCH_DE",
    "WH_FCTS",
    "WH_ANALYST",
    "WH_ADHOC_API",
    "WH_DS",
    "TROIUI_ADHOC",
]


def main() -> None:
    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute("SELECT CURRENT_WAREHOUSE()")
            print("current_warehouse:", cur.fetchone()[0])

            for wh in CANDIDATES:
                print("=" * 80)
                print("warehouse:", wh)
                try:
                    cur.execute(f'USE WAREHOUSE "{wh}"')
                    cur.execute("SELECT CURRENT_WAREHOUSE()")
                    print("- USE ok, now:", cur.fetchone()[0])

                    # Try to read statement timeout parameter
                    try:
                        cur.execute(
                            f"SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT_IN_SECONDS' IN WAREHOUSE {wh}"
                        )
                        row = cur.fetchone()
                        if row:
                            desc = [c[0] for c in cur.description]
                            val = row[desc.index("value")] if "value" in desc else None
                            print("- STATEMENT_TIMEOUT_IN_SECONDS:", val)
                        else:
                            print("- STATEMENT_TIMEOUT_IN_SECONDS: <no row>")
                    except Exception as e:  # noqa: BLE001
                        print("- cannot read warehouse parameter:", type(e).__name__, str(e))

                except Exception as e:  # noqa: BLE001
                    print("- USE failed:", type(e).__name__, str(e))

        finally:
            cur.close()


if __name__ == "__main__":
    main()
