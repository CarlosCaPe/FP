from __future__ import annotations

from snowrefactor.snowflake_conn import connect

ROLE = "_AR_GENERAL_DBO_DEV"
DB = "DEV_GENERAL"
SCHEMA = "CCARRILL2_FCTS"

SRC_SCHEMA = "DEV_GENERAL.TARGET"
TABLE = "SENSOR_READING_MOR_B"


def main() -> None:
    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(f'USE ROLE "{ROLE}"')
            cur.execute("SELECT CURRENT_ROLE()")
            print("CURRENT_ROLE:", cur.fetchone()[0])

            print(f"Ensuring schema exists: {DB}.{SCHEMA}")
            cur.execute(f"CREATE SCHEMA IF NOT EXISTS {DB}.{SCHEMA}")

            src = f"{SRC_SCHEMA}.{TABLE}"
            dst = f"{DB}.{SCHEMA}.{TABLE}"

            print(f"CLONE {src} -> {dst}")
            cur.execute(f"CREATE OR REPLACE TRANSIENT TABLE {dst} CLONE {src}")

            print("Enabling SOS...")
            try:
                cur.execute(
                    f"ALTER TABLE {dst} ADD SEARCH OPTIMIZATION ON EQUALITY(SITE_CODE, SENSOR_ID)"
                )
                print("SOS: OK")
            except Exception as e:  # noqa: BLE001
                print(f"SOS: ERROR: {type(e).__name__}: {e}")

        finally:
            cur.close()


if __name__ == "__main__":
    main()
