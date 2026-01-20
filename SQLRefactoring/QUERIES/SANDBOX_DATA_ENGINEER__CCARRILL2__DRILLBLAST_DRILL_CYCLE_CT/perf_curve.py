from __future__ import annotations

import argparse
import csv
import datetime as dt
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

from snowrefactor.snowflake_conn import connect


HERE = Path(__file__).resolve().parent
REPORTS_DIR = HERE.parent.parent / "reports"


@dataclass(frozen=True)
class Point:
    days: int
    side: str  # 'baseline' | 'refactor'
    marker: str
    proc_return: str
    focused_elapsed_s: float
    focused_bytes_scanned: int
    focused_rows_produced: int


@dataclass(frozen=True)
class StepPoint:
    days: int
    side: str  # 'baseline' | 'refactor'
    step: str  # 'call' | 'retention_check' | 'retention_delete' | 'delete_old' | 'merge' | 'archive' | 'other'
    query_id: str
    query_text: str
    elapsed_s: float
    bytes_scanned: int
    rows_produced: int


def _utc_stamp() -> str:
    return dt.datetime.now(dt.UTC).strftime("%Y%m%d_%H%M%S")


def _fetch_one(cur, sql: str) -> Any:
    cur.execute(sql)
    row = cur.fetchone()
    return row[0] if row else None


def _get_marker_ts(cur) -> str:
    # Use Snowflake CURRENT_TIMESTAMP so it aligns with query history timestamps.
    return str(_fetch_one(cur, "SELECT CURRENT_TIMESTAMP()"))


def _query_history_by_session_since(cur, marker_ts: str) -> list[dict[str, Any]]:
    # Near-real-time history for the current session.
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


def _matches_any(text: str, needles: Iterable[str]) -> bool:
    t = (text or "").lower()
    return any(n.lower() in t for n in needles)


def _summarize_focus(queries: list[dict[str, Any]], focus_needles: list[str]) -> tuple[float, int, int]:
    # Sum elapsed/bytes/rows for the statements related to the procedure work.
    focused = []
    for q in queries:
        qt = str(q.get("QUERY_TEXT", ""))
        # exclude the history query itself
        if "QUERY_HISTORY_BY_SESSION" in qt.upper():
            continue
        if _matches_any(qt, focus_needles):
            focused.append(q)

    def elapsed_s(q: dict[str, Any]) -> float:
        v = q.get("TOTAL_ELAPSED_TIME")
        if v is None:
            return 0.0
        try:
            return float(v) / 1000.0
        except Exception:
            return 0.0

    total_elapsed = sum(elapsed_s(q) for q in focused)
    total_bytes = sum(int(q.get("BYTES_SCANNED", 0) or 0) for q in focused)
    total_rows = sum(int(q.get("ROWS_PRODUCED", 0) or 0) for q in focused)
    return round(total_elapsed, 3), total_bytes, total_rows


def _elapsed_s(q: dict[str, Any]) -> float:
    v = q.get("TOTAL_ELAPSED_TIME")
    if v is None:
        return 0.0
    try:
        return float(v) / 1000.0
    except Exception:
        return 0.0


def _classify_step(side: str, query_text: str) -> str:
    qt = (query_text or "").strip().upper()

    if qt.startswith("CALL "):
        return "call"

    if side == "refactor":
        if "STEP=DELETE_OLD" in qt or qt.startswith("DELETE FROM SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_REF"):
            return "delete_old"
        if "STEP=MERGE" in qt or qt.startswith("MERGE INTO SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_REF"):
            return "merge"
        if "STEP=ARCHIVE" in qt or qt.startswith("UPDATE SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_REF"):
            return "archive"
        return "other"

    # baseline
    if "COUNT_CHECK" in qt or qt.startswith("SELECT COUNT"):
        return "retention_check"
    if qt.startswith("DELETE FROM SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_BASE"):
        return "retention_delete"
    if qt.startswith("MERGE INTO SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_BASE"):
        return "merge"
    if qt.startswith("UPDATE SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_BASE"):
        return "archive"
    return "other"


def _extract_step_points(days: int, side: str, queries: list[dict[str, Any]]) -> list[StepPoint]:
    out: list[StepPoint] = []
    for q in queries:
        qt = str(q.get("QUERY_TEXT", ""))
        if "QUERY_HISTORY_BY_SESSION" in qt.upper():
            continue

        step = _classify_step(side, qt)

        out.append(
            StepPoint(
                days=days,
                side=side,
                step=step,
                query_id=str(q.get("QUERY_ID", "")),
                query_text=" ".join(qt.split())[:500],
                elapsed_s=round(_elapsed_s(q), 3),
                bytes_scanned=int(q.get("BYTES_SCANNED", 0) or 0),
                rows_produced=int(q.get("ROWS_PRODUCED", 0) or 0),
            )
        )
    return out


def _rollup_steps(step_points: list[StepPoint]) -> dict[tuple[int, str, str], dict[str, Any]]:
    # key: (days, side, step)
    roll: dict[tuple[int, str, str], dict[str, Any]] = {}
    for sp in step_points:
        key = (sp.days, sp.side, sp.step)
        if key not in roll:
            roll[key] = {
                "elapsed_s": 0.0,
                "bytes_scanned": 0,
                "rows_produced": 0,
                "query_ids": [],
            }
        roll[key]["elapsed_s"] += sp.elapsed_s
        roll[key]["bytes_scanned"] += sp.bytes_scanned
        roll[key]["rows_produced"] += sp.rows_produced
        if sp.query_id:
            roll[key]["query_ids"].append(sp.query_id)

    # round elapsed for readability
    for v in roll.values():
        v["elapsed_s"] = round(float(v["elapsed_s"]), 3)
    return roll


def _write_csv(path: Path, points: list[Point]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "days",
                "side",
                "focused_elapsed_s",
                "focused_bytes_scanned",
                "focused_rows_produced",
                "marker",
                "proc_return",
            ]
        )
        for p in points:
            w.writerow(
                [
                    p.days,
                    p.side,
                    p.focused_elapsed_s,
                    p.focused_bytes_scanned,
                    p.focused_rows_produced,
                    p.marker,
                    p.proc_return,
                ]
            )


def _write_steps_csv(path: Path, step_points: list[StepPoint]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "days",
                "side",
                "step",
                "elapsed_s",
                "bytes_scanned",
                "rows_produced",
                "query_id",
                "query_text",
            ]
        )
        for sp in step_points:
            w.writerow(
                [
                    sp.days,
                    sp.side,
                    sp.step,
                    sp.elapsed_s,
                    sp.bytes_scanned,
                    sp.rows_produced,
                    sp.query_id,
                    sp.query_text,
                ]
            )


def _write_md(path: Path, points: list[Point], start_days: int, end_days: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    def pick(days: int, side: str) -> Point | None:
        for p in points:
            if p.days == days and p.side == side:
                return p
        return None

    lines: list[str] = []
    lines.append(f"# Perf Curve: {HERE.name}")
    lines.append(f"Generated (UTC): {dt.datetime.now(dt.UTC).isoformat()}")
    lines.append("")
    lines.append("## What this is")
    lines.append(
        "Runs baseline and refactor stored procedures for increasing lookback windows and pulls real metrics from "
        "`INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION()` (elapsed seconds, bytes scanned)."
    )
    lines.append("")
    lines.append(f"- days range: {start_days}..{end_days}")
    lines.append(f"- points per side: {end_days - start_days + 1}")
    lines.append("")

    lines.append("## Curve (focused totals)")
    lines.append("| days | baseline_elapsed_s | refactor_elapsed_s | baseline_bytes_scanned | refactor_bytes_scanned | speedup (baseline/refactor) |")
    lines.append("|---:|---:|---:|---:|---:|---:|")
    for d in range(start_days, end_days + 1):
        b = pick(d, "baseline")
        r = pick(d, "refactor")
        if not b or not r:
            continue
        speedup = (b.focused_elapsed_s / r.focused_elapsed_s) if r.focused_elapsed_s else None
        speedup_s = f"{speedup:.3f}" if speedup is not None else ""
        lines.append(
            f"| {d} | {b.focused_elapsed_s:.3f} | {r.focused_elapsed_s:.3f} | {b.focused_bytes_scanned} | {r.focused_bytes_scanned} | {speedup_s} |"
        )

    lines.append("")

    # Add step-level rollup for each day.
    # (This is intentionally verbose; the CSV is easier to graph/pivot.)
    lines.append("## Step Breakdown (per day)")
    lines.append("This section shows where time/scan goes (merge vs archive vs retention).")
    lines.append("")

    # Load step rollup from the sidecar CSV if present next to the MD.
    # The writer in main creates it in the same reports folder with matching stamp.
    steps_csv_guess = path.with_suffix(".steps.csv")
    if steps_csv_guess.exists():
        # very small parser (no pandas)
        with steps_csv_guess.open("r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            step_points = [
                StepPoint(
                    days=int(r["days"]),
                    side=r["side"],
                    step=r["step"],
                    elapsed_s=float(r["elapsed_s"]),
                    bytes_scanned=int(r["bytes_scanned"]),
                    rows_produced=int(r["rows_produced"]),
                    query_id=r["query_id"],
                    query_text=r["query_text"],
                )
                for r in reader
            ]

        roll = _rollup_steps(step_points)
        steps = ["retention_check", "retention_delete", "delete_old", "merge", "archive", "other"]
        for d in range(start_days, end_days + 1):
            lines.append(f"### days = {d}")
            lines.append("| step | baseline_elapsed_s | refactor_elapsed_s | baseline_bytes | refactor_bytes |")
            lines.append("|---|---:|---:|---:|---:|")
            for step in steps:
                b = roll.get((d, "baseline", step), {"elapsed_s": 0.0, "bytes_scanned": 0})
                r = roll.get((d, "refactor", step), {"elapsed_s": 0.0, "bytes_scanned": 0})
                lines.append(
                    f"| {step} | {b['elapsed_s']:.3f} | {r['elapsed_s']:.3f} | {b['bytes_scanned']} | {r['bytes_scanned']} |"
                )
            lines.append("")
    else:
        lines.append("(Step CSV not found next to this report.)")
        lines.append("")
    lines.append("## Notes")
    lines.append("- Order alternates per day to reduce cache bias (odd days baseline→refactor, even days refactor→baseline).")
    lines.append("- Focused metrics filter on procedure/table names so we don’t confuse the run with unrelated session queries.")
    lines.append("")

    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Generate a baseline vs refactor performance curve by running both stored procedures for days=1..30 "
            "and extracting elapsed/scan metrics from INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION()."
        )
    )
    parser.add_argument("--start-days", type=int, default=1)
    parser.add_argument("--end-days", type=int, default=30)
    args = parser.parse_args()

    if args.start_days < 1 or args.end_days < args.start_days:
        raise SystemExit("Invalid day range")

    base_proc = "SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_P_BASE"
    ref_proc = "SANDBOX_DATA_ENGINEER.CCARRILL2.DRILLBLAST_DRILL_CYCLE_CT_P_REF"

    base_needles = [
        "DRILLBLAST_DRILL_CYCLE_CT_P_BASE",
        "DRILLBLAST_DRILL_CYCLE_CT_BASE",
        "prod_target.collections.drillblast_drill_cycle_dt",
    ]
    ref_needles = [
        "DRILLBLAST_DRILL_CYCLE_CT_P_REF",
        "DRILLBLAST_DRILL_CYCLE_CT_REF",
        "snowrefactor_tag=",
        "prod_target.collections.drillblast_drill_cycle_dt",
    ]

    points: list[Point] = []
    step_points: list[StepPoint] = []

    with connect() as conn:
        cur = conn.cursor()
        try:
            session_id = _fetch_one(cur, "SELECT CURRENT_SESSION()")
            print(f"Session: {session_id}")

            for days in range(args.start_days, args.end_days + 1):
                # Alternate order to reduce cache bias.
                if days % 2 == 1:
                    plan = [("baseline", base_proc, base_needles), ("refactor", ref_proc, ref_needles)]
                else:
                    plan = [("refactor", ref_proc, ref_needles), ("baseline", base_proc, base_needles)]

                for side, proc, needles in plan:
                    marker = _get_marker_ts(cur)
                    sql = f"CALL {proc}('{days}')"
                    print(f"Running: days={days} side={side}: {sql}")
                    cur.execute(sql)
                    row = cur.fetchone()
                    proc_return = str(row[0]) if row else ""

                    queries = _query_history_by_session_since(cur, marker)
                    elapsed_s, bytes_scanned, rows_prod = _summarize_focus(queries, needles)

                    step_points.extend(_extract_step_points(days, side, queries))

                    points.append(
                        Point(
                            days=days,
                            side=side,
                            marker=marker,
                            proc_return=proc_return,
                            focused_elapsed_s=elapsed_s,
                            focused_bytes_scanned=bytes_scanned,
                            focused_rows_produced=rows_prod,
                        )
                    )

        finally:
            cur.close()

    stamp = _utc_stamp()
    csv_path = REPORTS_DIR / f"{HERE.name}__curve__{stamp}.csv"
    md_path = REPORTS_DIR / f"{HERE.name}__curve__{stamp}.md"
    steps_csv_path = REPORTS_DIR / f"{HERE.name}__curve__{stamp}.steps.csv"
    _write_csv(csv_path, points)
    _write_steps_csv(steps_csv_path, step_points)
    _write_md(md_path, points, args.start_days, args.end_days)

    print(f"Wrote CSV: {csv_path}")
    print(f"Wrote steps CSV: {steps_csv_path}")
    print(f"Wrote MD:  {md_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
