from __future__ import annotations

from dataclasses import dataclass

from snowrefactor.snowflake_conn import connect


@dataclass(frozen=True)
class Result:
    table: str
    exists: bool
    altered: bool
    error: str | None
    search_optimization: str | None
    search_optimization_error: str | None


def _show_table_row(cur, db: str, schema: str, name: str) -> dict[str, object] | None:
    cur.execute(f"SHOW TABLES LIKE '{name}' IN SCHEMA {db}.{schema}")
    rows = cur.fetchall()
    if not rows:
        return None
    cols = [c[0] for c in cur.description]
    return dict(zip(cols, rows[0]))


def main() -> None:
    role = "_AR_GENERAL_DBO_DEV"
    db = "DEV_GENERAL"
    schema = "TARGET"

    # Tables we care about; we will also validate existence.
    suffixes = ["SAM", "MOR", "CMX", "SIE", "NMO", "BAG", "CVE"]
    tables = [f"{db}.{schema}.SENSOR_READING_{s}_B" for s in suffixes]

    print(f"Using role: {role}")
    print(f"Target schema: {db}.{schema}")

    results: list[Result] = []

    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(f'USE ROLE "{role}"')
            cur.execute("SELECT CURRENT_ROLE()")
            print("CURRENT_ROLE:", cur.fetchone()[0])

            for full in tables:
                tdb, tschema, tname = full.split(".")
                before = _show_table_row(cur, tdb, tschema, tname)
                if before is None:
                    results.append(
                        Result(
                            table=full,
                            exists=False,
                            altered=False,
                            error=None,
                            search_optimization=None,
                            search_optimization_error=None,
                        )
                    )
                    print(f"- {full}: MISSING")
                    continue

                err: str | None = None
                altered = False
                try:
                    cur.execute(
                        f"ALTER TABLE {full} ADD SEARCH OPTIMIZATION ON EQUALITY(SITE_CODE, SENSOR_ID)"
                    )
                    altered = True
                    print(f"- {full}: ALTER OK")
                except Exception as e:  # noqa: BLE001
                    err = f"{type(e).__name__}: {e}"
                    print(f"- {full}: ALTER ERROR: {err}")

                after = _show_table_row(cur, tdb, tschema, tname)
                so = None
                so_err = None
                if after is not None:
                    so = str(after.get("search_optimization")) if "search_optimization" in after else None
                    so_err = (
                        str(after.get("search_optimization_error"))
                        if "search_optimization_error" in after
                        else None
                    )

                results.append(
                    Result(
                        table=full,
                        exists=True,
                        altered=altered,
                        error=err,
                        search_optimization=so,
                        search_optimization_error=so_err,
                    )
                )

        finally:
            cur.close()

    print("\nSummary")
    ok = [r for r in results if r.exists and r.search_optimization == "ON"]
    missing = [r for r in results if not r.exists]
    failed = [r for r in results if r.exists and r.search_optimization != "ON"]

    print(f"- ON: {len(ok)}")
    if missing:
        print(f"- MISSING: {len(missing)}")
        for r in missing:
            print(f"  - {r.table}")
    if failed:
        print(f"- NOT ON / FAILED: {len(failed)}")
        for r in failed:
            detail = r.error or (r.search_optimization_error or "unknown")
            print(f"  - {r.table}: {r.search_optimization} ({detail})")


if __name__ == "__main__":
    main()
