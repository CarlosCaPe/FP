from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from time import perf_counter
from typing import Any

from snowrefactor.snowflake_conn import connect
from snowrefactor.findings import FindingsInputs, write_findings_md


@dataclass(frozen=True)
class ExecutionStats:
    label: str
    query_id: str | None
    seconds: float
    explain_text: str | None
    history: dict[str, Any] | None


def _fetch_one_row_as_dict(cur) -> dict[str, Any] | None:
    row = cur.fetchone()
    if row is None:
        return None
    cols = [d[0] for d in (cur.description or [])]
    return {cols[i]: row[i] for i in range(min(len(cols), len(row)))}


def _query_history_for_query_id(conn, query_id: str) -> dict[str, Any] | None:
    # Best-effort: different Snowflake accounts expose different INFORMATION_SCHEMA functions.
    candidates = [
        ("SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_QUERY_ID(%s))", (query_id,)),
        ("SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION()) WHERE QUERY_ID = %s", (query_id,)),
    ]

    for sql, params in candidates:
        cur = conn.cursor()
        try:
            cur.execute(sql, params)
            return _fetch_one_row_as_dict(cur)
        except Exception:
            # fall through to next candidate
            pass
        finally:
            cur.close()

    return None


def _explain_text(conn, sql: str) -> str | None:
    # EXPLAIN is cheap and helps spot pruning / join explosion patterns.
    cur = conn.cursor()
    try:
        cur.execute("EXPLAIN USING TEXT " + sql.strip().rstrip(";"))
        rows = cur.fetchall() or []
        # Snowflake returns one column lines.
        lines = [str(r[0]) for r in rows if r and r[0] is not None]
        return "\n".join(lines).strip() or None
    except Exception:
        return None
    finally:
        cur.close()


def execute_and_analyze(*, label: str, sql: str) -> ExecutionStats:
    t0 = perf_counter()
    with connect() as conn:
        # Tag queries for easier inspection in UI/history.
        tag = f"snowrefactor:{label}:{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}"
        cur = conn.cursor()
        try:
            cur.execute("ALTER SESSION SET QUERY_TAG = %s", (tag,))
        finally:
            cur.close()

        explain = _explain_text(conn, sql)

        cur = conn.cursor()
        try:
            cur.execute(sql.strip().rstrip(";"))
            query_id = getattr(cur, "sfqid", None)
        finally:
            cur.close()

        history = _query_history_for_query_id(conn, str(query_id)) if query_id else None

    t1 = perf_counter()
    return ExecutionStats(
        label=label,
        query_id=str(query_id) if query_id else None,
        seconds=t1 - t0,
        explain_text=explain,
        history=history,
    )


def analyze_folder(*, folder: Path, reports_dir: Path) -> Path:
    baseline_path = folder / "baseline.sql"
    refactor_path = folder / "refactor.sql"

    if not baseline_path.exists() or not refactor_path.exists():
        raise FileNotFoundError("Expected baseline.sql and refactor.sql in folder")

    baseline_sql = baseline_path.read_text(encoding="utf-8")
    refactor_sql = refactor_path.read_text(encoding="utf-8")

    reports_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")

    started = datetime.now(timezone.utc)
    wall_t0 = perf_counter()

    # Run sequentially by default: stats are easier to interpret (warehouse/cache contention).
    base = execute_and_analyze(label="baseline", sql=baseline_sql)
    ref = execute_and_analyze(label="refactor", sql=refactor_sql)

    wall_t1 = perf_counter()
    ended = datetime.now(timezone.utc)

    payload: dict[str, Any] = {
        "folder": str(folder.name),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "timing": {
            "started_at_utc": started.isoformat(),
            "ended_at_utc": ended.isoformat(),
            "wall_seconds": wall_t1 - wall_t0,
            "baseline_seconds": base.seconds,
            "refactor_seconds": ref.seconds,
        },
        "baseline": {
            "query_id": base.query_id,
            "history": base.history,
        },
        "refactor": {
            "query_id": ref.query_id,
            "history": ref.history,
        },
    }

    json_path = reports_dir / f"analyze__{folder.name}__{stamp}.json"
    md_path = reports_dir / f"analyze__{folder.name}__{stamp}.md"
    explain_base_path = reports_dir / f"analyze__{folder.name}__{stamp}__baseline_explain.txt"
    explain_ref_path = reports_dir / f"analyze__{folder.name}__{stamp}__refactor_explain.txt"

    json_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False, default=str), encoding="utf-8")

    if base.explain_text:
        explain_base_path.write_text(base.explain_text + "\n", encoding="utf-8")
    if ref.explain_text:
        explain_ref_path.write_text(ref.explain_text + "\n", encoding="utf-8")

    findings_inputs = FindingsInputs(
        query_folder=folder.name,
        generated_at_utc=payload["generated_at"],
        baseline_query_id=base.query_id,
        refactor_query_id=ref.query_id,
        baseline_history=base.history,
        refactor_history=ref.history,
        baseline_explain_path=explain_base_path.name if base.explain_text else None,
        refactor_explain_path=explain_ref_path.name if ref.explain_text else None,
        baseline_seconds=base.seconds,
        refactor_seconds=ref.seconds,
    )
    write_findings_md(folder=folder, inputs=findings_inputs)

    def _fmt_hist(h: dict[str, Any] | None) -> str:
        if not h:
            return "(no history available via INFORMATION_SCHEMA)"
        keys = [
            "EXECUTION_STATUS",
            "TOTAL_ELAPSED_TIME",
            "EXECUTION_TIME",
            "COMPILATION_TIME",
            "BYTES_SCANNED",
            "PERCENTAGE_SCANNED_FROM_CACHE",
            "BYTES_SPILLED_TO_LOCAL_STORAGE",
            "BYTES_SPILLED_TO_REMOTE_STORAGE",
            "PARTITIONS_SCANNED",
            "PARTITIONS_TOTAL",
            "ROWS_PRODUCED",
        ]
        present = [k for k in keys if k in h]
        lines = [f"- {k}: {h.get(k)}" for k in present]
        return "\n".join(lines) if lines else "(history columns not present)"

    md_lines: list[str] = []
    md_lines.append(f"# Analyze Report: {folder.name}\n")
    md_lines.append(f"Generated (UTC): {payload['generated_at']}\n\n")
    t = payload["timing"]
    md_lines.append("## Timing\n")
    md_lines.append(f"- wall_seconds: {t['wall_seconds']:.3f}\n")
    md_lines.append(f"- baseline_seconds: {t['baseline_seconds']:.3f}\n")
    md_lines.append(f"- refactor_seconds: {t['refactor_seconds']:.3f}\n\n")

    md_lines.append("## Baseline\n")
    md_lines.append(f"- query_id: {base.query_id}\n")
    md_lines.append(_fmt_hist(base.history) + "\n\n")

    md_lines.append("## Refactor\n")
    md_lines.append(f"- query_id: {ref.query_id}\n")
    md_lines.append(_fmt_hist(ref.history) + "\n\n")

    md_lines.append("---\n")
    md_lines.append(f"JSON: {json_path.name}\n")
    md_lines.append(f"Findings: {folder / 'FINDINGS.md'}\n")
    if base.explain_text:
        md_lines.append(f"Baseline EXPLAIN: {explain_base_path.name}\n")
    if ref.explain_text:
        md_lines.append(f"Refactor EXPLAIN: {explain_ref_path.name}\n")

    md_path.write_text("".join(md_lines), encoding="utf-8")
    return md_path
