"""
SQL Azure Database Schema Extractor
Connects to Azure SQL databases and extracts DDL for all objects
"""
import pyodbc
import os
from pathlib import Path
import json
from datetime import datetime

# SQL Azure servers from screenshot
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

# Base directory for SQL files
BASE_DIR = Path(__file__).parent

def get_connection(server: str, database: str = "master"):
    """Connect to SQL Azure using Azure AD Interactive auth"""
    conn_str = (
        f"Driver={{ODBC Driver 17 for SQL Server}};"
        f"Server={server};"
        f"Database={database};"
        f"Authentication=ActiveDirectoryInteractive;"
        f"Encrypt=yes;"
        f"TrustServerCertificate=no;"
    )
    return pyodbc.connect(conn_str)

def list_databases(server: str) -> list:
    """List all accessible databases on a server"""
    try:
        conn = get_connection(server, "master")
        cursor = conn.cursor()
        cursor.execute("""
            SELECT name 
            FROM sys.databases 
            WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
            AND state = 0  -- ONLINE
            ORDER BY name
        """)
        databases = [row[0] for row in cursor.fetchall()]
        conn.close()
        return databases
    except Exception as e:
        print(f"  ❌ Cannot list databases: {e}")
        return []

def get_schemas(conn) -> list:
    """Get all user schemas"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT SCHEMA_NAME 
        FROM INFORMATION_SCHEMA.SCHEMATA
        WHERE SCHEMA_NAME NOT IN ('sys', 'INFORMATION_SCHEMA', 'guest')
        ORDER BY SCHEMA_NAME
    """)
    return [row[0] for row in cursor.fetchall()]

def get_tables(conn, schema: str) -> list:
    """Get all tables in a schema"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = ? AND TABLE_TYPE = 'BASE TABLE'
        ORDER BY TABLE_NAME
    """, schema)
    return [row[0] for row in cursor.fetchall()]

def get_views(conn, schema: str) -> list:
    """Get all views in a schema"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.VIEWS 
        WHERE TABLE_SCHEMA = ?
        ORDER BY TABLE_NAME
    """, schema)
    return [row[0] for row in cursor.fetchall()]

def get_procedures(conn, schema: str) -> list:
    """Get all stored procedures in a schema"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_SCHEMA = ? AND ROUTINE_TYPE = 'PROCEDURE'
        ORDER BY ROUTINE_NAME
    """, schema)
    return [row[0] for row in cursor.fetchall()]

def get_functions(conn, schema: str) -> list:
    """Get all functions in a schema"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_SCHEMA = ? AND ROUTINE_TYPE = 'FUNCTION'
        ORDER BY ROUTINE_NAME
    """, schema)
    return [row[0] for row in cursor.fetchall()]

def get_table_ddl(conn, schema: str, table: str) -> str:
    """Generate CREATE TABLE DDL"""
    cursor = conn.cursor()
    
    # Get columns
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
        
        # Build data type
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
    
    # Get primary key
    cursor.execute("""
        SELECT 
            kcu.COLUMN_NAME
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu 
            ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
        WHERE tc.TABLE_SCHEMA = ? AND tc.TABLE_NAME = ? AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
        ORDER BY kcu.ORDINAL_POSITION
    """, schema, table)
    pk_cols = [row[0] for row in cursor.fetchall()]
    
    if pk_cols:
        ddl_lines.append(f"\n-- Primary Key: ({', '.join(pk_cols)})")
    
    return "\n".join(ddl_lines)

def get_view_ddl(conn, schema: str, view: str) -> str:
    """Get VIEW definition"""
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
    """Get stored procedure definition"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT ROUTINE_DEFINITION 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_SCHEMA = ? AND ROUTINE_NAME = ? AND ROUTINE_TYPE = 'PROCEDURE'
    """, schema, proc)
    row = cursor.fetchone()
    if row and row[0]:
        return row[0]
    
    # Try sp_helptext as fallback
    try:
        cursor.execute(f"EXEC sp_helptext '[{schema}].[{proc}]'")
        lines = [row[0] for row in cursor.fetchall()]
        return "".join(lines)
    except:
        return f"-- Unable to get definition for [{schema}].[{proc}]"

def get_function_ddl(conn, schema: str, func: str) -> str:
    """Get function definition"""
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

def extract_database(server_info: dict, database: str):
    """Extract all objects from a database"""
    server = server_info["server"]
    env_name = server_info["name"]
    
    print(f"\n  📂 Database: {database}")
    
    try:
        conn = get_connection(server, database)
    except Exception as e:
        print(f"    ❌ Cannot connect: {e}")
        return
    
    # Create directory structure
    db_dir = BASE_DIR / env_name / database
    
    schemas = get_schemas(conn)
    total_objects = 0
    
    for schema in schemas:
        tables = get_tables(conn, schema)
        views = get_views(conn, schema)
        procs = get_procedures(conn, schema)
        funcs = get_functions(conn, schema)
        
        if not (tables or views or procs or funcs):
            continue
        
        print(f"    📁 Schema: {schema}")
        
        # Tables
        if tables:
            table_dir = db_dir / schema / "Tables"
            table_dir.mkdir(parents=True, exist_ok=True)
            for table in tables:
                try:
                    ddl = get_table_ddl(conn, schema, table)
                    (table_dir / f"{table}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"      ⚠️ Table {table}: {e}")
            print(f"       Tables: {len(tables)}")
        
        # Views
        if views:
            view_dir = db_dir / schema / "Views"
            view_dir.mkdir(parents=True, exist_ok=True)
            for view in views:
                try:
                    ddl = get_view_ddl(conn, schema, view)
                    (view_dir / f"{view}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"      ⚠️ View {view}: {e}")
            print(f"       Views: {len(views)}")
        
        # Stored Procedures
        if procs:
            proc_dir = db_dir / schema / "StoredProcedures"
            proc_dir.mkdir(parents=True, exist_ok=True)
            for proc in procs:
                try:
                    ddl = get_procedure_ddl(conn, schema, proc)
                    (proc_dir / f"{proc}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"      ⚠️ Procedure {proc}: {e}")
            print(f"       Procedures: {len(procs)}")
        
        # Functions
        if funcs:
            func_dir = db_dir / schema / "Functions"
            func_dir.mkdir(parents=True, exist_ok=True)
            for func in funcs:
                try:
                    ddl = get_function_ddl(conn, schema, func)
                    (func_dir / f"{func}.sql").write_text(ddl, encoding='utf-8')
                    total_objects += 1
                except Exception as e:
                    print(f"      ⚠️ Function {func}: {e}")
            print(f"       Functions: {len(funcs)}")
    
    conn.close()
    print(f"    ✅ Total objects extracted: {total_objects}")
    return total_objects

def main():
    print("=" * 80)
    print("SQL Azure Schema Extractor")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    
    total_all = 0
    
    for server_info in SERVERS:
        print(f"\n🖥️  Server: {server_info['name']} ({server_info['server']})")
        print("-" * 60)
        
        # Create environment directory
        env_dir = BASE_DIR / server_info["name"]
        env_dir.mkdir(parents=True, exist_ok=True)
        
        databases = list_databases(server_info["server"])
        
        if not databases:
            print("  ⚠️ No accessible databases found")
            continue
        
        print(f"  Found {len(databases)} databases: {', '.join(databases)}")
        
        for db in databases:
            count = extract_database(server_info, db)
            if count:
                total_all += count
    
    print("\n" + "=" * 80)
    print(f"Completed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Total objects extracted: {total_all}")
    print("=" * 80)

if __name__ == "__main__":
    main()
