from __future__ import annotations

from snowrefactor.snowflake_conn import connect


PROD_SCHEMA = "PROD_DATALAKE.FCTS"
SANDBOX_DB = "SANDBOX_DATA_ENGINEER"
SANDBOX_SCHEMA = "CCARRILL2"
SANDBOX_PREFIX = "FCTS_"

TABLES = [
    "SENSOR_READING_SAM_B",
    "SENSOR_READING_MOR_B",
    "SENSOR_READING_CMX_B",
    "SENSOR_READING_SIE_B",
    "SENSOR_READING_NMO_B",
    "SENSOR_READING_BAG_B",
    "SENSOR_READING_CVE_B",
]


def exec_one(cur, sql: str) -> None:
    cur.execute(sql)


def main() -> None:
    with connect() as conn:
        cur = conn.cursor()
        try:
            for t in TABLES:
                src = f"{PROD_SCHEMA}.{t}"
                dst = f"{SANDBOX_DB}.{SANDBOX_SCHEMA}.{SANDBOX_PREFIX}{t}"
                print("=" * 100)
                print(f"CLONE {src} -> {dst}")
                exec_one(cur, f"CREATE OR REPLACE TRANSIENT TABLE {dst} CLONE {src}")

            print("=" * 100)
            print("Enabling Search Optimization (SOS) on clones:")
            for t in TABLES:
                dst = f"{SANDBOX_DB}.{SANDBOX_SCHEMA}.{SANDBOX_PREFIX}{t}"
                print("-", dst)

                # Prefer the EQUALITY form; if the account uses a different syntax, this will error
                # and we can adjust.
                try:
                    exec_one(
                        cur,
                        "ALTER TABLE {dst} ADD SEARCH OPTIMIZATION ON EQUALITY(SITE_CODE, SENSOR_ID)".format(
                            dst=dst
                        ),
                    )
                    print("  OK")
                except Exception as e:  # noqa: BLE001
                    print(f"  ERROR: {type(e).__name__}: {e}")

        finally:
            cur.close()


if __name__ == "__main__":
    main()
