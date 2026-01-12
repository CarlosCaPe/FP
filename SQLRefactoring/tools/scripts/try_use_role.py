from __future__ import annotations

from snowrefactor.snowflake_conn import connect


def main() -> None:
    role = "_AR_GENERAL_DBO_DEV"
    with connect() as conn:
        cur = conn.cursor()
        try:
            try:
                cur.execute(f'USE ROLE "{role}"')
                cur.execute("SELECT CURRENT_ROLE()")
                print("CURRENT_ROLE after USE ROLE:", cur.fetchone()[0])
            except Exception as e:  # noqa: BLE001
                print(f"USE ROLE failed: {type(e).__name__}: {e}")
        finally:
            cur.close()


if __name__ == "__main__":
    main()
