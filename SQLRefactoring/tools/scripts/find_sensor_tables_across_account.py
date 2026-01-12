from __future__ import annotations

from snowrefactor.snowflake_conn import connect


def main() -> None:
    pattern = "SENSOR_READING_MOR_B"
    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(f"SHOW TERSE TABLES LIKE '{pattern}' IN ACCOUNT")
            rows = cur.fetchall()
            cols = [c[0] for c in cur.description]
            print("cols:", cols)
            print("matches:", len(rows))
            # Print a compact view of the first 50 matches
            for r in rows[:50]:
                d = dict(zip(cols, r))
                # Columns vary; common ones: database_name, schema_name, name, kind
                db = d.get("database_name") or d.get("database")
                schema = d.get("schema_name") or d.get("schema")
                name = d.get("name")
                kind = d.get("kind")
                print(f"- {db}.{schema}.{name} ({kind})")
        finally:
            cur.close()


if __name__ == "__main__":
    main()
