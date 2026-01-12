from __future__ import annotations

import argparse

from snowrefactor.snowflake_conn import connect


def _extract_arg_types(arguments_col: str, func_name: str) -> str | None:
    """Return '(TYPE, TYPE, ...)' from SHOW USER FUNCTIONS 'arguments' column.

    The column commonly looks like:
      SENSOR_SNAPSHOT_GET(VARCHAR, BOOLEAN, ARRAY, ARRAY) RETURN TABLE (...)
    We only need the argument type list for GET_DDL.
    """
    if not arguments_col:
        return None
    s = str(arguments_col).strip()
    # Remove leading function name if present
    prefix = f"{func_name}"
    if s.upper().startswith(prefix.upper()):
        s = s[len(prefix) :].lstrip()
    if not s.startswith("("):
        # Try to find the first '(' anywhere
        i = s.find("(")
        if i == -1:
            return None
        s = s[i:]
    # Take up to the matching ')'
    j = s.find(")")
    if j == -1:
        return None
    return s[: j + 1]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--role", default=None)
    ap.add_argument(
        "--fqn",
        required=True,
        help="Fully qualified function name without signature (e.g. SANDBOX_DB.SCHEMA.SENSOR_SNAPSHOT_GET)",
    )
    args = ap.parse_args()

    # This function exists in 2 overloads; fetch both by querying SHOW FUNCTIONS.
    db, schema, name = args.fqn.split(".")

    with connect() as conn:
        cur = conn.cursor()
        try:
            if args.role:
                cur.execute(f'USE ROLE "{args.role}"')
            cur.execute("SELECT CURRENT_ROLE()")
            print("CURRENT_ROLE:", cur.fetchone()[0])

            print(f"Listing overloads via SHOW USER FUNCTIONS in {db}.{schema} ...")

            cur.execute(f"SHOW USER FUNCTIONS LIKE '{name}' IN SCHEMA {db}.{schema}")
            rows = cur.fetchall()
            cols = [c[0] for c in cur.description]
            if not rows:
                raise SystemExit(f"No functions found for {args.fqn}")

            print("SHOW USER FUNCTIONS columns:")
            print(", ".join(cols))

            sig_col = None
            for cand in ("signature", "arguments"):
                if cand in cols:
                    sig_col = cand
                    break
            sig_idx = cols.index(sig_col) if sig_col else None
            for r in rows:
                raw_sig = r[sig_idx] if sig_idx is not None else None
                arg_types = _extract_arg_types(str(raw_sig or ""), name)
                if not arg_types:
                    print(f"Skipping row (could not parse argument types): {raw_sig!r}")
                    continue

                full_sig = f"{db}.{schema}.{name}{arg_types}"
                print(f"Fetching GET_DDL for: {full_sig}")
                safe = full_sig.replace("'", "''")
                cur.execute(f"SELECT GET_DDL('FUNCTION', '{safe}')")
                ddl = cur.fetchone()[0]
                print("=" * 100)
                print(full_sig)
                # Print a small excerpt plus key markers
                markers = ["DEV_GENERAL", "SANDBOX_DATA_ENGINEER", "PROD_DATALAKE", "FCTS_SENSOR_READING"]
                for m in markers:
                    print(f"contains {m}: {m in ddl}")

                # Focused checks for this project
                suffixes = ["SAM", "MOR", "CMX", "SIE", "NMO", "BAG", "CVE"]
                for s in suffixes:
                    dev = f"DEV_GENERAL.TARGET.SENSOR_READING_{s}_B"
                    sbx = f"SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_{s}_B"
                    if (dev in ddl) or (sbx in ddl):
                        print(f"source SENSOR_READING_{s}_B: dev={dev in ddl} sandbox_clone={sbx in ddl}")
                print("--- DDL (first 800 chars) ---")
                print(str(ddl)[:800])
        finally:
            cur.close()


if __name__ == "__main__":
    main()
