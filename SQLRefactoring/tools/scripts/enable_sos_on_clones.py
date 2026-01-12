from __future__ import annotations

from snowrefactor.snowflake_conn import connect

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


def main() -> None:
    with connect() as conn:
        cur = conn.cursor()
        try:
            for t in TABLES:
                dst = f"{SANDBOX_DB}.{SANDBOX_SCHEMA}.{SANDBOX_PREFIX}{t}"
                print("=" * 100)
                print(dst)
                try:
                    cur.execute(
                        "ALTER TABLE {dst} ADD SEARCH OPTIMIZATION ON EQUALITY(SITE_CODE, SENSOR_ID)".format(
                            dst=dst
                        )
                    )
                    print("SOS: OK")
                except Exception as e:  # noqa: BLE001
                    print(f"SOS: ERROR: {type(e).__name__}: {e}")
        finally:
            cur.close()


if __name__ == "__main__":
    main()
