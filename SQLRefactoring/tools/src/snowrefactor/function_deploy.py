from __future__ import annotations

import json
import re
import time
from pathlib import Path

from snowflake.connector.errors import ProgrammingError

from snowrefactor.snowflake_conn import connect, load_snowflake_env


def _split_sql_statements(sql: str) -> list[str]:
    """Split a SQL script into statements on semicolons, ignoring semicolons inside single-quoted strings.

    This is intentionally simple and tailored to our generated DDL files.
    """
    s = sql.strip()
    out: list[str] = []
    buf: list[str] = []
    in_sq = False
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == "'":
            # Handle escaped single-quote inside a string: ''
            if in_sq and i + 1 < len(s) and s[i + 1] == "'":
                buf.append("''")
                i += 2
                continue
            in_sq = not in_sq
            buf.append(ch)
            i += 1
            continue

        if ch == ";" and not in_sq:
            stmt = "".join(buf).strip()
            if stmt:
                out.append(stmt)
            buf = []
            i += 1
            continue

        buf.append(ch)
        i += 1

    tail = "".join(buf).strip()
    if tail:
        out.append(tail)
    return out


def _summarize_statement(stmt: str) -> str:
    compact = " ".join(stmt.strip().split())
    upper = compact.upper()
    if upper.startswith("CREATE") or upper.startswith("ALTER") or upper.startswith("DROP"):
        return compact[:140] + ("..." if len(compact) > 140 else "")
    return compact[:80] + ("..." if len(compact) > 80 else "")


def _is_ignorable_dynamic_table_exists_error(err: ProgrammingError) -> bool:
    # Snowflake sometimes returns an error object for idempotent Dynamic Table DDL with a message like:
    #   "DT_SENSOR_LATEST_MOR already exists, statement succeeded."
    # We treat that as non-fatal so re-deploys keep going.
    msg = str(err).lower()
    # Treat any "already exists" as ignorable for Dynamic Tables.
    # Re-deploys should not be blocked by DT existence.
    return "already exists" in msg


def _extract_dynamic_table_name(stmt: str) -> str | None:
    m = re.search(
        r"(?is)\bcreate\s+(?:or\s+replace\s+)?dynamic\s+table\s+(?:if\s+not\s+exists\s+)?([^\s\(]+)",
        stmt,
    )
    if not m:
        return None
    raw = m.group(1).strip()
    # If qualified, SHOW ... LIKE only needs the object name in the current schema.
    name = raw.split(".")[-1]
    if name.startswith('"') and name.endswith('"') and len(name) >= 2:
        name = name[1:-1].replace('""', '"')
    return name.strip() or None


def _dynamic_table_exists(conn, name: str) -> bool:
    cur = conn.cursor()
    try:
        # Relies on the session already being in the target database/schema.
        safe_name = name.replace("'", "''")
        cur.execute(f"SHOW DYNAMIC TABLES LIKE '{safe_name}'")
        return cur.fetchone() is not None
    finally:
        cur.close()


def _rewrite_unqualified_function_name(*, ddl: str, target_fqn: str) -> str:
    """Rewrite CREATE OR REPLACE FUNCTION <name>(...) to CREATE OR REPLACE FUNCTION <target_fqn>(...).

    Snowflake GET_DDL for functions often returns an unqualified, quoted name like:
      CREATE OR REPLACE FUNCTION "SENSOR_SNAPSHOT_GET"(...)
    For sandbox deployment we want:
      CREATE OR REPLACE FUNCTION SANDBOX_DB.SCHEMA.SENSOR_SNAPSHOT_GET(...)
    """
    text = ddl.strip().rstrip(";")
    # Replace only the first occurrence after CREATE OR REPLACE FUNCTION
    return re.sub(
        r"(?is)\bcreate\s+or\s+replace\s+function\s+\"?[^\"\(\s]+\"?\s*\(",
        f"CREATE OR REPLACE FUNCTION {target_fqn}(",
        text,
        count=1,
    )


def _rewrite_all_unqualified_function_names(*, ddl: str, target_fqn: str) -> str:
    """Rewrite all CREATE OR REPLACE FUNCTION <name>(...) headers to target_fqn."""
    text = ddl.strip().rstrip(";")
    return re.sub(
        r"(?is)\bcreate\s+or\s+replace\s+function\s+\"?[^\"\(\s]+\"?\s*\(",
        f"CREATE OR REPLACE FUNCTION {target_fqn}(",
        text,
    )


def deploy_function_from_folder(
    *,
    folder_name: str,
    queries_dir: Path,
    ddl_filename: str = "refactor_ddl.sql",
    target_name: str | None = None,
) -> str:
    folder = queries_dir / folder_name
    ddl_path = folder / ddl_filename
    if not ddl_path.exists():
        raise FileNotFoundError(f"Missing {ddl_path}")

    env = load_snowflake_env()
    if not env.database or not env.schema:
        raise RuntimeError(
            "Missing sandbox target database/schema. Set CONN_LIB_SNOWFLAKE_DATABASE and CONN_LIB_SNOWFLAKE_SCHEMA."
        )

    if not target_name:
        # Folder is safe name: DB__SCHEMA__NAME
        target_name = folder_name.split("__")[-1]
    target_fqn = f"{env.database}.{env.schema}.{target_name}"

    ddl = ddl_path.read_text(encoding="utf-8")
    # If ddl already targets the sandbox, keep as-is. Otherwise rewrite all headers.
    if re.search(r"(?is)\bcreate\s+or\s+replace\s+function\s+" + re.escape(target_fqn) + r"\b", ddl):
        final_sql = ddl.strip().rstrip(";")
    else:
        final_sql = _rewrite_all_unqualified_function_names(ddl=ddl, target_fqn=target_fqn)

    # Optional template substitution for multi-object deploys.
    # Dynamic Tables require an explicit warehouse; allow using the current env warehouse.
    if "{{WAREHOUSE}}" in final_sql:
        if not env.warehouse:
            raise RuntimeError(
                "DDL contains {{WAREHOUSE}} but CONN_LIB_SNOWFLAKE_WAREHOUSE is not set. "
                "Set it in your .env or environment variables."
            )

        wh = env.warehouse.strip()
        # Always quote to preserve case/special chars.
        wh_quoted = '"' + wh.replace('"', '""') + '"'
        final_sql = final_sql.replace("{{WAREHOUSE}}", wh_quoted)

    with connect() as conn:
        # Most deploy statements should not hang forever.
        # We'll temporarily relax the timeout for Dynamic Table creation only.
        cur0 = conn.cursor()
        try:
            cur0.execute("ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 3600")
        finally:
            cur0.close()

        statements = _split_sql_statements(final_sql)
        inflight_path = folder / "dynamic_tables_inflight.json"
        try:
            inflight: dict[str, str] = json.loads(inflight_path.read_text(encoding="utf-8"))
        except FileNotFoundError:
            inflight = {}
        except Exception:
            inflight = {}
        # For DT creation, don't block the whole deploy indefinitely.
        # If a DT needs initial refresh, we submit it async and wait a bit,
        # then stop early with a clear message so the user can re-run later.
        dt_wait_seconds = 60

        for idx, stmt in enumerate(statements, start=1):
            summary = _summarize_statement(stmt)
            print(f"[{idx}/{len(statements)}] Executing: {summary}")

            is_dynamic_table_ddl = re.match(r"(?is)^\s*create\s+(or\s+replace\s+)?dynamic\s+table\b", stmt) is not None

            if is_dynamic_table_ddl:
                print("    Note: Dynamic Table creation/initial refresh can take a while the first time.")

                # Important: don't rebuild the Dynamic Table on every deploy.
                # If it already exists, skip the CREATE to avoid a full refresh/recompute.
                dt_name = _extract_dynamic_table_name(stmt)
                if dt_name and _dynamic_table_exists(conn, dt_name):
                    if dt_name in inflight:
                        inflight.pop(dt_name, None)
                        inflight_path.write_text(json.dumps(inflight, indent=2, sort_keys=True), encoding="utf-8")
                    print(f"    Note: Dynamic Table {dt_name} already exists; skipping CREATE to avoid rebuild.")
                    continue

            cur = conn.cursor()
            try:
                try:
                    if is_dynamic_table_ddl:
                        dt_name = _extract_dynamic_table_name(stmt) or "<unknown>"

                        # If we've already kicked off this DT build previously, avoid starting another one.
                        if dt_name in inflight:
                            existing_qid = inflight[dt_name]
                            status = conn.get_query_status(existing_qid)
                            if conn.is_still_running(status):
                                raise RuntimeError(
                                    "Dynamic Table creation is still running (initial refresh can take a while). "
                                    f"Query id: {existing_qid}. "
                                    "Wait for it to finish in Snowflake History, then re-run deploy-function."
                                )
                            # If it's not still running, drop the marker and allow a re-attempt.
                            inflight.pop(dt_name, None)
                            inflight_path.write_text(json.dumps(inflight, indent=2, sort_keys=True), encoding="utf-8")

                        # Let DT creation run longer than the normal session timeout.
                        cur.execute("ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 0")

                        # Dynamic Table CREATE can take a long time and sometimes appears to hang.
                        # Using async execution lets us poll status and keeps feedback flowing.
                        sfqid_raw = cur.execute_async(stmt)
                        sfqid = sfqid_raw.get("queryId") if isinstance(sfqid_raw, dict) else sfqid_raw
                        print(f"    Query id: {sfqid}")

                        inflight[dt_name] = str(sfqid)
                        inflight_path.write_text(json.dumps(inflight, indent=2, sort_keys=True), encoding="utf-8")

                        last_print = 0.0
                        start = time.time()
                        while True:
                            status = conn.get_query_status(sfqid)
                            if not conn.is_still_running(status):
                                break

                            if time.time() - start >= dt_wait_seconds:
                                raise RuntimeError(
                                    "Dynamic Table creation is still running (initial refresh can take a while). "
                                    f"Query id: {sfqid}. "
                                    "Wait for it to finish in Snowflake History, then re-run deploy-function."
                                )

                            now = time.time()
                            if now - last_print >= 15:
                                print(f"    Status: {status}")
                                last_print = now
                            time.sleep(5)

                        # Raises if the statement failed.
                        cur.get_results_from_sfqid(sfqid)

                        inflight.pop(dt_name, None)
                        inflight_path.write_text(json.dumps(inflight, indent=2, sort_keys=True), encoding="utf-8")

                        # Restore normal timeout for the rest of the deploy.
                        cur.execute("ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 3600")
                    else:
                        cur.execute(stmt)
                except ProgrammingError as e:
                    if is_dynamic_table_ddl and _is_ignorable_dynamic_table_exists_error(e):
                        print("    Note: Dynamic Table already exists; continuing.")
                    else:
                        raise
            finally:
                cur.close()

    (folder / "sandbox_function.txt").write_text(target_fqn + "\n", encoding="utf-8")
    return target_fqn
