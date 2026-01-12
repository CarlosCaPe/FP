from __future__ import annotations

import argparse
import json
from collections import deque
from dataclasses import dataclass
from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path

from snowrefactor.snowflake_conn import connect, load_snowflake_env


@dataclass(frozen=True)
class Obj:
    db: str
    schema: str
    name: str
    domain: str

    @property
    def key(self) -> tuple[str, str, str, str]:
        return (self.db.upper(), self.schema.upper(), self.name.upper(), self.domain.upper())

    def fqn(self) -> str:
        return f"{self.db}.{self.schema}.{self.name}"


def _q_ident(ident: str) -> str:
    return '"' + ident.replace('"', '""') + '"'


def _q_fqn(db: str, schema: str, name: str) -> str:
    return f"{_q_ident(db)}.{_q_ident(schema)}.{_q_ident(name)}"


def _parse_fqn(fqn: str) -> tuple[str, str, str]:
    parts = [p.strip() for p in fqn.split(".") if p.strip()]
    if len(parts) != 3:
        raise ValueError(f"Expected 3-part name <db>.<schema>.<name>, got: {fqn!r}")
    return parts[0], parts[1], parts[2]


def _fetchall_dict(cur) -> list[dict[str, object]]:
    cols = [c[0] for c in (cur.description or [])]

    def norm(v: object) -> object:
        # Snowflake connector can return datetime/date/Decimal/bytes in SHOW/DESCRIBE outputs.
        # Normalize to JSON-serializable values.
        if isinstance(v, datetime):
            return v.isoformat()
        if isinstance(v, date):
            return v.isoformat()
        if isinstance(v, Decimal):
            # Preserve numeric meaning; callers can parse if needed.
            return float(v)
        if isinstance(v, (bytes, bytearray)):
            return v.hex()
        return v

    out: list[dict[str, object]] = []
    for row in cur.fetchall():
        out.append({k: norm(v) for k, v in zip(cols, row)})
    return out


def _try_show_object_deps(cur, *, view_fqn: str) -> tuple[list[dict[str, object]] | None, str | None]:
    # Not all accounts/roles support SHOW OBJECT DEPENDENCIES; keep as best-effort.
    try:
        cur.execute(f"SHOW OBJECT DEPENDENCIES IN VIEW {view_fqn}")
        rows = _fetchall_dict(cur)
        return rows, None
    except Exception as e:
        return None, str(e)


def _account_usage_deps(cur, obj: Obj) -> list[Obj]:
    # ACCOUNT_USAGE typically stores uppercase names; we compare case-insensitively.
    cur.execute(
        """
        SELECT
                    REFERENCED_DATABASE,
                    REFERENCED_SCHEMA,
                    REFERENCED_OBJECT_NAME,
                    REFERENCED_OBJECT_DOMAIN
        FROM SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
                WHERE UPPER(REFERENCING_DATABASE) = UPPER(%s)
                    AND UPPER(REFERENCING_SCHEMA) = UPPER(%s)
                    AND UPPER(REFERENCING_OBJECT_NAME) = UPPER(%s)
                    AND UPPER(REFERENCING_OBJECT_DOMAIN) = UPPER(%s)
        """,
        (obj.db, obj.schema, obj.name, obj.domain),
    )

    out: list[Obj] = []
    for rdb, rsch, rname, rdomain in cur.fetchall():
        if not (rdb and rsch and rname and rdomain):
            continue
        out.append(Obj(str(rdb), str(rsch), str(rname), str(rdomain)))
    return out


def _show_dynamic_table(cur, obj: Obj) -> dict[str, object] | None:
    # SHOW DYNAMIC TABLES LIKE only matches object name in the current schema.
    try:
        cur.execute(f"SHOW DYNAMIC TABLES LIKE %s IN SCHEMA {_q_ident(obj.db)}.{_q_ident(obj.schema)}", (obj.name,))
        rows = _fetchall_dict(cur)
        return rows[0] if rows else None
    except Exception:
        return None


def _describe_dynamic_table(cur, obj: Obj) -> list[dict[str, object]] | None:
    try:
        cur.execute(f"DESCRIBE DYNAMIC TABLE {_q_fqn(obj.db, obj.schema, obj.name)}")
        return _fetchall_dict(cur)
    except Exception:
        return None


def _get_ddl(cur, obj: Obj) -> str | None:
    try:
        cur.execute("SELECT GET_DDL(%s, %s)", (obj.domain.upper(), obj.fqn()))
        row = cur.fetchone()
        return row[0] if row else None
    except Exception:
        return None


def _reconstruct_path(prev: dict[tuple[str, str, str, str], tuple[str, str, str, str] | None], target: Obj) -> list[Obj]:
    chain: list[Obj] = []
    cur_key: tuple[str, str, str, str] | None = target.key
    while cur_key is not None:
        db, schema, name, domain = cur_key
        chain.append(Obj(db, schema, name, domain))
        cur_key = prev.get(cur_key)
    chain.reverse()
    return chain


def main() -> int:
    ap = argparse.ArgumentParser(description="Deep dependency research for DRILL_CYCLE CDC blockers (Dynamic Tables FULL refresh / IMMUTABLE).")
    ap.add_argument("--root", default="PROD_WG.DRILL_BLAST.DRILL_CYCLE", help="Root view to analyze (db.schema.name)")
    ap.add_argument("--max-nodes", type=int, default=250, help="Safety cap on dependency traversal")
    ap.add_argument(
        "--max-depth",
        type=int,
        default=6,
        help="Max dependency depth to traverse from root (default: 6). Lower this if runs feel slow.",
    )
    ap.add_argument(
        "--include-ddl",
        action="store_true",
        help="Include GET_DDL for each Dynamic Table (can be slow). Default: off for speed.",
    )
    ap.add_argument(
        "--include-describe",
        action="store_true",
        help="Include DESCRIBE DYNAMIC TABLE output (can be slow). Default: off for speed.",
    )
    ap.add_argument(
        "--include-show",
        action="store_true",
        help="Include SHOW DYNAMIC TABLES row (can be slow / may require privileges). Default: off for speed.",
    )
    ap.add_argument(
        "--out-prefix",
        default="dependency_research",
        help="Output file prefix in the current folder (default: dependency_research)",
    )
    args = ap.parse_args()

    root_db, root_schema, root_name = _parse_fqn(args.root)
    root = Obj(root_db, root_schema, root_name, "VIEW")

    env = load_snowflake_env()
    out_dir = Path(__file__).resolve().parent
    ts = datetime.now(UTC).strftime("%Y%m%d_%H%M%S")
    out_json = out_dir / f"{args.out_prefix}__{ts}.json"
    out_md = out_dir / f"{args.out_prefix}__{ts}.md"

    results: dict[str, object] = {
        "root": {"db": root.db, "schema": root.schema, "name": root.name, "domain": root.domain},
        "generated_utc": datetime.now(UTC).isoformat(timespec="seconds").replace("+00:00", "Z"),
        "env": {
            "role": env.role,
            "warehouse": env.warehouse,
            "database": env.database,
            "schema": env.schema,
        },
        "show_object_dependencies": None,
        "show_object_dependencies_error": None,
        "graph": {"nodes_visited": 0, "edges": []},
        "dynamic_tables": [],
        "notes": [],
    }

    with connect() as conn:
        cur = conn.cursor()
        try:
            # Best-effort SHOW OBJECT DEPENDENCIES for the root view.
            show_rows, show_err = _try_show_object_deps(cur, view_fqn=_q_fqn(root.db, root.schema, root.name))
            results["show_object_dependencies"] = show_rows
            results["show_object_dependencies_error"] = show_err

            visited: set[tuple[str, str, str, str]] = set()
            prev: dict[tuple[str, str, str, str], tuple[str, str, str, str] | None] = {root.key: None}

            q: deque[tuple[Obj, int]] = deque([(root, 0)])
            dt_found: dict[tuple[str, str, str, str], Obj] = {}

            while q and len(visited) < args.max_nodes:
                obj, depth = q.popleft()
                if obj.key in visited:
                    continue
                visited.add(obj.key)

                if depth > args.max_depth:
                    continue

                try:
                    deps = _account_usage_deps(cur, obj)
                except Exception as e:
                    results["notes"].append(f"Failed OBJECT_DEPENDENCIES for {obj.fqn()} ({obj.domain}): {e}")
                    continue

                for dep in deps:
                    results["graph"]["edges"].append(
                        {
                            "from": {"db": obj.db, "schema": obj.schema, "name": obj.name, "domain": obj.domain},
                            "to": {"db": dep.db, "schema": dep.schema, "name": dep.name, "domain": dep.domain},
                        }
                    )

                    if dep.key not in prev:
                        prev[dep.key] = obj.key

                    dom = dep.domain.upper()
                    if dom == "DYNAMIC TABLE":
                        dt_found[dep.key] = dep
                        continue

                    # Traverse only a few domains to avoid exploding the graph.
                    if dom in {"VIEW", "MATERIALIZED VIEW"}:
                        q.append((dep, depth + 1))

            results["graph"]["nodes_visited"] = len(visited)

            for dt in dt_found.values():
                show_row = _show_dynamic_table(cur, dt) if args.include_show else None
                desc_rows = _describe_dynamic_table(cur, dt) if args.include_describe else None
                ddl = _get_ddl(cur, dt) if args.include_ddl else None
                path = _reconstruct_path(prev, dt)

                results["dynamic_tables"].append(
                    {
                        "fqn": dt.fqn(),
                        "domain": dt.domain,
                        "path_from_root": [{"db": o.db, "schema": o.schema, "name": o.name, "domain": o.domain} for o in path],
                        "show": show_row,
                        "describe": desc_rows,
                        "ddl": ddl,
                    }
                )

        finally:
            cur.close()

    out_json.write_text(json.dumps(results, indent=2, sort_keys=True), encoding="utf-8")

    # Minimal markdown summary for sharing with owners.
    lines: list[str] = []
    lines.append(f"# Dependency research: {root.fqn()} ({root.domain})")
    lines.append("")
    lines.append(f"Generated (UTC): {results['generated_utc']}")
    lines.append("")

    dts: list[dict[str, object]] = list(results.get("dynamic_tables") or [])
    if not dts:
        lines.append("No Dynamic Table dependencies found via ACCOUNT_USAGE traversal.")
        lines.append("If you expected Dynamic Tables, check privileges to SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES or try again later (ACCOUNT_USAGE lag).")
    else:
        lines.append(f"Found {len(dts)} Dynamic Table dependency(ies).")
        lines.append("")

        for item in dts:
            lines.append(f"## {item['fqn']}")
            show = item.get("show")
            if isinstance(show, dict):
                # Print key fields if present
                for k in ["refresh_mode", "target_lag", "warehouse", "name", "database_name", "schema_name"]:
                    if k in show:
                        lines.append(f"- {k}: {show[k]}")
            else:
                lines.append("- show: (not available)")

            path = item.get("path_from_root")
            if isinstance(path, list) and path:
                chain = " -> ".join(f"{p['db']}.{p['schema']}.{p['name']}[{p['domain']}]" for p in path)
                lines.append(f"- path: {chain}")

            ddl = item.get("ddl")
            if isinstance(ddl, str) and ddl.strip():
                lines.append("")
                lines.append("DDL (from GET_DDL):")
                lines.append("```sql")
                lines.append(ddl.strip().rstrip(";") + ";")
                lines.append("```")
            else:
                lines.append("- ddl: (not available)")

            lines.append("")
            lines.append("Owner action (for stream-on-view enablement):")
            lines.append("- If this Dynamic Table uses REFRESH_MODE='FULL', Snowflake requires an IMMUTABLE constraint to support change tracking/streams downstream.")
            lines.append("- Use the DDL above as the exact starting point; add an IMMUTABLE constraint only if the DT query is deterministic.")
            lines.append("")

    out_md.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")

    print("Wrote:")
    print(" ", out_json)
    print(" ", out_md)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
