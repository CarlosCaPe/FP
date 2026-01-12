from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


USER_NOTES_START = "<!-- USER_NOTES_START -->"
USER_NOTES_END = "<!-- USER_NOTES_END -->"


@dataclass(frozen=True)
class FindingsInputs:
    query_folder: str
    generated_at_utc: str
    baseline_query_id: str | None
    refactor_query_id: str | None
    baseline_history: dict[str, Any] | None
    refactor_history: dict[str, Any] | None
    baseline_explain_path: str | None
    refactor_explain_path: str | None
    baseline_seconds: float
    refactor_seconds: float


def _get(h: dict[str, Any] | None, key: str) -> Any:
    return None if not h else h.get(key)


def _num(v: Any) -> float | None:
    try:
        if v is None:
            return None
        return float(v)
    except Exception:
        return None


def _pct_improvement(baseline: float, refactor: float) -> float | None:
    if baseline <= 0:
        return None
    return (baseline - refactor) / baseline * 100.0


def _fmt_minutes(seconds: float) -> str:
    return f"{seconds / 60.0:.2f} min"


def _fmt_time_delta(baseline_seconds: float, refactor_seconds: float) -> str:
    # Positive => refactor is slower, negative => refactor is faster.
    delta = refactor_seconds - baseline_seconds
    abs_delta = abs(delta)
    direction = "slower" if delta > 0 else "faster" if delta < 0 else "no change"
    if direction == "no change":
        return "0.000s (0.00 min) no change"
    return f"{abs_delta:.3f}s ({_fmt_minutes(abs_delta)}) {direction}"


def _speedup_factor(baseline_seconds: float, refactor_seconds: float) -> float | None:
    if baseline_seconds <= 0 or refactor_seconds <= 0:
        return None
    return baseline_seconds / refactor_seconds


def _human_bytes(v: Any) -> str | None:
    n = _num(v)
    if n is None:
        return None
    units = ["B", "KB", "MB", "GB", "TB", "PB"]
    i = 0
    while n >= 1024 and i < len(units) - 1:
        n /= 1024
        i += 1
    return f"{n:.2f} {units[i]}"


def _preserve_user_notes(existing: str | None) -> str:
    if not existing:
        return (
            f"{USER_NOTES_START}\n"
            "- (Add PM-facing notes here: impact, timeline, stakeholders)\n"
            f"{USER_NOTES_END}\n"
        )

    if USER_NOTES_START in existing and USER_NOTES_END in existing:
        start = existing.index(USER_NOTES_START)
        end = existing.index(USER_NOTES_END) + len(USER_NOTES_END)
        return existing[start:end] + "\n"

    return (
        f"{USER_NOTES_START}\n"
        "- (Add PM-facing notes here: impact, timeline, stakeholders)\n"
        f"{USER_NOTES_END}\n"
    )


def render_findings_md(inputs: FindingsInputs, previous_findings_text: str | None) -> str:
    now = datetime.now(timezone.utc)
    user_notes = _preserve_user_notes(previous_findings_text)

    b_exec_ms = _get(inputs.baseline_history, "EXECUTION_TIME")
    r_exec_ms = _get(inputs.refactor_history, "EXECUTION_TIME")

    b_bytes = _get(inputs.baseline_history, "BYTES_SCANNED")
    r_bytes = _get(inputs.refactor_history, "BYTES_SCANNED")

    b_cache = _get(inputs.baseline_history, "PERCENTAGE_SCANNED_FROM_CACHE")
    r_cache = _get(inputs.refactor_history, "PERCENTAGE_SCANNED_FROM_CACHE")

    b_spill_local = _get(inputs.baseline_history, "BYTES_SPILLED_TO_LOCAL_STORAGE")
    r_spill_local = _get(inputs.refactor_history, "BYTES_SPILLED_TO_LOCAL_STORAGE")

    b_spill_remote = _get(inputs.baseline_history, "BYTES_SPILLED_TO_REMOTE_STORAGE")
    r_spill_remote = _get(inputs.refactor_history, "BYTES_SPILLED_TO_REMOTE_STORAGE")

    time_impr = _pct_improvement(inputs.baseline_seconds, inputs.refactor_seconds)
    speedup = _speedup_factor(inputs.baseline_seconds, inputs.refactor_seconds)
    bytes_impr = None
    if _num(b_bytes) is not None and _num(r_bytes) is not None and _num(b_bytes) and _num(b_bytes) != 0:
        bytes_impr = (_num(b_bytes) - _num(r_bytes)) / _num(b_bytes) * 100.0

    lines: list[str] = []
    lines.append(f"# Findings — {inputs.query_folder}\n\n")
    lines.append(f"Generated (UTC): {inputs.generated_at_utc}\n")
    lines.append(f"Last updated (UTC): {now.isoformat()}\n\n")

    lines.append("## Executive summary\n")
    if time_impr is not None:
        time_delta = _fmt_time_delta(inputs.baseline_seconds, inputs.refactor_seconds)
        if time_impr >= 0:
            lines.append(
                f"- Runtime: {inputs.refactor_seconds:.3f}s vs {inputs.baseline_seconds:.3f}s ({time_delta}, {time_impr:.1f}% faster)\n"
            )
        else:
            lines.append(
                f"- Runtime: {inputs.refactor_seconds:.3f}s vs {inputs.baseline_seconds:.3f}s ({time_delta}, {-time_impr:.1f}% slower)\n"
            )
    else:
        lines.append(f"- Runtime: {inputs.refactor_seconds:.3f}s vs {inputs.baseline_seconds:.3f}s\n")
    if bytes_impr is not None:
        lines.append(f"- Bytes scanned: {_human_bytes(r_bytes)} vs {_human_bytes(b_bytes)} ({bytes_impr:+.1f}% change)\n")
    else:
        if b_bytes is not None or r_bytes is not None:
            lines.append(f"- Bytes scanned: baseline={_human_bytes(b_bytes)}, refactor={_human_bytes(r_bytes)}\n")
    lines.append("\n")

    lines.append("## Time improvement (plain English)\n")
    lines.append(f"- Baseline: {inputs.baseline_seconds:.3f}s ({_fmt_minutes(inputs.baseline_seconds)})\n")
    lines.append(f"- Refactor: {inputs.refactor_seconds:.3f}s ({_fmt_minutes(inputs.refactor_seconds)})\n")
    lines.append(f"- Change: {_fmt_time_delta(inputs.baseline_seconds, inputs.refactor_seconds)}\n")
    if time_impr is not None:
        if time_impr >= 0:
            lines.append(f"- Percent: {time_impr:.1f}% faster\n")
        else:
            lines.append(f"- Percent: {-time_impr:.1f}% slower\n")
    if speedup is not None:
        lines.append(f"- Speedup factor: {speedup:.2f}x\n")
    lines.append("\n")

    lines.append("## What changed (technical)\n")
    lines.append("- Refactor organized as layered CTEs: `src_*` → `int_*` → `agg_*` → `final_*`.\n")
    lines.append("- No intended semantic change: output columns and meaning must remain identical (validated by regression).\n\n")

    lines.append("## Why it should be faster\n")
    lines.append("- Clear separation of concerns reduces accidental recomputation and makes future optimizations safer.\n")
    lines.append("- Centralized parameter handling prevents repeated expressions and makes pruning opportunities easier to spot.\n\n")

    lines.append("## Performance signals (Snowflake query history)\n")
    lines.append("Baseline:\n")
    lines.append(f"- QUERY_ID: {inputs.baseline_query_id}\n")
    if inputs.baseline_history:
        lines.append(f"- EXECUTION_TIME(ms): {b_exec_ms}\n")
        lines.append(f"- BYTES_SCANNED: {_human_bytes(b_bytes)}\n")
        if b_cache is not None:
            lines.append(f"- PERCENTAGE_SCANNED_FROM_CACHE: {b_cache}\n")
        if b_spill_local is not None or b_spill_remote is not None:
            lines.append(f"- SPILL(local/remote): {_human_bytes(b_spill_local)} / {_human_bytes(b_spill_remote)}\n")
    else:
        lines.append("- (No history row available via INFORMATION_SCHEMA in this account/session)\n")

    lines.append("\nRefactor:\n")
    lines.append(f"- QUERY_ID: {inputs.refactor_query_id}\n")
    if inputs.refactor_history:
        lines.append(f"- EXECUTION_TIME(ms): {r_exec_ms}\n")
        lines.append(f"- BYTES_SCANNED: {_human_bytes(r_bytes)}\n")
        if r_cache is not None:
            lines.append(f"- PERCENTAGE_SCANNED_FROM_CACHE: {r_cache}\n")
        if r_spill_local is not None or r_spill_remote is not None:
            lines.append(f"- SPILL(local/remote): {_human_bytes(r_spill_local)} / {_human_bytes(r_spill_remote)}\n")
    else:
        lines.append("- (No history row available via INFORMATION_SCHEMA in this account/session)\n")

    lines.append("\n")

    lines.append("## EXPLAIN\n")
    lines.append("- Use these files to review pruning, join order, and scan patterns:\n")
    if inputs.baseline_explain_path:
        lines.append(f"  - Baseline: {inputs.baseline_explain_path}\n")
    if inputs.refactor_explain_path:
        lines.append(f"  - Refactor: {inputs.refactor_explain_path}\n")
    lines.append("\n")

    lines.append("## Regression status\n")
    lines.append("- Expected: same DDL (normalized) and same result set (rowcount/columns/checksum).\n")
    lines.append("- Run: `python -m snowrefactor regress-view <baseline_fqn> <sandbox_fqn> --threads 2`\n\n")

    lines.append("## PM notes\n")
    lines.append(user_notes)

    lines.append("\n## Next steps\n")
    lines.append("- If regression passes, deploy the refactor to production via the owning team’s change process.\n")
    lines.append("- If regression fails, inspect checksum/columns deltas and review the `final` projection.\n")

    return "".join(lines)


def write_findings_md(*, folder: Path, inputs: FindingsInputs) -> Path:
    path = folder / "FINDINGS.md"
    existing = path.read_text(encoding="utf-8") if path.exists() else None
    content = render_findings_md(inputs, existing)
    path.write_text(content, encoding="utf-8")
    return path
