from __future__ import annotations

from snowrefactor.snowflake_conn import connect


def main() -> None:
    targets = [
        "PROD_DATALAKE.FCTS.PI_AF_ATTRIBUTE",
        "PROD_DATALAKE.FCTS.PI_POINT",
    ]

    with connect() as conn:
        cur = conn.cursor()
        try:
            for full in targets:
                db, schema, name = full.split(".")
                cur.execute(f"SHOW VIEWS LIKE '{name}' IN SCHEMA {db}.{schema}")
                rows = cur.fetchall()
                print("=" * 80)
                print(full)
                print(f"views: {len(rows)}")
                if not rows:
                    continue

                desc = [c[0] for c in cur.description]
                r = rows[0]

                def get(col: str):
                    try:
                        return r[desc.index(col)]
                    except Exception:
                        return None

                print(f"- created_on: {get('created_on')}")
                print(f"- name: {get('name')}")
                print(f"- is_secure: {get('is_secure')}")
                print(f"- comment: {get('comment')}")
        finally:
            cur.close()


if __name__ == "__main__":
    main()
