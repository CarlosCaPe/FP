from __future__ import annotations

from snowrefactor.snowflake_conn import connect


def _bytes_to_human(n: int | None) -> str:
    if n is None:
        return "?"
    units = [(1024**4, "TB"), (1024**3, "GB"), (1024**2, "MB"), (1024, "KB")]
    for div, u in units:
        if n >= div:
            return f"{n / div:.2f} {u}"
    return f"{n} B"


def main() -> None:
    role = "_AR_GENERAL_DBO_DEV"
    db = "DEV_GENERAL"
    schema = "TARGET"
    pattern = "SENSOR_READING_%_B"

    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(f'USE ROLE "{role}"')
            cur.execute("SELECT CURRENT_ROLE()")
            print("CURRENT_ROLE:", cur.fetchone()[0])

            cur.execute(f"SHOW TABLES LIKE '{pattern}' IN SCHEMA {db}.{schema}")
            rows = cur.fetchall()
            cols = [c[0] for c in cur.description]

            # Normalize/print
            print(f"Tables in {db}.{schema} matching {pattern}: {len(rows)}")

            def get(row, col: str):
                try:
                    return row[cols.index(col)]
                except Exception:
                    return None

            # Sort by bytes desc when available
            def bytes_key(row):
                b = get(row, "bytes")
                try:
                    return int(b)
                except Exception:
                    return -1

            rows_sorted = sorted(rows, key=bytes_key, reverse=True)

            for r in rows_sorted:
                name = get(r, "name")
                kind = get(r, "kind")
                rows_cnt = get(r, "rows")
                bytes_cnt = get(r, "bytes")
                created_on = get(r, "created_on")
                last_altered = get(r, "last_altered")
                clustering_key = get(r, "clustering_key")
                search_optimization = get(r, "search_optimization")
                so_err = get(r, "search_optimization_error")

                bytes_int = None
                try:
                    bytes_int = int(bytes_cnt)
                except Exception:
                    pass

                print("=" * 90)
                print(f"{db}.{schema}.{name}")
                print(f"- kind: {kind}")
                print(f"- created_on: {created_on}")
                if last_altered is not None:
                    print(f"- last_altered: {last_altered}")
                print(f"- rows: {rows_cnt}")
                print(f"- bytes: {bytes_cnt} ({_bytes_to_human(bytes_int)})")
                if clustering_key is not None:
                    print(f"- clustering_key: {clustering_key}")
                if search_optimization is not None:
                    print(f"- search_optimization: {search_optimization}")
                if so_err not in (None, ""):
                    print(f"- search_optimization_error: {so_err}")

        finally:
            cur.close()


if __name__ == "__main__":
    main()
