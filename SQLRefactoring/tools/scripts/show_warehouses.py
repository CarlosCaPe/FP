from __future__ import annotations

from snowrefactor.snowflake_conn import connect


def main() -> None:
    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute("SHOW WAREHOUSES")
            rows = cur.fetchall()
            desc = [c[0] for c in cur.description]

            def idx(name: str) -> int | None:
                return desc.index(name) if name in desc else None

            ni, si, sti, ti = idx("name"), idx("size"), idx("state"), idx("type")

            print(f"warehouses={len(rows)}")
            for r in rows:
                name = r[ni] if ni is not None else r[0]
                size = r[si] if si is not None else ""
                state = r[sti] if sti is not None else ""
                wtype = r[ti] if ti is not None else ""
                print(f"- {name} | size={size} | state={state} | type={wtype}")
        finally:
            cur.close()


if __name__ == "__main__":
    main()
