from __future__ import annotations

import argparse

from snowrefactor.snowflake_conn import connect


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("pattern", help="SHOW TERSE TABLES LIKE <pattern> IN ACCOUNT")
    args = ap.parse_args()

    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(f"SHOW TERSE TABLES LIKE '{args.pattern}' IN ACCOUNT")
            rows = cur.fetchall()
            cols = [c[0] for c in cur.description]
            print("cols:", cols)
            print("matches:", len(rows))
            for r in rows[:200]:
                d = dict(zip(cols, r))
                db = d.get("database_name") or d.get("database")
                schema = d.get("schema_name") or d.get("schema")
                name = d.get("name")
                kind = d.get("kind")
                print(f"- {db}.{schema}.{name} ({kind})")
        finally:
            cur.close()


if __name__ == "__main__":
    main()
