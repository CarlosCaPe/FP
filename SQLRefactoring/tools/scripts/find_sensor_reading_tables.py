from __future__ import annotations

from snowrefactor.snowflake_conn import connect

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
                cur.execute(f"SHOW TERSE TABLES LIKE '{t}' IN ACCOUNT")
                rows = cur.fetchall()
                cols = [c[0] for c in cur.description]
                print("=" * 100)
                print(t)
                print("matches:", len(rows))
                for r in rows:
                    d = dict(zip(cols, r))
                    print(f"- {d.get('database_name')}.{d.get('schema_name')}.{d.get('name')} ({d.get('kind')})")
        finally:
            cur.close()


if __name__ == "__main__":
    main()
