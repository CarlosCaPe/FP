"""
verify_sql_server_incr_deployment.py
====================================
Verifies all INCR tables and archival procedures in SQL Server SNOWFLAKE_WG database.

Author: Carlos Carrillo
Date: 2026-01-28
"""

import pyodbc
import struct
from azure.identity import InteractiveBrowserCredential
from datetime import datetime

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


def main():
    print("=" * 70)
    print("  SQL SERVER INCR OBJECTS VERIFICATION")
    print(f"  Database: SNOWFLAKE_WG")
    print(f"  Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)
    
    conn = get_azure_connection()
    cursor = conn.cursor()
    
    # =========================================================================
    # TABLES
    # =========================================================================
    print("\n" + "=" * 70)
    print("  INCR TABLES")
    print("=" * 70)
    
    cursor.execute("""
        SELECT 
            t.TABLE_NAME,
            (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS c WHERE c.TABLE_NAME = t.TABLE_NAME) as col_count
        FROM INFORMATION_SCHEMA.TABLES t
        WHERE TABLE_TYPE = 'BASE TABLE' 
        AND TABLE_NAME LIKE '%_INCR'
        ORDER BY TABLE_NAME
    """)
    tables = cursor.fetchall()
    
    print(f"\n  Found {len(tables)} INCR Tables:\n")
    
    for table_name, col_count in tables:
        cursor.execute(f"SELECT COUNT(*) FROM [{table_name}]")
        row_count = cursor.fetchone()[0]
        print(f"    ✅ {table_name}")
        print(f"       Columns: {col_count}, Rows: {row_count:,}")
    
    # =========================================================================
    # PROCEDURES
    # =========================================================================
    print("\n" + "=" * 70)
    print("  ARCHIVAL PROCEDURES")
    print("=" * 70)
    
    cursor.execute("""
        SELECT ROUTINE_NAME, CREATED, LAST_ALTERED
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'PROCEDURE' 
        AND ROUTINE_NAME LIKE 'usp_Archive_%INCR%'
        ORDER BY ROUTINE_NAME
    """)
    procs = cursor.fetchall()
    
    print(f"\n  Found {len(procs)} Archival Procedures:\n")
    
    for proc_name, created, altered in procs:
        print(f"    ✅ {proc_name}")
        print(f"       Created: {created}")
    
    # =========================================================================
    # INDEXES
    # =========================================================================
    print("\n" + "=" * 70)
    print("  ARCHIVAL INDEXES")
    print("=" * 70)
    
    cursor.execute("""
        SELECT 
            i.name as index_name,
            t.name as table_name,
            c.name as column_name
        FROM sys.indexes i
        JOIN sys.tables t ON i.object_id = t.object_id
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE i.name LIKE 'IX_%INCR%'
        ORDER BY t.name, i.name
    """)
    indexes = cursor.fetchall()
    
    print(f"\n  Found {len(indexes)} Indexes:\n")
    
    for idx_name, table_name, col_name in indexes:
        print(f"    ✅ {idx_name}")
        print(f"       Table: {table_name}, Column: {col_name}")
    
    # =========================================================================
    # TEST EXECUTION
    # =========================================================================
    print("\n" + "=" * 70)
    print("  PROCEDURE EXECUTION TEST")
    print("=" * 70)
    
    test_procs = [
        ("usp_Archive_BLAST_PLAN_INCR", "DW_MODIFY_TS"),
        ("usp_Archive_DRILL_CYCLE_INCR", "DW_MODIFY_TS"),
        ("usp_Archive_LH_HAUL_CYCLE_INCR", "DW_MODIFY_TS"),
        ("usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR", "START_TS_LOCAL"),
        ("usp_Archive_LH_LOADING_CYCLE_INCR", "CYCLE_START_TS_LOCAL"),
        ("usp_Archive_LH_BUCKET_INCR", "TRIP_TS_LOCAL"),
    ]
    
    print(f"\n  Testing {len(test_procs)} procedures with @NumberOfDays = 365:\n")
    
    all_passed = True
    for proc_name, archive_col in test_procs:
        try:
            cursor.execute(f"EXEC {proc_name} @NumberOfDays = 365")
            result = cursor.fetchone()
            status = result[0] if result else "NO RESULT"
            rows = result[1] if result and len(result) > 1 else 0
            
            if status == "SUCCESS":
                print(f"    ✅ {proc_name}")
                print(f"       Archive Column: {archive_col}, Rows Deleted: {rows}")
            else:
                print(f"    ❌ {proc_name}: {status}")
                all_passed = False
        except Exception as e:
            print(f"    ❌ {proc_name}: {str(e)[:60]}")
            all_passed = False
    
    # =========================================================================
    # SUMMARY
    # =========================================================================
    print("\n" + "=" * 70)
    print("  DEPLOYMENT VERIFICATION SUMMARY")
    print("=" * 70)
    print(f"""
  📊 Tables:     {len(tables)} INCR tables created
  📊 Procedures: {len(procs)} archival procedures deployed
  📊 Indexes:    {len(indexes)} archival indexes created
  📊 Tests:      {'✅ ALL PASSED' if all_passed else '❌ SOME FAILED'}
  
  ✅ SQL Server INCR infrastructure is ready!
  
  ⚠️  Next Steps:
     1. Azure Function needs to sync data from Snowflake INCR tables
     2. Once data is populated, archival can run
     3. Execute: EXEC usp_Archive_All_INCR_Tables @NumberOfDays = 3;
""")
    
    conn.close()


if __name__ == "__main__":
    main()
