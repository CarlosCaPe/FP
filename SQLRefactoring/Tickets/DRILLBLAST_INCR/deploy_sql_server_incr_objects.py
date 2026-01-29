"""
deploy_sql_server_incr_objects.py
================================
Deploys all INCR tables and archival procedures to SQL Server SNOWFLAKE_WG database.

This script:
1. Creates 14 INCR tables (10 DRILL_BLAST + 4 LOAD_HAUL)
2. Deploys 14 archival stored procedures
3. Deploys 1 master archival procedure

Author: Carlos Carrillo
Date: 2026-01-28
"""

import pyodbc
import struct
from azure.identity import InteractiveBrowserCredential
from pathlib import Path
import sys

# SQL Server connection details
SERVER = "azwd22midbx02.eb8a77f2eea6.database.windows.net"
DATABASE = "SNOWFLAKE_WG"

def get_azure_connection():
    """Get Azure AD authenticated connection to SQL Server."""
    print(f"🔐 Authenticating to Azure AD...")
    credential = InteractiveBrowserCredential()
    token = credential.get_token("https://database.windows.net/.default")
    
    # Pack token for ODBC
    token_bytes = token.token.encode("UTF-16-LE")
    token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
    
    conn_str = (
        f"Driver={{ODBC Driver 17 for SQL Server}};"
        f"Server={SERVER};"
        f"Database={DATABASE};"
    )
    
    conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
    print(f"✅ Connected to {SERVER}/{DATABASE}")
    return conn


def deploy_tables(conn):
    """Deploy all INCR tables to SQL Server."""
    cursor = conn.cursor()
    
    tables_dir = Path(__file__).parent / "EXTRACTED_FOR_SQLSERVER" / "SQL_SERVER" / "TABLES"
    
    if not tables_dir.exists():
        print(f"❌ Tables directory not found: {tables_dir}")
        return 0, 0
    
    table_files = sorted(tables_dir.glob("*.sql"))
    
    print(f"\n📋 DEPLOYING {len(table_files)} TABLES...")
    print("=" * 60)
    
    success_count = 0
    failed_count = 0
    
    for sql_file in table_files:
        table_name = sql_file.stem
        try:
            ddl = sql_file.read_text(encoding='utf-8')
            
            # Split by GO statements and execute each batch
            batches = [b.strip() for b in ddl.split('\nGO\n') if b.strip()]
            
            for batch in batches:
                if batch and not batch.upper().startswith('GO'):
                    cursor.execute(batch)
            
            conn.commit()
            
            # Check if table exists
            cursor.execute(f"""
                SELECT COUNT(*) FROM sys.objects 
                WHERE object_id = OBJECT_ID(N'[dbo].[{table_name}]') 
                AND type in (N'U')
            """)
            exists = cursor.fetchone()[0] > 0
            
            if exists:
                print(f"  ✅ {table_name}")
                success_count += 1
            else:
                print(f"  ⚠️  {table_name} (created but not verified)")
                success_count += 1
                
        except Exception as e:
            print(f"  ❌ {table_name}: {str(e)[:80]}")
            failed_count += 1
            conn.rollback()
    
    return success_count, failed_count


def deploy_procedures(conn):
    """Deploy all archival procedures to SQL Server."""
    cursor = conn.cursor()
    
    proc_dir = Path(__file__).parent / "EXTRACTED_FOR_SQLSERVER" / "SQL_SERVER" / "PROCEDURES"
    
    if not proc_dir.exists():
        print(f"❌ Procedures directory not found: {proc_dir}")
        return 0, 0
    
    proc_files = sorted(proc_dir.glob("*.sql"))
    
    print(f"\n📋 DEPLOYING {len(proc_files)} PROCEDURES...")
    print("=" * 60)
    
    success_count = 0
    failed_count = 0
    
    for sql_file in proc_files:
        proc_name = sql_file.stem
        try:
            ddl = sql_file.read_text(encoding='utf-8')
            
            # Remove GO statements and execute the batch
            ddl_clean = ddl.replace('\nGO\n', '\n').replace('\nGO', '').replace('GO\n', '')
            ddl_clean = ddl_clean.strip()
            if ddl_clean.endswith('GO'):
                ddl_clean = ddl_clean[:-2].strip()
            
            cursor.execute(ddl_clean)
            conn.commit()
            
            print(f"  ✅ {proc_name}")
            success_count += 1
                
        except Exception as e:
            print(f"  ❌ {proc_name}: {str(e)[:80]}")
            failed_count += 1
            conn.rollback()
    
    return success_count, failed_count


def verify_deployment(conn):
    """Verify deployed objects."""
    cursor = conn.cursor()
    
    print(f"\n📋 VERIFYING DEPLOYMENT...")
    print("=" * 60)
    
    # Check tables
    cursor.execute("""
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_TYPE = 'BASE TABLE' 
        AND TABLE_NAME LIKE '%_INCR'
        ORDER BY TABLE_NAME
    """)
    tables = [row[0] for row in cursor.fetchall()]
    
    print(f"\n📊 INCR Tables Found: {len(tables)}")
    for t in tables:
        cursor.execute(f"SELECT COUNT(*) FROM [{t}]")
        row_count = cursor.fetchone()[0]
        print(f"    {t}: {row_count:,} rows")
    
    # Check procedures
    cursor.execute("""
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'PROCEDURE' 
        AND ROUTINE_NAME LIKE 'usp_Archive_%'
        ORDER BY ROUTINE_NAME
    """)
    procs = [row[0] for row in cursor.fetchall()]
    
    print(f"\n📊 Archival Procedures Found: {len(procs)}")
    for p in procs:
        print(f"    {p}")
    
    return len(tables), len(procs)


def main():
    print("=" * 70)
    print("  SQL SERVER INCR OBJECTS DEPLOYMENT")
    print("  Database: SNOWFLAKE_WG")
    print("=" * 70)
    
    try:
        conn = get_azure_connection()
        
        # Deploy tables
        tables_success, tables_failed = deploy_tables(conn)
        
        # Deploy procedures
        procs_success, procs_failed = deploy_procedures(conn)
        
        # Verify
        tables_found, procs_found = verify_deployment(conn)
        
        # Summary
        print("\n" + "=" * 70)
        print("  DEPLOYMENT SUMMARY")
        print("=" * 70)
        print(f"\n  TABLES:")
        print(f"    Deployed: {tables_success}")
        print(f"    Failed:   {tables_failed}")
        print(f"    Verified: {tables_found}")
        
        print(f"\n  PROCEDURES:")
        print(f"    Deployed: {procs_success}")
        print(f"    Failed:   {procs_failed}")
        print(f"    Verified: {procs_found}")
        
        if tables_failed == 0 and procs_failed == 0:
            print("\n  ✅ DEPLOYMENT COMPLETE - ALL OBJECTS CREATED")
        else:
            print(f"\n  ⚠️  DEPLOYMENT COMPLETED WITH {tables_failed + procs_failed} ERRORS")
        
        conn.close()
        
    except Exception as e:
        print(f"\n❌ Deployment failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
