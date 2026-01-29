"""
deploy_procedures_only.py
=========================
Deploys all archival stored procedures to SQL Server SNOWFLAKE_WG database.
Handles GO statements properly for pyodbc.

Author: Carlos Carrillo
Date: 2026-01-28
"""

import pyodbc
import struct
from azure.identity import InteractiveBrowserCredential
from pathlib import Path
import re

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


def deploy_procedures(conn):
    """Deploy all archival procedures to SQL Server."""
    cursor = conn.cursor()
    
    proc_dir = Path(__file__).parent / "DDL-Scripts" / "SQL_SERVER" / "PROCEDURES"
    
    if not proc_dir.exists():
        print(f"❌ Procedures directory not found: {proc_dir}")
        return 0, 0
    
    proc_files = sorted([f for f in proc_dir.glob("*.sql") if f.stem != "README"])
    
    print(f"\n📋 DEPLOYING {len(proc_files)} PROCEDURES...")
    print("=" * 60)
    
    success_count = 0
    failed_count = 0
    
    for sql_file in proc_files:
        proc_name = sql_file.stem
        try:
            ddl = sql_file.read_text(encoding='utf-8')
            
            # Remove GO statements - pyodbc doesn't handle them
            ddl_clean = re.sub(r'\n\s*GO\s*\n', '\n', ddl, flags=re.IGNORECASE)
            ddl_clean = re.sub(r'\n\s*GO\s*$', '', ddl_clean, flags=re.IGNORECASE)
            ddl_clean = ddl_clean.strip()
            
            # Execute the DDL
            cursor.execute(ddl_clean)
            conn.commit()
            
            print(f"  ✅ {proc_name}")
            success_count += 1
                
        except Exception as e:
            error_msg = str(e)
            # Truncate long error messages
            if len(error_msg) > 100:
                error_msg = error_msg[:100] + "..."
            print(f"  ❌ {proc_name}: {error_msg}")
            failed_count += 1
            conn.rollback()
    
    return success_count, failed_count


def verify_procedures(conn):
    """Verify deployed procedures."""
    cursor = conn.cursor()
    
    print(f"\n📋 VERIFYING PROCEDURES...")
    print("=" * 60)
    
    # Check for INCR procedures
    cursor.execute("""
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'PROCEDURE' 
        AND ROUTINE_NAME LIKE 'usp_Archive_%INCR%'
        ORDER BY ROUTINE_NAME
    """)
    procs = [row[0] for row in cursor.fetchall()]
    
    print(f"\n📊 INCR Archival Procedures Found: {len(procs)}")
    for p in procs:
        print(f"    ✅ {p}")
    
    return len(procs)


def test_procedure(conn, proc_name):
    """Test executing a procedure."""
    cursor = conn.cursor()
    
    try:
        cursor.execute(f"EXEC {proc_name} @NumberOfDays = 365")
        result = cursor.fetchone()
        if result:
            status = result[0]
            rows_deleted = result[1] if len(result) > 1 else 0
            return status, rows_deleted
    except Exception as e:
        return "ERROR", str(e)[:50]


def main():
    print("=" * 70)
    print("  SQL SERVER PROCEDURE DEPLOYMENT")
    print("  Database: SNOWFLAKE_WG")
    print("=" * 70)
    
    conn = get_azure_connection()
    
    # Deploy procedures
    procs_success, procs_failed = deploy_procedures(conn)
    
    # Verify
    procs_found = verify_procedures(conn)
    
    # Test one procedure
    print(f"\n📋 TESTING PROCEDURES...")
    print("=" * 60)
    
    test_procs = [
        "usp_Archive_BLAST_PLAN_INCR",
        "usp_Archive_DRILL_CYCLE_INCR",
        "usp_Archive_LH_HAUL_CYCLE_INCR"
    ]
    
    for proc in test_procs:
        status, rows = test_procedure(conn, proc)
        if status == "SUCCESS":
            print(f"    ✅ {proc}: {status}, {rows} rows deleted")
        else:
            print(f"    ❌ {proc}: {status}")
    
    # Summary
    print("\n" + "=" * 70)
    print("  DEPLOYMENT SUMMARY")
    print("=" * 70)
    print(f"\n  PROCEDURES:")
    print(f"    Deployed: {procs_success}")
    print(f"    Failed:   {procs_failed}")
    print(f"    Verified: {procs_found}")
    
    if procs_failed == 0:
        print("\n  ✅ DEPLOYMENT COMPLETE - ALL PROCEDURES CREATED")
    else:
        print(f"\n  ⚠️  DEPLOYMENT COMPLETED WITH {procs_failed} ERRORS")
    
    conn.close()


if __name__ == "__main__":
    main()
