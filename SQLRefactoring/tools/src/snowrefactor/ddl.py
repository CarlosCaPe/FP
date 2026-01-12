from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re

from snowrefactor.snowflake_conn import connect


@dataclass(frozen=True)
class PulledView:
    fqn: str
    ddl: str


def _safe_folder_name(fqn: str) -> str:
    # Use a stable, filesystem-friendly name. Keep it reversible in config.
    return fqn.strip().replace(".", "__").replace(" ", "_")


def get_view_ddl(fqn: str) -> PulledView:
    sql = "SELECT GET_DDL('VIEW', %s)"

    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(sql, (fqn,))
            row = cur.fetchone()
        finally:
            cur.close()

    if not row or row[0] is None:
        raise RuntimeError(f"GET_DDL returned no result for: {fqn}")

    ddl = str(row[0])
    return PulledView(fqn=fqn, ddl=ddl)


def normalize_view_ddl(ddl: str) -> str:
    """Normalize view DDL so it can be compared across schemas/databases.

    - Replaces the fully-qualified view name after `VIEW` with a placeholder
    - Trims trailing semicolons
    - Collapses whitespace
    """
    text = ddl.strip().rstrip(";")
    # Replace the view name token after CREATE OR REPLACE VIEW
    text = re.sub(
        r"(?is)\bcreate\s+or\s+replace\s+view\s+[^\(\s]+",
        "CREATE OR REPLACE VIEW <VIEW>",
        text,
    )
    # normalize whitespace
    text = re.sub(r"\s+", " ", text).strip()
    return text


def extract_view_select_from_ddl(ddl: str) -> str | None:
    """Extract the SELECT body from a GET_DDL view definition (best-effort)."""
    m = re.search(r"(?is)\)\s+as\s+(.*)\s*$", ddl.strip().rstrip(";"))
    if not m:
        return None
    return m.group(1).strip().rstrip(";")


def pull_view_baseline(*, fqn: str, queries_dir: Path, force: bool) -> Path:
    pulled = get_view_ddl(fqn)

    queries_dir.mkdir(parents=True, exist_ok=True)
    folder = queries_dir / _safe_folder_name(fqn)
    folder.mkdir(parents=True, exist_ok=True)

    baseline_ddl = folder / "baseline_ddl.sql"
    baseline_sql = folder / "baseline.sql"
    refactor_sql = folder / "refactor.sql"
    config_yml = folder / "config.yml"

    if not force:
        for p in [baseline_ddl, baseline_sql, refactor_sql]:
            if p.exists():
                raise FileExistsError(f"File already exists: {p}. Use --force to overwrite.")

    baseline_ddl.write_text(pulled.ddl.strip() + "\n", encoding="utf-8")

    # Baseline query: compare against the current view output.
    baseline_select = f"-- Baseline result from existing view\nSELECT * FROM {pulled.fqn};\n"
    baseline_sql.write_text(baseline_select, encoding="utf-8")

    # Start refactor as a copy of baseline; user edits it.
    if not refactor_sql.exists() or force:
        refactor_sql.write_text(
            f"-- Refactor this query to be faster, but identical results\nSELECT * FROM {pulled.fqn};\n",
            encoding="utf-8",
        )

    if not config_yml.exists():
        config_yml.write_text(
            "# View metadata for this refactor\n"
            f"# target_view: {pulled.fqn}\n"
            "# order_by: []  # optional for deterministic checksum\n"
            "# primary_key: []  # optional for key-based comparisons\n"
            "# max_fetch_rows: 200000\n",
            encoding="utf-8",
        )

    return folder
