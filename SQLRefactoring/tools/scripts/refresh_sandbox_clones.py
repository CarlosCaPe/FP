from __future__ import annotations

import argparse
import time
from dataclasses import dataclass

from snowrefactor.snowflake_conn import connect


@dataclass(frozen=True)
class TableClone:
    source: str
    target: str


def _parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(
        description=(
            "Refresh sandbox table clones (CREATE OR REPLACE TRANSIENT TABLE ... CLONE ...) "
            "so tests compare against a fresh snapshot."
        )
    )
    ap.add_argument("--role", default=None, help="Optional role to USE ROLE before cloning.")
    ap.add_argument(
        "--source-db",
        default="PROD_DATALAKE",
        help="Source database (default: PROD_DATALAKE)",
    )
    ap.add_argument(
        "--source-schema",
        default="FCTS",
        help="Source schema (default: FCTS)",
    )
    ap.add_argument(
        "--target-db",
        default="SANDBOX_DATA_ENGINEER",
        help="Target database (default: SANDBOX_DATA_ENGINEER)",
    )
    ap.add_argument(
        "--target-schema",
        default="CCARRILL2",
        help="Target schema (default: CCARRILL2)",
    )
    ap.add_argument(
        "--prefix",
        default="FCTS_",
        help="Prefix for target tables (default: FCTS_)",
    )
    ap.add_argument(
        "--suffixes",
        default="SAM,MOR,CMX,SIE,NMO,BAG,CVE",
        help="Comma-separated SENSOR_READING table suffixes to clone.",
    )
    ap.add_argument(
        "--exclude-suffixes",
        default="",
        help=(
            "Comma-separated SENSOR_READING table suffixes to SKIP cloning. "
            "Example: --exclude-suffixes MOR"
        ),
    )
    return ap.parse_args()


def main() -> None:
    args = _parse_args()

    suffixes = [s.strip().upper() for s in str(args.suffixes).split(",") if s.strip()]
    exclude = {s.strip().upper() for s in str(args.exclude_suffixes).split(",") if s.strip()}
    if not suffixes:
        raise SystemExit("No suffixes provided")

    clones: list[TableClone] = []
    for s in suffixes:
        if s in exclude:
            continue
        src = f"{args.source_db}.{args.source_schema}.SENSOR_READING_{s}_B"
        tgt = f"{args.target_db}.{args.target_schema}.{args.prefix}SENSOR_READING_{s}_B"
        clones.append(TableClone(source=src, target=tgt))

    print(
        f"Refreshing {len(clones)} clones into {args.target_db}.{args.target_schema} "
        f"from {args.source_db}.{args.source_schema}..."
    )

    ok = 0
    for c in clones:
        ddl = f"CREATE OR REPLACE TRANSIENT TABLE {c.target} CLONE {c.source}"

        # Reconnect per-table (or per retry) to avoid a single flaky network event
        # aborting the entire refresh.
        last_err: str | None = None
        for attempt in range(1, 4):
            try:
                with connect() as conn:
                    cur = conn.cursor()
                    try:
                        if args.role:
                            cur.execute(f'USE ROLE "{args.role}"')
                        if attempt == 1:
                            cur.execute("SELECT CURRENT_ROLE()")
                            print("CURRENT_ROLE:", cur.fetchone()[0])

                        cur.execute(ddl)
                        ok += 1
                        print(f"- OK: {c.target} <= CLONE {c.source}")
                        last_err = None
                        break
                    finally:
                        cur.close()
            except KeyboardInterrupt as e:  # noqa: BLE001
                # In this environment Snowflake connector sometimes surfaces transient network
                # issues as KeyboardInterrupt. Treat it as retryable unless user repeats it.
                last_err = f"KeyboardInterrupt: {e}"
            except Exception as e:  # noqa: BLE001
                last_err = f"{type(e).__name__}: {e}"

            if attempt < 3:
                time.sleep(2 * attempt)

        if last_err:
            print(f"- ERROR: {c.target} <= {c.source}: {last_err}")

    print(f"Done. OK={ok}/{len(clones)}")


if __name__ == "__main__":
    main()
