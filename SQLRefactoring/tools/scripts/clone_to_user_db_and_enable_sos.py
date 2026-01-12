from __future__ import annotations

from snowrefactor.snowflake_conn import connect

USER_DB = '"USER$CCARRILL2@FMI.COM"'
USER_SCHEMA = 'FCTS'

# Keep it small at first: the two that dominate scans.
TABLES = [
    ('PROD_DATALAKE.FCTS.SENSOR_READING_MOR_B', f'{USER_DB}.{USER_SCHEMA}.SENSOR_READING_MOR_B'),
    ('PROD_DATALAKE.FCTS.SENSOR_READING_NMO_B', f'{USER_DB}.{USER_SCHEMA}.SENSOR_READING_NMO_B'),
]


def main() -> None:
    with connect() as conn:
        cur = conn.cursor()
        try:
            print(f'Ensuring schema exists: {USER_DB}.{USER_SCHEMA}')
            cur.execute(f'CREATE SCHEMA IF NOT EXISTS {USER_DB}.{USER_SCHEMA}')

            for src, dst in TABLES:
                print('=' * 100)
                print(f'CLONE {src} -> {dst}')
                # Source tables are TRANSIENT; clone must also be TRANSIENT
                cur.execute(f'CREATE OR REPLACE TRANSIENT TABLE {dst} CLONE {src}')

            print('=' * 100)
            print('Enabling SOS on user-db clones:')
            for _, dst in TABLES:
                print('-', dst)
                try:
                    cur.execute(
                        f"ALTER TABLE {dst} ADD SEARCH OPTIMIZATION ON EQUALITY(SITE_CODE, SENSOR_ID)"
                    )
                    print('  OK')
                except Exception as e:  # noqa: BLE001
                    print(f'  ERROR: {type(e).__name__}: {e}')

        finally:
            cur.close()


if __name__ == '__main__':
    main()
