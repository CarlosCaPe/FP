from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from concurrent.futures import ThreadPoolExecutor
from time import perf_counter

import pandas as pd

from snowrefactor.config import load_query_config
from snowrefactor.snowflake_conn import connect
from snowrefactor.sql_runner import fetch_dataframe, fetch_rowcount, in_db_profile


def _null_counts(df: pd.DataFrame) -> dict[str, int]:
    return {c: int(df[c].isna().sum()) for c in df.columns}


def _numeric_stats(df: pd.DataFrame) -> dict[str, dict[str, float]]:
    stats: dict[str, dict[str, float]] = {}
    numeric_cols = df.select_dtypes(include=["number"]).columns
    for c in numeric_cols:
        series = df[c]
        stats[c] = {
            "count": float(series.count()),
            "mean": float(series.mean()) if series.count() else float("nan"),
            "std": float(series.std()) if series.count() else float("nan"),
            "min": float(series.min()) if series.count() else float("nan"),
            "max": float(series.max()) if series.count() else float("nan"),
        }
    return stats


def _checksum_dataframe(df: pd.DataFrame, order_by: list[str] | None) -> str:
    # Deterministic checksum without pulling to DB: sort + stable string concat.
    # Intended for moderate datasets only.
    if order_by:
        missing = [c for c in order_by if c not in df.columns]
        if missing:
            raise ValueError(f"order_by columns not found: {missing}")
        df = df.sort_values(by=order_by, kind="mergesort")
    # Normalize types to strings with explicit NA marker
    norm = df.fillna("<NULL>").astype(str)

    # Avoid DataFrame.apply(axis=1) corner cases (can return a DataFrame depending
    # on inferred return type). Build row strings directly.
    arr = norm.to_numpy(dtype=str, copy=False)
    joined = ["|".join(row) for row in arr]
    # If the caller didn't specify an order, make the checksum insensitive to row ordering.
    if not order_by:
        joined = sorted(joined)
    import hashlib

    h = hashlib.sha256()
    for v in joined:
        h.update(v.encode("utf-8"))
        h.update(b"\n")
    return h.hexdigest()


def compare_sql(
    *,
    query_name: str,
    baseline_sql: str,
    refactor_sql: str,
    reports_dir: Path,
    max_fetch_rows: int,
    order_by: list[str] | None = None,
    ignore_columns: list[str] | None = None,
    extra: dict[str, Any] | None = None,
    threads: int = 2,
) -> Path:
    reports_dir.mkdir(parents=True, exist_ok=True)

    started_at = datetime.now(timezone.utc)
    wall_t0 = perf_counter()

    def _run_one(label: str, sql: str) -> dict[str, Any]:
        # Each thread uses its own connection.
        t0 = perf_counter()
        with connect() as conn:
            rowcount = fetch_rowcount(conn, sql)
            result = fetch_dataframe(conn, sql, max_fetch_rows)
            profile = None
            if result.dataframe is None:
                profile = in_db_profile(conn, sql, ignore_columns=ignore_columns)
        t1 = perf_counter()
        return {
            "label": label,
            "rowcount": rowcount,
            "columns": result.columns,
            "truncated": bool(getattr(result, "truncated", False)),
            "dataframe": result.dataframe,
            "in_db_profile": profile,
            "seconds": t1 - t0,
        }

    max_workers = max(1, int(threads))
    with ThreadPoolExecutor(max_workers=max_workers) as ex:
        f_base = ex.submit(_run_one, "baseline", baseline_sql)
        f_ref = ex.submit(_run_one, "refactor", refactor_sql)
        baseline_run = f_base.result()
        refactor_run = f_ref.result()

    wall_t1 = perf_counter()
    ended_at = datetime.now(timezone.utc)

    baseline_cnt = int(baseline_run["rowcount"])
    refactor_cnt = int(refactor_run["rowcount"])
    baseline = baseline_run["dataframe"]
    refactor = refactor_run["dataframe"]

    report: dict[str, Any] = {
        "query_name": query_name,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "timing": {
            "started_at_utc": started_at.isoformat(),
            "ended_at_utc": ended_at.isoformat(),
            "wall_seconds": wall_t1 - wall_t0,
            "baseline_seconds": baseline_run["seconds"],
            "refactor_seconds": refactor_run["seconds"],
            "threads": max_workers,
        },
        "rowcount": {"baseline": baseline_cnt, "refactor": refactor_cnt, "delta": refactor_cnt - baseline_cnt},
        "columns": {
            "baseline": baseline_run["columns"],
            "refactor": refactor_run["columns"],
            "equal": baseline_run["columns"] == refactor_run["columns"],
        },
        "mode": "dataframe" if (baseline is not None and refactor is not None) else "stats_only",
    }

    if extra is not None:
        report["extra"] = extra

    if baseline is not None and refactor is not None:
        bdf = baseline
        rdf = refactor

        ignored_present: list[str] = []
        ignored_missing: list[str] = []
        if ignore_columns:
            for c in ignore_columns:
                if c in bdf.columns and c in rdf.columns:
                    ignored_present.append(c)
                else:
                    ignored_missing.append(c)
        if ignored_present:
            bdf = bdf.drop(columns=ignored_present)
            rdf = rdf.drop(columns=ignored_present)

        if ignored_present or ignored_missing:
            report["ignored_columns"] = {
                "requested": list(ignore_columns or []),
                "ignored": ignored_present,
                "missing_in_one_side": ignored_missing,
            }

        report["null_counts"] = {"baseline": _null_counts(bdf), "refactor": _null_counts(rdf)}
        report["numeric_stats"] = {"baseline": _numeric_stats(bdf), "refactor": _numeric_stats(rdf)}
        report["checksum"] = {
            "baseline": _checksum_dataframe(bdf, order_by),
            "refactor": _checksum_dataframe(rdf, order_by),
        }
        report["checksum"]["equal"] = report["checksum"]["baseline"] == report["checksum"]["refactor"]

    if report["mode"] == "stats_only":
        bprof = baseline_run.get("in_db_profile")
        rprof = refactor_run.get("in_db_profile")
        report["in_db_profile"] = {"baseline": bprof, "refactor": rprof}
        if bprof and rprof:
            bck = bprof.get("checksum")
            rck = rprof.get("checksum")
            report["checksum"] = {"baseline": bck, "refactor": rck, "equal": (bck is not None and bck == rck)}

    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    json_path = reports_dir / f"{query_name}__{stamp}.json"
    md_path = reports_dir / f"{query_name}__{stamp}.md"

    json_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")

    lines: list[str] = []
    lines.append(f"# Regression Report: {query_name}\n")
    lines.append(f"Generated (UTC): {report['generated_at']}\n")
    rc = report["rowcount"]
    lines.append("## Rowcount\n")
    lines.append(f"- baseline: {rc['baseline']}\n")
    lines.append(f"- refactor: {rc['refactor']}\n")
    lines.append(f"- delta: {rc['delta']}\n")

    cols = report["columns"]
    lines.append("\n## Columns\n")
    lines.append(f"- equal: {cols['equal']}\n")
    if not cols["equal"]:
        lines.append(f"- baseline: {cols['baseline']}\n")
        lines.append(f"- refactor: {cols['refactor']}\n")

    lines.append(f"\n## Mode\n- {report['mode']}\n")

    if isinstance(report.get("timing"), dict):
        t = report["timing"]
        lines.append("\n## Timing\n")
        lines.append(f"- started_at_utc: {t.get('started_at_utc')}\n")
        lines.append(f"- ended_at_utc: {t.get('ended_at_utc')}\n")
        lines.append(f"- wall_seconds: {t.get('wall_seconds'):.3f}\n")
        lines.append(f"- baseline_seconds: {t.get('baseline_seconds'):.3f}\n")
        lines.append(f"- refactor_seconds: {t.get('refactor_seconds'):.3f}\n")

    if isinstance(report.get("extra"), dict) and isinstance(report["extra"].get("ddl"), dict):
        ddl = report["extra"]["ddl"]
        lines.append("\n## DDL\n")
        lines.append(f"- equal (normalized): {ddl.get('equal_normalized')}\n")

    if "checksum" in report:
        ck = report["checksum"]
        lines.append("\n## Checksum\n")
        lines.append(f"- equal: {ck.get('equal')}\n")

    lines.append(f"\n---\nJSON: {json_path.name}\n")
    md_path.write_text("".join(lines), encoding="utf-8")
    return md_path


def compare_queries(
    query_name: str,
    queries_dir: Path,
    reports_dir: Path,
    max_fetch_rows: int,
    *,
    threads: int = 2,
) -> Path:
    folder = queries_dir / query_name
    baseline_path = folder / "baseline.sql"
    refactor_path = folder / "refactor.sql"

    if not baseline_path.exists():
        raise FileNotFoundError(f"Missing {baseline_path}")
    if not refactor_path.exists():
        raise FileNotFoundError(f"Missing {refactor_path}")

    cfg = load_query_config(folder)
    effective_max_fetch = cfg.max_fetch_rows or max_fetch_rows

    baseline_sql = baseline_path.read_text(encoding="utf-8")
    refactor_sql = refactor_path.read_text(encoding="utf-8")

    return compare_sql(
        query_name=query_name,
        baseline_sql=baseline_sql,
        refactor_sql=refactor_sql,
        reports_dir=reports_dir,
        max_fetch_rows=effective_max_fetch,
        order_by=cfg.order_by,
        ignore_columns=cfg.ignore_columns,
        threads=threads,
    )
