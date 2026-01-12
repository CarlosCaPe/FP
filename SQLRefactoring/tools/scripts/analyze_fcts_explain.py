from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class ScanStat:
    table: str
    alias: str | None
    partitions_total: int | None
    partitions_assigned: int | None
    bytes_assigned: int | None
    kind: str  # baseline|refactor|other
    file: str
    line_number: int


_TABLESCAN_RE = re.compile(
    r"->TableScan\s+(?P<table>[^\s]+)"  # table token
    r"(?:\s+as\s+(?P<alias>[^\s]+))?"  # optional alias
    r".*?\{(?P<brace>[^}]*)\}",
    re.IGNORECASE,
)


def _int_or_none(s: str | None) -> int | None:
    if s is None:
        return None
    s = s.strip()
    if not s:
        return None
    try:
        return int(s)
    except ValueError:
        return None


def _parse_brace_kv(brace: str) -> dict[str, int | None]:
    out: dict[str, int | None] = {
        "partitionsTotal": None,
        "partitionsAssigned": None,
        "bytesAssigned": None,
    }
    for part in brace.split(","):
        if "=" not in part:
            continue
        k, v = part.split("=", 1)
        k = k.strip()
        v = v.strip()
        if k in out:
            out[k] = _int_or_none(v)
    return out


def iter_explain_files(reports_dir: Path) -> Iterable[tuple[Path, str]]:
    for p in sorted(reports_dir.glob("*_explain.txt")):
        name = p.name.lower()
        if "baseline_explain" in name:
            kind = "baseline"
        elif "refactor_explain" in name:
            kind = "refactor"
        else:
            kind = "other"
        yield p, kind


def parse_explain_file(path: Path, kind: str) -> list[ScanStat]:
    stats: list[ScanStat] = []
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return stats

    for idx, line in enumerate(lines, start=1):
        if ".FCTS." not in line:
            continue
        if "->TableScan" not in line and "->tablescan" not in line.lower():
            continue
        m = _TABLESCAN_RE.search(line)
        if not m:
            continue
        table = m.group("table")
        if ".FCTS." not in table:
            continue
        alias = m.group("alias")
        kv = _parse_brace_kv(m.group("brace") or "")
        stats.append(
            ScanStat(
                table=table,
                alias=alias,
                partitions_total=kv["partitionsTotal"],
                partitions_assigned=kv["partitionsAssigned"],
                bytes_assigned=kv["bytesAssigned"],
                kind=kind,
                file=path.name,
                line_number=idx,
            )
        )
    return stats


def _fmt_bytes(n: int | None) -> str:
    if n is None:
        return "-"
    # base-10 for readability in comms
    units = [("TB", 10**12), ("GB", 10**9), ("MB", 10**6)]
    for u, div in units:
        if n >= div:
            return f"{n / div:.2f} {u}"
    return f"{n} B"


def _fmt_int(n: int | None) -> str:
    if n is None:
        return "-"
    return f"{n:,}"


def _ratio(num: int | None, den: int | None) -> float | None:
    if num is None or den in (None, 0):
        return None
    return num / den


def _pct_reduction(smaller: int | None, larger: int | None) -> str:
    r = _ratio(smaller, larger)
    if r is None:
        return "-"
    return f"{(1 - r) * 100:.1f}%"


def _best_effort_max(items: list[ScanStat], alias: str) -> tuple[int | None, int | None]:
    """Return (bytesAssigned_max, partitionsAssigned_max) for a specific alias within items."""
    alias_upper = alias.upper()
    filt = [s for s in items if (s.alias or "").upper() == alias_upper]
    if not filt:
        return None, None
    bytes_vals = [s.bytes_assigned for s in filt if isinstance(s.bytes_assigned, int)]
    part_vals = [s.partitions_assigned for s in filt if isinstance(s.partitions_assigned, int)]
    return (max(bytes_vals) if bytes_vals else None, max(part_vals) if part_vals else None)


def main() -> int:
    ap = argparse.ArgumentParser(
        description=(
            "Analyze Snowflake EXPLAIN reports under SQL/reports and summarize scans of *.FCTS.* tables. "
            "Uses TableScan {partitionsTotal/Assigned, bytesAssigned} as evidence."
        )
    )
    ap.add_argument(
        "--reports-dir",
        default=str(Path(__file__).resolve().parents[1] / "reports"),
        help="Path to reports directory (default: SQL/reports)",
    )
    ap.add_argument(
        "--out-md",
        default="fcts_explain_summary.md",
        help="Output markdown filename (written into reports-dir)",
    )
    ap.add_argument(
        "--out-md-simple",
        default="fcts_explain_summary_simple.md",
        help="Output simplified markdown filename (written into reports-dir)",
    )
    ap.add_argument(
        "--out-json",
        default="fcts_explain_summary.json",
        help="Output json filename (written into reports-dir)",
    )
    ap.add_argument(
        "--top",
        type=int,
        default=25,
        help="How many tables to show in the markdown summary (default: 25)",
    )
    args = ap.parse_args()

    reports_dir = Path(args.reports_dir)
    all_stats: list[ScanStat] = []
    for f, kind in iter_explain_files(reports_dir):
        all_stats.extend(parse_explain_file(f, kind))

    # Aggregate by table+kind and compute maxima (worst-case footprint)
    by_table_kind: dict[tuple[str, str], list[ScanStat]] = {}
    for s in all_stats:
        by_table_kind.setdefault((s.table, s.kind), []).append(s)

    def max_field(items: list[ScanStat], attr: str) -> int | None:
        vals = [getattr(i, attr) for i in items]
        vals2 = [v for v in vals if isinstance(v, int)]
        return max(vals2) if vals2 else None

    # Best proxy for "with clustering key" = RAW_SUB vs RAW when both exist for same table+file (baseline only).
    # We take the *minimum* RAW_SUB bytesAssigned observed and compare to *maximum* RAW bytesAssigned observed.
    raw_sub_bytes_min: dict[str, int] = {}
    raw_sub_parts_min: dict[str, int] = {}
    raw_bytes_max: dict[str, int] = {}
    raw_parts_max: dict[str, int] = {}

    for s in all_stats:
        if s.kind != "baseline":
            continue
        if s.alias is None:
            continue
        alias = s.alias.upper()
        if alias == "RAW_SUB":
            if s.bytes_assigned is not None:
                raw_sub_bytes_min[s.table] = min(raw_sub_bytes_min.get(s.table, s.bytes_assigned), s.bytes_assigned)
            if s.partitions_assigned is not None:
                raw_sub_parts_min[s.table] = min(raw_sub_parts_min.get(s.table, s.partitions_assigned), s.partitions_assigned)
        elif alias == "RAW":
            if s.bytes_assigned is not None:
                raw_bytes_max[s.table] = max(raw_bytes_max.get(s.table, s.bytes_assigned), s.bytes_assigned)
            if s.partitions_assigned is not None:
                raw_parts_max[s.table] = max(raw_parts_max.get(s.table, s.partitions_assigned), s.partitions_assigned)

    # Build per-table rollup
    tables = sorted({s.table for s in all_stats})
    rollup: list[dict[str, object]] = []
    for table in tables:
        base_items = by_table_kind.get((table, "baseline"), [])
        ref_items = by_table_kind.get((table, "refactor"), [])
        base_bytes = max_field(base_items, "bytes_assigned")
        base_parts = max_field(base_items, "partitions_assigned")
        ref_bytes = max_field(ref_items, "bytes_assigned")
        ref_parts = max_field(ref_items, "partitions_assigned")

        proxy_bytes = raw_sub_bytes_min.get(table)
        proxy_parts = raw_sub_parts_min.get(table)
        raw_bytes = raw_bytes_max.get(table)
        raw_parts = raw_parts_max.get(table)

        rollup.append(
            {
                "table": table,
                "baseline": {
                    "bytesAssigned_max": base_bytes,
                    "partitionsAssigned_max": base_parts,
                    "occurrences": len(base_items),
                },
                "refactor": {
                    "bytesAssigned_max": ref_bytes,
                    "partitionsAssigned_max": ref_parts,
                    "occurrences": len(ref_items),
                },
                "proxy_with_clustering": {
                    "raw_bytesAssigned_max": raw_bytes,
                    "raw_partitionsAssigned_max": raw_parts,
                    "raw_sub_bytesAssigned_min": proxy_bytes,
                    "raw_sub_partitionsAssigned_min": proxy_parts,
                    "bytes_reduction_pct": _pct_reduction(proxy_bytes, raw_bytes),
                    "partitions_reduction_pct": _pct_reduction(proxy_parts, raw_parts),
                },
            }
        )

    # Sort by baseline worst-case bytes
    def sort_key(r: dict[str, object]) -> int:
        b = r["baseline"]["bytesAssigned_max"]  # type: ignore[index]
        return int(b) if isinstance(b, int) else -1

    rollup_sorted = sorted(rollup, key=sort_key, reverse=True)

    # Write JSON
    out_json = reports_dir / args.out_json
    out_json.write_text(json.dumps({"tables": rollup_sorted, "scans": [asdict(s) for s in all_stats]}, indent=2), encoding="utf-8")

    # Write Markdown
    out_md = reports_dir / args.out_md
    lines: list[str] = []
    lines.append("# FCTS EXPLAIN Scan Summary")
    lines.append("")
    lines.append(f"Reports scanned: {len(list(reports_dir.glob('*_explain.txt')))}")
    lines.append(f"Distinct FCTS tables found: {len(tables)}")
    lines.append("")
    lines.append("This report summarizes `->TableScan` stats captured in EXPLAIN text files. It does **not** query Snowflake.")
    lines.append("The ‘estimated_after_clustering_key’ columns use `RAW_SUB` vs `RAW` in baseline plans as an estimate of pruning potential with a clustering key like `(SITE_CODE, SENSOR_ID, VALUE_UTC_TS)`.")
    lines.append("")

    lines.append("## Top tables by baseline bytesAssigned (max)")
    lines.append("")
    lines.append(
        "| table | baseline bytesAssigned (max) | baseline partitionsAssigned (max) | "
        "refactor bytesAssigned (max) | raw bytesAssigned (max) | raw partitionsAssigned (max) | "
        "est bytesAssigned (RAW_SUB min) | est partitionsAssigned (RAW_SUB min) | "
        "est bytes reduction | est partitions reduction |"
    )
    lines.append("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")

    for r in rollup_sorted[: args.top]:
        table = str(r["table"])
        b = r["baseline"]  # type: ignore[assignment]
        rf = r["refactor"]  # type: ignore[assignment]
        px = r["proxy_with_clustering"]  # type: ignore[assignment]

        raw_bytes = px["raw_bytesAssigned_max"]  # type: ignore[index]
        raw_parts = px["raw_partitionsAssigned_max"]  # type: ignore[index]

        lines.append(
            "| "
            + table
            + " | "
            + _fmt_bytes(b["bytesAssigned_max"])  # type: ignore[index]
            + " | "
            + _fmt_int(b["partitionsAssigned_max"])  # type: ignore[index]
            + " | "
            + _fmt_bytes(rf["bytesAssigned_max"])  # type: ignore[index]
            + " | "
            + _fmt_bytes(raw_bytes)
            + " | "
            + _fmt_int(raw_parts)
            + " | "
            + _fmt_bytes(px["raw_sub_bytesAssigned_min"])  # type: ignore[index]
            + " | "
            + _fmt_int(px["raw_sub_partitionsAssigned_min"])  # type: ignore[index]
            + " | "
            + str(px["bytes_reduction_pct"])  # type: ignore[index]
            + " | "
            + str(px["partitions_reduction_pct"])  # type: ignore[index]
            + " |"
        )

    out_md.write_text("\n".join(lines) + "\n", encoding="utf-8")

    # Write simplified Markdown (Now vs After clustering key estimate)
    out_md_simple = reports_dir / args.out_md_simple
    lines_s: list[str] = []
    lines_s.append("# FCTS Scan Summary (Now vs After clustering key — estimate)")
    lines_s.append("")
    lines_s.append(f"Reports scanned: {len(list(reports_dir.glob('*_explain.txt')))}")
    lines_s.append(f"Distinct FCTS tables found: {len(tables)}")
    lines_s.append("")
    lines_s.append("Definitions:")
    lines_s.append("- Now = baseline RAW scan worst-case (max bytesAssigned/partitionsAssigned) when available")
    lines_s.append("- After clustering key (estimate) = best observed pruning case (min RAW_SUB bytesAssigned/partitionsAssigned) in baseline")
    lines_s.append("- If a table only appears in refactor EXPLAINs, the Now/After estimate may be unavailable")
    lines_s.append("")

    comparable = [r for r in rollup_sorted if isinstance(r["proxy_with_clustering"]["raw_bytesAssigned_max"], int) and isinstance(r["proxy_with_clustering"]["raw_sub_bytesAssigned_min"], int)]  # type: ignore[index]
    refactor_only = [
        r
        for r in rollup_sorted
        if not (isinstance(r["proxy_with_clustering"]["raw_bytesAssigned_max"], int) and isinstance(r["proxy_with_clustering"]["raw_sub_bytesAssigned_min"], int))
        and isinstance(r["refactor"]["bytesAssigned_max"], int)
        and not isinstance(r["baseline"]["bytesAssigned_max"], int)
    ]  # type: ignore[index]

    lines_s.append("## Comparable tables (Now vs After estimate available)")
    lines_s.append("")
    lines_s.append("| table | Now (bytes / partitions) | After clustering key (est) (bytes / partitions) | Reduction (bytes / partitions) |")
    lines_s.append("|---|---:|---:|---:|")
    for r in comparable[: args.top]:
        table = str(r["table"])
        px = r["proxy_with_clustering"]  # type: ignore[assignment]
        now_bytes = px["raw_bytesAssigned_max"]  # type: ignore[index]
        now_parts = px["raw_partitionsAssigned_max"]  # type: ignore[index]
        est_bytes = px["raw_sub_bytesAssigned_min"]  # type: ignore[index]
        est_parts = px["raw_sub_partitionsAssigned_min"]  # type: ignore[index]
        bytes_red = _pct_reduction(est_bytes, now_bytes)
        parts_red = _pct_reduction(est_parts, now_parts)
        lines_s.append(
            "| "
            + table
            + " | "
            + f"{_fmt_bytes(now_bytes)} / {_fmt_int(now_parts)}"
            + " | "
            + f"{_fmt_bytes(est_bytes)} / {_fmt_int(est_parts)}"
            + " | "
            + f"{bytes_red} / {parts_red}"
            + " |"
        )

    if refactor_only:
        lines_s.append("")
        lines_s.append("## Tables seen in refactor only (no baseline Now/After estimate)")
        lines_s.append("")
        lines_s.append("| table | Observed in refactor (bytesAssigned max) |")
        lines_s.append("|---|---:|")
        for r in refactor_only[: args.top]:
            table = str(r["table"])
            rf = r["refactor"]  # type: ignore[assignment]
            lines_s.append("| " + table + " | " + _fmt_bytes(rf["bytesAssigned_max"]) + " |")  # type: ignore[index]

    out_md_simple.write_text("\n".join(lines_s) + "\n", encoding="utf-8")

    print(f"Wrote: {out_md}")
    print(f"Wrote: {out_md_simple}")
    print(f"Wrote: {out_json}")
    print(f"Tables: {len(tables)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
