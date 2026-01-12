from __future__ import annotations

from snowrefactor.snowflake_conn import connect


def main() -> None:
    user = "CCARRILL2@FMI.COM"
    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(f'SHOW GRANTS TO USER "{user}"')
            rows = cur.fetchall()
            cols = [c[0] for c in cur.description]
            print("cols:", cols)
            print("rowcount:", len(rows))
            for r in rows[:20]:
                d = dict(zip(cols, r))
                print(d)
        finally:
            cur.close()


if __name__ == "__main__":
    main()
