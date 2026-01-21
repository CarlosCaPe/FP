"""
SQL Azure Database Schema Extractor v3
Uses azure-identity for authentication
Extracts ALL SQL object types: Tables, Views, Procedures, Functions,
Table Types, User-Defined Types, Triggers, Sequences, Synonyms
"""
import pyodbc
import struct
from azure.identity import AzureCliCredential, DefaultAzureCredential, InteractiveBrowserCredential
import os
from pathlib import Path
from datetime import datetime

# SQL Azure servers
SERVERS = [
    {
        "name": "DEV",
        "server": "azwd22midbx02.eb8a77f2eea6.database.windows.net",
        "prefix": "azwd"
    },
    {
        "name": "TEST",
        "server": "azwt22midbx02.9959d3e6fe6e.database.windows.net",
        "prefix": "azwt"
    },
    {
        "name": "PROD",
        "server": "azwp22midbx02.8232c56adfdf.database.windows.net",
        "prefix": "azwp"
    }
]

BASE_DIR = Path(__file__).parent

# Get Azure AD token
def get_token():
    """Get Azure AD access token for SQL using Interactive Browser"""
    credential = InteractiveBrowserCredential()
    token = credential.get_token("https://database.windows.net/.default")
    return token.token

def get_connection_with_token(server: str, database: str, token: str):
    """Connect using access token"""
    token_bytes = token.encode("UTF-16-LE")
    token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
    
    conn_str = (
        f"Driver={{ODBC Driver 17 for SQL Server}};"
        f"Server=tcp:{server},1433;"
        f"Database={database};"
        f"Encrypt=yes;"
        f"TrustServerCertificate=no;"
        f"Connection Timeout=30;"
    )

    SQL_COPT_SS_ACCESS_TOKEN = 1256
    conn = pyodbc.connect(conn_str, attrs_before={SQL_COPT_SS_ACCESS_TOKEN: token_struct})
    return conn

def list_databases(server: str, token: str) -> list:
    """List all accessible databases"""
    try:
        conn = get_connection_with_token(server, "master", token)
        cursor = conn.cursor()
        cursor.execute("""
            SELECT name
            FROM sys.databases
            WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
            AND state = 0
            ORDER BY name
        """)
        databases = [row[0] for row in cursor.fetchall()]
        conn.close()
        return databases
    except Exception as e:
        print(f"   Cannot list databases: {e}")
        return []

def get_schemas(conn) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT SCHEMA_NAME
        FROM INFORMATION_SCHEMA.SCHEMATA
        WHERE SCHEMA_NAME NOT IN ('sys', 'INFORMATION_SCHEMA', 'guest')
        ORDER BY SCHEMA_NAME
    """)
    return [row[0] for row in cursor.fetchall()]

def get_tables(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = ? AND TABLE_TYPE = 'BASE TABLE'
        ORDER BY TABLE_NAME
    """, schema)
    return [row[0] for row in cursor.fetchall()]

def get_views(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = ?
        ORDER BY TABLE_NAME
    """, schema)
    return [row[0] for row in cursor.fetchall()]

def get_procedures(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT ROUTINE_NAME
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE ROUTINE_SCHEMA = ? AND ROUTINE_TYPE = 'PROCEDURE'
        ORDER BY ROUTINE_NAME
    """, schema)
    return [row[0] for row in cursor.fetchall()]

def get_functions(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT ROUTINE_NAME
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE ROUTINE_SCHEMA = ? AND ROUTINE_TYPE = 'FUNCTION'
        ORDER BY ROUTINE_NAME
    """, schema)
    return [row[0] for row in cursor.fetchall()]

# NEW: Table Types (User-Defined Table Types)
def get_table_types(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT t.name
        FROM sys.table_types t
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name = ?
        ORDER BY t.name
    """, schema)
    return [row[0] for row in cursor.fetchall()]

# NEW: User-Defined Types (scalar)
def get_user_types(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT t.name
        FROM sys.types t
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name = ? AND t.is_user_defined = 1 AND t.is_table_type = 0
        ORDER BY t.name
    """, schema)
    return [row[0] for row in cursor.fetchall()]

# NEW: Triggers
def get_triggers(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT tr.name
        FROM sys.triggers tr
        INNER JOIN sys.objects o ON tr.parent_id = o.object_id
        INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
        WHERE s.name = ? AND tr.parent_class = 1
        ORDER BY tr.name
    """, schema)
    return [row[0] for row in cursor.fetchall()]

# NEW: Sequences
def get_sequences(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT seq.name
        FROM sys.sequences seq
        INNER JOIN sys.schemas s ON seq.schema_id = s.schema_id
        WHERE s.name = ?
        ORDER BY seq.name
    """, schema)
    return [row[0] for row in cursor.fetchall()]

# NEW: Synonyms
def get_synonyms(conn, schema: str) -> list:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT syn.name
        FROM sys.synonyms syn
        INNER JOIN sys.schemas s ON syn.schema_id = s.schema_id
        WHERE s.name = ?
        ORDER BY syn.name
    """, schema)
    return [row[0] for row in cursor.fetchall()]

def get_table_ddl(conn, schema: str, table: str) -> str:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT
            c.COLUMN_NAME,
            c.DATA_TYPE,
            c.CHARACTER_MAXIMUM_LENGTH,
            c.NUMERIC_PRECISION,
            c.NUMERIC_SCALE,
            c.IS_NULLABLE,
            c.COLUMN_DEFAULT
        FROM INFORMATION_SCHEMA.COLUMNS c
        WHERE c.TABLE_SCHEMA = ? AND c.TABLE_NAME = ?
        ORDER BY c.ORDINAL_POSITION
    """, schema, table)
    columns = cursor.fetchall()

    ddl_lines = [f"CREATE TABLE [{schema}].[{table}] ("]

    col_defs = []
    for col in columns:
        col_name, data_type, char_len, num_prec, num_scale, nullable, default = col
        if char_len and char_len > 0:
            if char_len == -1:
                type_def = f"{data_type}(MAX)"
            else:
                type_def = f"{data_type}({char_len})"
        elif num_prec and data_type in ('decimal', 'numeric'):
            type_def = f"{data_type}({num_prec},{num_scale or 0})"
        else:
            type_def = data_type

        null_def = "NULL" if nullable == "YES" else "NOT NULL"
        default_def = f" DEFAULT {default}" if default else ""

        col_defs.append(f"    [{col_name}] {type_def} {null_def}{default_def}")

    ddl_lines.append(",\n".join(col_defs))
    ddl_lines.append(");")

    return "\n".join(ddl_lines)

def get_view_ddl(conn, schema: str, view: str) -> str:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT VIEW_DEFINITION
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
    """, schema, view)
    row = cursor.fetchone()
    if row and row[0]:
        return f"CREATE VIEW [{schema}].[{view}] AS\n{row[0]}"
    return f"-- Unable to get definition for [{schema}].[{view}]"

def get_procedure_ddl(conn, schema: str, proc: str) -> str:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT ROUTINE_DEFINITION
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE ROUTINE_SCHEMA = ? AND ROUTINE_NAME = ? AND ROUTINE_TYPE = 'PROCEDURE'
    """, schema, proc)
    row = cursor.fetchone()
    if row and row[0]:
        return row[0]

    try:
        cursor.execute(f"EXEC sp_helptext '[{schema}].[{proc}]'")
        lines = [row[0] for row in cursor.fetchall()]
        return "".join(lines)
    except:
        return f"-- Unable to get definition for [{schema}].[{proc}]"

def get_function_ddl(conn, schema: str, func: str) -> str:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT ROUTINE_DEFINITION
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE ROUTINE_SCHEMA = ? AND ROUTINE_NAME = ? AND ROUTINE_TYPE = 'FUNCTION'
    """, schema, func)
    row = cursor.fetchone()
    if row and row[0]:
        return row[0]
    return f"-- Unable to get definition for [{schema}].[{func}]"

# NEW: Table Type DDL
def get_table_type_ddl(conn, schema: str, tt_name: str) -> str:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            c.name AS column_name,
            ty.name AS type_name,
            c.max_length,
            c.precision,
            c.scale,
            c.is_nullable
        FROM sys.table_types tt
        INNER JOIN sys.schemas s ON tt.schema_id = s.schema_id
        INNER JOIN sys.columns c ON c.object_id = tt.type_table_object_id
        INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
        WHERE s.name = ? AND tt.name = ?
        ORDER BY c.column_id
    """, schema, tt_name)
    columns = cursor.fetchall()
    
    ddl_lines = [f"CREATE TYPE [{schema}].[{tt_name}] AS TABLE ("]
    col_defs = []
    for col in columns:
        col_name, type_name, max_len, prec, scale, is_nullable = col
        if type_name in ('varchar', 'nvarchar', 'char', 'nchar', 'binary', 'varbinary'):
            if max_len == -1:
                type_def = f"{type_name}(MAX)"
            elif type_name.startswith('n'):
                type_def = f"{type_name}({max_len // 2})"
            else:
                type_def = f"{type_name}({max_len})"
        elif type_name in ('decimal', 'numeric'):
            type_def = f"{type_name}({prec},{scale})"
        else:
            type_def = type_name
        null_def = "NULL" if is_nullable else "NOT NULL"
        col_defs.append(f"    [{col_name}] {type_def} {null_def}")
    
    ddl_lines.append(",\n".join(col_defs))
    ddl_lines.append(");")
    return "\n".join(ddl_lines)

# NEW: User-Defined Type DDL
def get_user_type_ddl(conn, schema: str, type_name: str) -> str:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            bt.name AS base_type,
            t.max_length,
            t.precision,
            t.scale,
            t.is_nullable
        FROM sys.types t
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        INNER JOIN sys.types bt ON t.system_type_id = bt.user_type_id
        WHERE s.name = ? AND t.name = ? AND t.is_user_defined = 1
    """, schema, type_name)
    row = cursor.fetchone()
    if row:
        base_type, max_len, prec, scale, is_nullable = row
        if base_type in ('varchar', 'nvarchar', 'char', 'nchar'):
            if max_len == -1:
                type_spec = f"{base_type}(MAX)"
            elif base_type.startswith('n'):
                type_spec = f"{base_type}({max_len // 2})"
            else:
                type_spec = f"{base_type}({max_len})"
        elif base_type in ('decimal', 'numeric'):
            type_spec = f"{base_type}({prec},{scale})"
        else:
            type_spec = base_type
        null_def = "NULL" if is_nullable else "NOT NULL"
        return f"CREATE TYPE [{schema}].[{type_name}] FROM {type_spec} {null_def};"
    return f"-- Unable to get definition for [{schema}].[{type_name}]"

# NEW: Trigger DDL
def get_trigger_ddl(conn, schema: str, trigger_name: str) -> str:
    cursor = conn.cursor()
    try:
        cursor.execute("""
            SELECT m.definition
            FROM sys.triggers tr
            INNER JOIN sys.sql_modules m ON tr.object_id = m.object_id
            INNER JOIN sys.objects o ON tr.parent_id = o.object_id
            INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
            WHERE s.name = ? AND tr.name = ?
        """, schema, trigger_name)
        row = cursor.fetchone()
        if row and row[0]:
            return row[0]
    except:
        pass
    return f"-- Unable to get definition for trigger [{trigger_name}]"

# NEW: Sequence DDL
def get_sequence_ddl(conn, schema: str, seq_name: str) -> str:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            ty.name AS type_name,
            seq.start_value,
            seq.increment,
            seq.minimum_value,
            seq.maximum_value,
            seq.is_cycling
        FROM sys.sequences seq
        INNER JOIN sys.schemas s ON seq.schema_id = s.schema_id
        INNER JOIN sys.types ty ON seq.user_type_id = ty.user_type_id
        WHERE s.name = ? AND seq.name = ?
    """, schema, seq_name)
    row = cursor.fetchone()
    if row:
        type_name, start, incr, min_val, max_val, is_cycling = row
        cycle = "CYCLE" if is_cycling else "NO CYCLE"
        return f"""CREATE SEQUENCE [{schema}].[{seq_name}]
    AS {type_name}
    START WITH {start}
    INCREMENT BY {incr}
    MINVALUE {min_val}
    MAXVALUE {max_val}
    {cycle};"""
    return f"-- Unable to get definition for [{schema}].[{seq_name}]"

# NEW: Synonym DDL
def get_synonym_ddl(conn, schema: str, syn_name: str) -> str:
    cursor = conn.cursor()
    cursor.execute("""
        SELECT base_object_name
        FROM sys.synonyms syn
        INNER JOIN sys.schemas s ON syn.schema_id = s.schema_id
        WHERE s.name = ? AND syn.name = ?
    """, schema, syn_name)
    row = cursor.fetchone()
    if row:
        return f"CREATE SYNONYM [{schema}].[{syn_name}] FOR {row[0]};"
    return f"-- Unable to get definition for [{schema}].[{syn_name}]"

def extract_database(server_info: dict, database: str, token: str):
    server = server_info["server"]
    env_name = server_info["name"]

    print(f"\n   Database: {database}")

    try:
        conn = get_connection_with_token(server, database, token)
    except Exception as e:
        print(f"     Cannot connect: {e}")
        return 0

    db_dir = BASE_DIR / env_name / database

    schemas = get_schemas(conn)
    total_objects = 0

    for schema in schemas:
        tables = get_tables(conn, schema)
        views = get_views(conn, schema)
        procs = get_procedures(conn, schema)
        funcs = get_functions(conn, schema)
        table_types = get_table_types(conn, schema)
        user_types = get_user_types(conn, schema)
        triggers = get_triggers(conn, schema)
        sequences = get_sequences(conn, schema)
        synonyms = get_synonyms(conn, schema)

        if not (tables or views or procs or funcs or table_types or user_types or triggers or sequences or synonyms):
            continue

        print(f"     Schema: {schema}")

        if tables:
            table_dir = db_dir / schema / "Tables"
            table_dir.mkdir(parents=True, exist_ok=True)
            for table in tables:
                try:
                    ddl = get_table_ddl(conn, schema, table)
                    (table_dir / f"{table}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       Table {table}: {e}")
            print(f"       Tables: {len(tables)}")

        if views:
            view_dir = db_dir / schema / "Views"
            view_dir.mkdir(parents=True, exist_ok=True)
            for view in views:
                try:
                    ddl = get_view_ddl(conn, schema, view)
                    (view_dir / f"{view}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       View {view}: {e}")
            print(f"       Views: {len(views)}")

        if procs:
            proc_dir = db_dir / schema / "StoredProcedures"
            proc_dir.mkdir(parents=True, exist_ok=True)
            for proc in procs:
                try:
                    ddl = get_procedure_ddl(conn, schema, proc)
                    (proc_dir / f"{proc}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       Procedure {proc}: {e}")
            print(f"       Procedures: {len(procs)}")

        if funcs:
            func_dir = db_dir / schema / "Functions"
            func_dir.mkdir(parents=True, exist_ok=True)
            for func in funcs:
                try:
                    ddl = get_function_ddl(conn, schema, func)
                    (func_dir / f"{func}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       Function {func}: {e}")
            print(f"       Functions: {len(funcs)}")

        if table_types:
            tt_dir = db_dir / schema / "TableTypes"
            tt_dir.mkdir(parents=True, exist_ok=True)
            for tt in table_types:
                try:
                    ddl = get_table_type_ddl(conn, schema, tt)
                    (tt_dir / f"{tt}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       TableType {tt}: {e}")
            print(f"       TableTypes: {len(table_types)}")

        if user_types:
            ut_dir = db_dir / schema / "UserDefinedTypes"
            ut_dir.mkdir(parents=True, exist_ok=True)
            for ut in user_types:
                try:
                    ddl = get_user_type_ddl(conn, schema, ut)
                    (ut_dir / f"{ut}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       UserType {ut}: {e}")
            print(f"       UserDefinedTypes: {len(user_types)}")

        if triggers:
            tr_dir = db_dir / schema / "Triggers"
            tr_dir.mkdir(parents=True, exist_ok=True)
            for tr in triggers:
                try:
                    ddl = get_trigger_ddl(conn, schema, tr)
                    (tr_dir / f"{tr}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       Trigger {tr}: {e}")
            print(f"       Triggers: {len(triggers)}")

        if sequences:
            seq_dir = db_dir / schema / "Sequences"
            seq_dir.mkdir(parents=True, exist_ok=True)
            for seq in sequences:
                try:
                    ddl = get_sequence_ddl(conn, schema, seq)
                    (seq_dir / f"{seq}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       Sequence {seq}: {e}")
            print(f"       Sequences: {len(sequences)}")

        if synonyms:
            syn_dir = db_dir / schema / "Synonyms"
            syn_dir.mkdir(parents=True, exist_ok=True)
            for syn in synonyms:
                try:
                    ddl = get_synonym_ddl(conn, schema, syn)
                    (syn_dir / f"{syn}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"       Synonym {syn}: {e}")
            print(f"       Synonyms: {len(synonyms)}")

    conn.close()
    print(f"     Total objects extracted: {total_objects}")
    return total_objects

def main():
    print("=" * 80)
    print("SQL Azure Schema Extractor v3 - ALL Object Types")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    print("Object types: Tables, Views, Procedures, Functions,")
    print("              TableTypes, UserDefinedTypes, Triggers, Sequences, Synonyms")

    print("\n Authenticating with Azure AD...")

    try:
        token = get_token()
        print("    Authentication successful\n")
    except Exception as e:
        print(f"    Authentication failed: {e}")
        return

    total_all = 0

    for server_info in SERVERS:
        print(f"\n  Server: {server_info['name']} ({server_info['server']})")
        print("-" * 60)

        env_dir = BASE_DIR / server_info["name"]
        env_dir.mkdir(parents=True, exist_ok=True)

        databases = list_databases(server_info["server"], token)

        if not databases:
            print("   No accessible databases found")
            continue

        print(f"  Found {len(databases)} databases: {', '.join(databases)}")

        for db in databases:
            count = extract_database(server_info, db, token)
            if count:
                total_all += count

    print("\n" + "=" * 80)
    print(f"Completed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Total objects extracted: {total_all}")
    print("=" * 80)

if __name__ == "__main__":
    main()
