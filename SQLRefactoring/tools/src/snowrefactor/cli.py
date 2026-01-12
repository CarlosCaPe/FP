from __future__ import annotations

import argparse
from pathlib import Path

from rich.console import Console

from snowrefactor.compare import compare_queries, compare_sql
from snowrefactor.ddl import pull_view_baseline
from snowrefactor.function_ddl import pull_function_baseline
from snowrefactor.function_deploy import deploy_function_from_folder
from snowrefactor.view_deploy import deploy_view_from_folder
from snowrefactor.regress import regress_views
from snowrefactor.analyze import analyze_folder
from snowrefactor.downstream import find_downstream_references


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="snowrefactor",
        description="Run baseline/refactor Snowflake queries and compare results.",
    )

    sub = parser.add_subparsers(dest="cmd", required=True)

    p_compare = sub.add_parser("compare", help="Compare baseline.sql vs refactor.sql for a query")
    p_compare.add_argument("name", help="Folder name under QUERIES/")
    p_compare.add_argument(
        "--queries-dir",
        default=str(Path.cwd() / "QUERIES"),
        help="Path to QUERIES directory (default: ./QUERIES)",
    )
    p_compare.add_argument(
        "--reports-dir",
        default=str(Path.cwd() / "reports"),
        help="Where to write reports (default: ./reports)",
    )
    p_compare.add_argument(
        "--max-fetch-rows",
        type=int,
        default=200_000,
        help="Max rows to fetch into pandas before switching to in-DB stats only.",
    )
    p_compare.add_argument(
        "--threads",
        type=int,
        default=2,
        help="Run baseline/refactor in parallel threads (default: 2)",
    )

    p_pull = sub.add_parser("pull-ddl", help="Fetch view DDL and scaffold a query folder")
    p_pull.add_argument(
        "fqn",
        help="Fully-qualified view name: <database>.<schema>.<view>",
    )
    p_pull.add_argument(
        "--queries-dir",
        default=str(Path.cwd() / "QUERIES"),
        help="Path to QUERIES directory (default: ./QUERIES)",
    )
    p_pull.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing baseline files if folder already exists.",
    )

    p_pf = sub.add_parser("pull-function", help="Fetch function DDL and scaffold a query folder")
    p_pf.add_argument(
        "fqn",
        help="Fully-qualified function name: <database>.<schema>.<function>",
    )
    p_pf.add_argument(
        "--queries-dir",
        default=str(Path.cwd() / "QUERIES"),
        help="Path to QUERIES directory (default: ./QUERIES)",
    )
    p_pf.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing baseline files if folder already exists.",
    )

    p_cv = sub.add_parser("compare-views", help="Compare two views by selecting all columns")
    p_cv.add_argument("baseline_fqn", help="Baseline view FQN: <db>.<schema>.<view>")
    p_cv.add_argument("refactor_fqn", help="Refactor view FQN: <db>.<schema>.<view>")
    p_cv.add_argument(
        "--reports-dir",
        default=str(Path.cwd() / "reports"),
        help="Where to write reports (default: ./reports)",
    )
    p_cv.add_argument(
        "--max-fetch-rows",
        type=int,
        default=200_000,
        help="Max rows to fetch into pandas before switching to in-DB stats only.",
    )
    p_cv.add_argument(
        "--threads",
        type=int,
        default=2,
        help="Run both views in parallel threads (default: 2)",
    )
    p_cv.add_argument(
        "--ignore-columns",
        default=None,
        help="Comma-separated column names to ignore in checksum/stats (e.g. UTC_CREATED_DATE)",
    )

    p_deploy = sub.add_parser("deploy-view", help="Create/replace a sandbox view from refactor.sql")
    p_deploy.add_argument(
        "folder",
        help="Folder name under QUERIES/ (e.g. PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL)",
    )
    p_deploy.add_argument(
        "--queries-dir",
        default=str(Path.cwd() / "QUERIES"),
        help="Path to QUERIES directory (default: ./QUERIES)",
    )
    p_deploy.add_argument(
        "--target-name",
        required=False,
        help="Sandbox view name to create (in env database/schema). If omitted, uses the original view name from the folder.",
    )
    p_deploy.add_argument(
        "--force",
        action="store_true",
        help="Use CREATE OR REPLACE (default true behavior). Provided for symmetry.",
    )

    p_deploy_fn = sub.add_parser(
        "deploy-function",
        help="Deploy refactored function DDL into the sandbox database/schema",
    )
    p_deploy_fn.add_argument(
        "folder",
        help="Folder name under QUERIES/ (e.g. PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET)",
    )
    p_deploy_fn.add_argument(
        "--queries-dir",
        default=str(Path.cwd() / "QUERIES"),
        help="Path to QUERIES directory (default: ./QUERIES)",
    )
    p_deploy_fn.add_argument(
        "--ddl",
        default="refactor_ddl.sql",
        help="DDL filename inside the folder (default: refactor_ddl.sql)",
    )
    p_deploy_fn.add_argument(
        "--name",
        default=None,
        help="Override function name in sandbox (defaults to name in folder)",
    )

    p_reg = sub.add_parser("regress-view", help="Regression test two views: DDL (normalized) + DML")
    p_reg.add_argument("baseline_fqn", help="Baseline view FQN: <db>.<schema>.<view>")
    p_reg.add_argument("sandbox_fqn", help="Sandbox view FQN: <db>.<schema>.<view>")
    p_reg.add_argument(
        "--reports-dir",
        default=str(Path.cwd() / "reports"),
        help="Where to write reports (default: ./reports)",
    )
    p_reg.add_argument(
        "--max-fetch-rows",
        type=int,
        default=200_000,
        help="Max rows to fetch into pandas before switching to in-DB stats only.",
    )
    p_reg.add_argument(
        "--threads",
        type=int,
        default=2,
        help="Run both views in parallel threads (default: 2)",
    )
    p_reg.add_argument(
        "--ignore-columns",
        default=None,
        help="Comma-separated column names to ignore in checksum/stats (e.g. UTC_CREATED_DATE)",
    )

    p_an = sub.add_parser("analyze", help="Run baseline/refactor and capture EXPLAIN + query history metrics")
    p_an.add_argument(
        "folder",
        help="Folder name under QUERIES/ (e.g. PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL)",
    )
    p_an.add_argument(
        "--queries-dir",
        default=str(Path.cwd() / "QUERIES"),
        help="Path to QUERIES directory (default: ./QUERIES)",
    )
    p_an.add_argument(
        "--reports-dir",
        default=str(Path.cwd() / "reports"),
        help="Where to write reports (default: ./reports)",
    )

    p_ds = sub.add_parser("downstream", help="Find QUERIES folders that reference a given string")
    p_ds.add_argument(
        "needle",
        help="String to search for (e.g. PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET)",
    )
    p_ds.add_argument(
        "--queries-dir",
        default=str(Path.cwd() / "QUERIES"),
        help="Path to QUERIES directory (default: ./QUERIES)",
    )

    args = parser.parse_args(argv)

    console = Console()

    if args.cmd == "compare":
        report_path = compare_queries(
            query_name=args.name,
            queries_dir=Path(args.queries_dir),
            reports_dir=Path(args.reports_dir),
            max_fetch_rows=args.max_fetch_rows,
            threads=args.threads,
        )
        console.print(f"Report written: {report_path}")
        return 0

    if args.cmd == "pull-ddl":
        folder = pull_view_baseline(
            fqn=args.fqn,
            queries_dir=Path(args.queries_dir),
            force=args.force,
        )
        console.print(f"Scaffolded: {folder}")
        return 0

    if args.cmd == "pull-function":
        folder = pull_function_baseline(
            fqn=args.fqn,
            queries_dir=Path(args.queries_dir),
            force=args.force,
        )
        console.print(f"Scaffolded: {folder}")
        return 0

    if args.cmd == "compare-views":
        ignore_cols = (
            [c.strip() for c in args.ignore_columns.split(",") if c.strip()] if args.ignore_columns else None
        )
        baseline_sql = f"SELECT * FROM {args.baseline_fqn};"
        refactor_sql = f"SELECT * FROM {args.refactor_fqn};"
        report_path = compare_sql(
            query_name=f"views__{args.baseline_fqn}__vs__{args.refactor_fqn}".replace(".", "_").replace(" ", "_"),
            baseline_sql=baseline_sql,
            refactor_sql=refactor_sql,
            reports_dir=Path(args.reports_dir),
            max_fetch_rows=args.max_fetch_rows,
            order_by=None,
            ignore_columns=ignore_cols,
            threads=args.threads,
        )
        console.print(f"Report written: {report_path}")
        return 0

    if args.cmd == "deploy-view":
        target_name = args.target_name
        if not target_name:
            # folder is the safe name generated from fqn: DB__SCHEMA__VIEW
            target_name = args.folder.split("__")[-1]

        target_fqn = deploy_view_from_folder(
            folder_name=args.folder,
            queries_dir=Path(args.queries_dir),
            target_name=target_name,
        )
        console.print(f"Deployed sandbox view: {target_fqn}")
        return 0

    if args.cmd == "deploy-function":
        try:
            target = deploy_function_from_folder(
                folder_name=args.folder,
                queries_dir=Path(args.queries_dir),
                ddl_filename=args.ddl,
                target_name=args.name,
            )
        except Exception as e:
            console.print(f"Deploy failed: {e}")
            return 1

        console.print(f"Deployed sandbox function: {target}")
        return 0

    if args.cmd == "regress-view":
        ignore_cols = (
            [c.strip() for c in args.ignore_columns.split(",") if c.strip()] if args.ignore_columns else None
        )
        report_path = regress_views(
            baseline_fqn=args.baseline_fqn,
            sandbox_fqn=args.sandbox_fqn,
            reports_dir=Path(args.reports_dir),
            max_fetch_rows=args.max_fetch_rows,
            threads=args.threads,
            ignore_columns=ignore_cols,
        )
        console.print(f"Report written: {report_path}")
        return 0

    if args.cmd == "analyze":
        folder = Path(args.queries_dir) / args.folder
        report_path = analyze_folder(folder=folder, reports_dir=Path(args.reports_dir))
        console.print(f"Report written: {report_path}")
        return 0

    if args.cmd == "downstream":
        hits = find_downstream_references(queries_dir=Path(args.queries_dir), needle=args.needle)
        if not hits:
            console.print("No matches.")
            return 0
        for h in hits:
            console.print(f"{h.folder}: {h.file}:{h.line}  {h.text}")
        return 0

    return 2
