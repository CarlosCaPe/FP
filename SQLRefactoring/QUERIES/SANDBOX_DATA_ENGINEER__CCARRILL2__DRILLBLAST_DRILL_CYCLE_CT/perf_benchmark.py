from __future__ import annotations

import argparse
import datetime as dt
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

from snowrefactor.snowflake_conn import connect


HERE = Path(__file__).resolve().parent
REPORTS_DIR = HERE.parent.parent / "reports"


@dataclass(frozen=True)
class RunResult:
    label: str
    marker_utc: str
    proc_return: str
    queries: list[dict[str, Any]]


def _utc_now_compact() -> str:
    return dt.datetime.now(dt.UTC).strftime("%Y%m%d_%H%M%S")


def _fetch_one(cur, sql: str) -> Any:
    cur.execute(sql)
    row = cur.fetchone()
    return row[0] if row else None


def _get_marker_ts(cur) -> str:
    # Use Snowflake's CURRENT_TIMESTAMP so it lines up with query history timestamps.
    return str(_fetch_one(cur, "SELECT CURRENT_TIMESTAMP()"))


def _query_history_by_session(cur, marker_ts: str) -> list[dict[str, Any]]:
    # INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION() is near-real-time (vs ACCOUNT_USAGE delay).
    # Note: we keep the WHERE filter coarse and do detailed filtering client-side.
    sql = """
SELECT *
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION())
WHERE START_TIME >= TO_TIMESTAMP_LTZ(%(marker)s)
ORDER BY START_TIME
"""
    cur.execute(sql, {"marker": marker_ts})
    cols = [c[0] for c in cur.description]
    out: list[dict[str, Any]] = []
    for row in cur.fetchall():
        out.append({cols[i]: row[i] for i in range(len(cols))})
    return out


def _normalize_sql(sql: str) -> str:
    return re.sub(r"\s+", " ", (sql or "").strip())


def _matches_any(text: str, needles: Iterable[str]) -> bool:
    t = (text or "").lower()
    return any(n.lower() in t for n in needles)


def _summarize_queries(queries: list[dict[str, Any]], focus_needles: list[str]) -> dict[str, Any]:
    # Prefer these canonical fields if present.
    def get(q: dict[str, Any], key: str, default=None):
        return q.get(key) if key in q else default

    focused = [q for q in queries if _matches_any(str(get(q, "QUERY_TEXT", "")), focus_needles)]

    def elapsed_s(q: dict[str, Any]) -> float:
        # TOTAL_ELAPSED_TIME is milliseconds.
        v = get(q, "TOTAL_ELAPSED_TIME")
        if v is None:
            return 0.0
        try:
            return float(v) / 1000.0
        except Exception:
            return 0.0

    total_elapsed = sum(elapsed_s(q) for q in focused)
    total_bytes = sum(int(get(q, "BYTES_SCANNED", 0) or 0) for q in focused)
    total_part_scanned = sum(int(get(q, "PARTITIONS_SCANNED", 0) or 0) for q in focused)

    # Show top offenders by elapsed time.
    top = sorted(focused, key=elapsed_s, reverse=True)[:10]
    top_rows = []
    for q in top:
        top_rows.append(
            {
                "QUERY_ID": get(q, "QUERY_ID"),
                "ELAPSED_S": round(elapsed_s(q), 3),
                "BYTES_SCANNED": int(get(q, "BYTES_SCANNED", 0) or 0),
                "PARTITIONS_SCANNED": int(get(q, "PARTITIONS_SCANNED", 0) or 0),
                "ROWS_PRODUCED": int(get(q, "ROWS_PRODUCED", 0) or 0),
                "QUERY_TEXT": _normalize_sql(str(get(q, "QUERY_TEXT", "")))[:280],
            }
        )

    return {
        "focused_count": len(focused),
        "total_elapsed_s": round(total_elapsed, 3),
        "total_bytes_scanned": total_bytes,
        "total_partitions_scanned": total_part_scanned,
        "top_queries": top_rows,
    }


def _write_report(path: Path, runs: list[RunResult]) -> None:
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    lines: list[str] = []
    lines.append(f"# Perf Benchmark: {HERE.name}")
    lines.append(f"Generated (UTC): {dt.datetime.now(dt.UTC).isoformat()}")
    lines.append("")
    lines.append("## What this proves")
    lines.append(
        "This benchmarks the **stored procedures** (not the `snowrefactor compare` SELECT timings) by extracting query metrics "
        "from `INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION()` for the same connection/session."
    )
    lines.append("")

    base_needles = [
        "DRILLBLAST_DRILL_CYCLE_CT_BASE",
        "DRILLBLAST_DRILL_CYCLE_CT_P_BASE",
        "prod_target.collections.drillblast_drill_cycle_dt",
        " MINUS ",
    ]
    ref_needles = [
        "DRILLBLAST_DRILL_CYCLE_CT_REF",
        "DRILLBLAST_DRILL_CYCLE_CT_P_REF",
        "snowrefactor_tag=",
        "prod_target.collections.drillblast_drill_cycle_dt",
    ]

    # Quick rollup for stakeholders.
    lines.append("## Quick Rollup (Focused)")
    lines.append("This is the same data as below, just summarized.")
    lines.append("")
    lines.append("| run | focused_elapsed_s | focused_bytes_scanned |")
    lines.append("|---|---:|---:|")
    for run in runs:
        needles = ref_needles if "refactor" in run.label else base_needles
        summary = _summarize_queries(run.queries, needles)
        lines.append(
            f"| {run.label} | {summary['total_elapsed_s']} | {summary['total_bytes_scanned']} |"
        )
    lines.append("")

    for run in runs:
        lines.append(f"## Run: {run.label}")
        lines.append(f"- marker_utc: {run.marker_utc}")
        lines.append(f"- procedure_return: {run.proc_return}")

        needles = ref_needles if "refactor" in run.label else base_needles
        summary = _summarize_queries(run.queries, needles)

        lines.append("")
        lines.append("**Focused summary**")
        lines.append(f"- focused_query_count: {summary['focused_count']}")
        lines.append(f"- focused_total_elapsed_s: {summary['total_elapsed_s']}")
        lines.append(f"- focused_total_bytes_scanned: {summary['total_bytes_scanned']}")
        lines.append(f"- focused_total_partitions_scanned: {summary['total_partitions_scanned']}")
        lines.append("")

        lines.append("**Top queries (focused)**")
        for q in summary["top_queries"]:
            lines.append(
                "- "
                + json.dumps(
                    {
                        "QUERY_ID": q["QUERY_ID"],
                        "ELAPSED_S": q["ELAPSED_S"],
                        "BYTES_SCANNED": q["BYTES_SCANNED"],
                        "PARTITIONS_SCANNED": q["PARTITIONS_SCANNED"],
                        "ROWS_PRODUCED": q["ROWS_PRODUCED"],
                        "QUERY_TEXT": q["QUERY_TEXT"],
                    },
                    ensure_ascii=False,
                )
            )
        lines.append("")

    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Run a robust baseline vs refactor benchmark by executing both procedures multiple times and pulling elapsed/scan metrics "
            "from INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION() for each run."
        )
    )
    parser.add_argument("--days", default="30", help="Lookback window in days. Default: 30")
    parser.add_argument("--repeats", type=int, default=2, help="How many times to run each procedure (interleaved). Default: 2")
    args = parser.parse_args()

    base_proc = "SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_P_BASE"
    ref_proc = "SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_P_REF"

    runs: list[RunResult] = []

    with connect() as conn:
        cur = conn.cursor()
        try:
            session_id = _fetch_one(cur, "SELECT CURRENT_SESSION()")
            print(f"Session: {session_id}")

            # Interleave runs to reduce cache bias.
            for i in range(1, args.repeats + 1):
                for label, proc in [(f"baseline_run_{i}", base_proc), (f"refactor_run_{i}", ref_proc)]:
                    marker = _get_marker_ts(cur)
                    sql = f"CALL {proc}('{args.days}')"
                    print(f"Running: {label}: {sql}")
                    cur.execute(sql)
                    row = cur.fetchone()
                    proc_return = str(row[0]) if row else ""

                    # Pull query history since marker and attach.
                    queries = _query_history_by_session(cur, marker)
                    runs.append(RunResult(label=label, marker_utc=marker, proc_return=proc_return, queries=queries))
                    print(f"Captured {len(queries)} queries since marker")

        finally:
            cur.close()

    stamp = _utc_now_compact()
    report_path = REPORTS_DIR / f"{HERE.name}__perf__{stamp}.md"
    _write_report(report_path, runs)
    print(f"Wrote report: {report_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
