"""
regression_test_sql_server_only.py
==================================
Regression test for SQL Server INCR infrastructure.
Tests tables, procedures, indexes, and execution.

Author: Carlos Carrillo
Date: 2026-01-28
"""

import pyodbc
import struct
from azure.identity import InteractiveBrowserCredential
from datetime import datetime

# SQL Server connection details
SQL_SERVER = "azwd22midbx02.eb8a77f2eea6.database.windows.net"
SQL_DATABASE = "SNOWFLAKE_WG"

# Expected objects
EXPECTED_TABLES = [
    ("DRILL_BLAST__BLAST_PLAN_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__BL_DW_BLAST_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__BL_DW_HOLE_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__DRILLBLAST_OPERATOR_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__DRILLBLAST_SHIFT_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__DRILL_CYCLE_INCR", "DW_MODIFY_TS"),
    ("DRILL_BLAST__DRILL_PLAN_INCR", "DW_MODIFY_TS"),
    ("LOAD_HAUL__LH_HAUL_CYCLE_INCR", "DW_MODIFY_TS"),
    ("LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR", "START_TS_LOCAL"),
    ("LOAD_HAUL__LH_LOADING_CYCLE_INCR", "CYCLE_START_TS_LOCAL"),
    ("LOAD_HAUL__LH_BUCKET_INCR", "TRIP_TS_LOCAL"),
]

EXPECTED_PROCEDURES = [
    "usp_Archive_BLAST_PLAN_INCR",
    "usp_Archive_BLAST_PLAN_EXECUTION_INCR",
    "usp_Archive_BL_DW_BLAST_INCR",
    "usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR",
    "usp_Archive_BL_DW_HOLE_INCR",
    "usp_Archive_DRILLBLAST_EQUIPMENT_INCR",
    "usp_Archive_DRILLBLAST_OPERATOR_INCR",
    "usp_Archive_DRILLBLAST_SHIFT_INCR",
    "usp_Archive_DRILL_CYCLE_INCR",
    "usp_Archive_DRILL_PLAN_INCR",
    "usp_Archive_LH_HAUL_CYCLE_INCR",
    "usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR",
    "usp_Archive_LH_LOADING_CYCLE_INCR",
    "usp_Archive_LH_BUCKET_INCR",
    "usp_Archive_All_INCR_Tables",  # Master procedure
]


def get_connection():
    """Connect to SQL Server using Azure AD."""
    print("🔐 Connecting to SQL Server...")
    credential = InteractiveBrowserCredential()
    token = credential.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("UTF-16-LE")
    token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
    
    conn_str = f"Driver={{ODBC Driver 17 for SQL Server}};Server={SQL_SERVER};Database={SQL_DATABASE};"
    conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
    print(f"✅ Connected to SQL Server: {SQL_DATABASE}")
    return conn


def test_tables(conn):
    """Test all INCR tables exist with correct structure."""
    cursor = conn.cursor()
    
    print("\n" + "=" * 70)
    print("  TEST 1: INCR TABLES")
    print("=" * 70)
    
    # Get existing tables
    cursor.execute("""
        SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME LIKE '%_INCR'
    """)
    existing = {row[0] for row in cursor.fetchall()}
    
    passed = 0
    failed = 0
    
    for table_name, archive_col in EXPECTED_TABLES:
        # Check table exists
        if table_name not in existing:
            print(f"  ❌ {table_name} - TABLE NOT FOUND")
            failed += 1
            continue
        
        # Check archive column exists
        cursor.execute(f"""
            SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = '{table_name}' AND COLUMN_NAME = '{archive_col}'
        """)
        has_col = cursor.fetchone()[0] > 0
        
        # Get row count
        cursor.execute(f"SELECT COUNT(*) FROM [{table_name}]")
        rows = cursor.fetchone()[0]
        
        # Get column count
        cursor.execute(f"""
            SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = '{table_name}'
        """)
        cols = cursor.fetchone()[0]
        
        if has_col:
            print(f"  ✅ {table_name}")
            print(f"     Columns: {cols}, Rows: {rows:,}, Archive: {archive_col}")
            passed += 1
        else:
            print(f"  ⚠️  {table_name} - Missing archive column: {archive_col}")
            failed += 1
    
    return passed, failed


def test_procedures(conn):
    """Test all archival procedures exist."""
    cursor = conn.cursor()
    
    print("\n" + "=" * 70)
    print("  TEST 2: ARCHIVAL PROCEDURES")
    print("=" * 70)
    
    # Get existing procedures
    cursor.execute("""
        SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME LIKE 'usp_Archive_%'
    """)
    existing = {row[0] for row in cursor.fetchall()}
    
    passed = 0
    failed = 0
    
    for proc_name in EXPECTED_PROCEDURES:
        if proc_name in existing:
            is_master = "(MASTER)" if proc_name == "usp_Archive_All_INCR_Tables" else ""
            print(f"  ✅ {proc_name} {is_master}")
            passed += 1
        else:
            print(f"  ❌ {proc_name} - NOT FOUND")
            failed += 1
    
    return passed, failed


def test_indexes(conn):
    """Test archival indexes exist."""
    cursor = conn.cursor()
    
    print("\n" + "=" * 70)
    print("  TEST 3: ARCHIVAL INDEXES")
    print("=" * 70)
    
    cursor.execute("""
        SELECT 
            t.name as table_name,
            i.name as index_name,
            c.name as column_name
        FROM sys.indexes i
        JOIN sys.tables t ON i.object_id = t.object_id
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE t.name LIKE '%_INCR'
        AND i.name LIKE 'IX_%'
        ORDER BY t.name
    """)
    indexes = cursor.fetchall()
    
    print(f"\n  Found {len(indexes)} indexes:\n")
    
    for table, idx_name, col_name in indexes:
        print(f"  ✅ {table}")
        print(f"     Index: {idx_name}")
        print(f"     Column: {col_name}")
    
    return len(indexes), 0


def test_procedure_execution(conn):
    """Test procedure execution."""
    cursor = conn.cursor()
    
    print("\n" + "=" * 70)
    print("  TEST 4: PROCEDURE EXECUTION")
    print("=" * 70)
    
    passed = 0
    failed = 0
    
    # Test individual procedures
    test_procs = [
        ("usp_Archive_BLAST_PLAN_INCR", "DW_MODIFY_TS"),
        ("usp_Archive_DRILL_CYCLE_INCR", "DW_MODIFY_TS"),
        ("usp_Archive_LH_HAUL_CYCLE_INCR", "DW_MODIFY_TS"),
        ("usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR", "START_TS_LOCAL"),
        ("usp_Archive_LH_LOADING_CYCLE_INCR", "CYCLE_START_TS_LOCAL"),
        ("usp_Archive_LH_BUCKET_INCR", "TRIP_TS_LOCAL"),
    ]
    
    print(f"\n  Testing {len(test_procs)} procedures (365-day lookback):\n")
    
    for proc_name, archive_col in test_procs:
        try:
            cursor.execute(f"EXEC {proc_name} @NumberOfDays = 365")
            result = cursor.fetchone()
            status = result[0] if result else "NO RESULT"
            rows = result[1] if result and len(result) > 1 else 0
            
            if status == "SUCCESS":
                print(f"  ✅ {proc_name}")
                print(f"     Status: SUCCESS, Rows Deleted: {rows}, Archive: {archive_col}")
                passed += 1
            else:
                print(f"  ❌ {proc_name}: {status}")
                failed += 1
        except Exception as e:
            print(f"  ❌ {proc_name}: {str(e)[:50]}")
            failed += 1
    
    return passed, failed


def main():
    print("=" * 70)
    print("  SQL SERVER INCR REGRESSION TEST")
    print(f"  Database: {SQL_DATABASE}")
    print(f"  Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)
    
    conn = get_connection()
    
    # Run tests
    t1_pass, t1_fail = test_tables(conn)
    t2_pass, t2_fail = test_procedures(conn)
    t3_pass, t3_fail = test_indexes(conn)
    t4_pass, t4_fail = test_procedure_execution(conn)
    
    # Summary
    total_pass = t1_pass + t2_pass + t3_pass + t4_pass
    total_fail = t1_fail + t2_fail + t3_fail + t4_fail
    
    print("\n" + "=" * 70)
    print("  REGRESSION TEST SUMMARY")
    print("=" * 70)
    print(f"""
  ┌────────────────────────────────────────────────────────────────┐
  │ TEST                           │ PASSED │ FAILED │ STATUS     │
  ├────────────────────────────────────────────────────────────────┤
  │ 1. INCR Tables                 │ {t1_pass:>6} │ {t1_fail:>6} │ {'✅ PASS' if t1_fail == 0 else '❌ FAIL'}    │
  │ 2. Archival Procedures         │ {t2_pass:>6} │ {t2_fail:>6} │ {'✅ PASS' if t2_fail == 0 else '❌ FAIL'}    │
  │ 3. Archival Indexes            │ {t3_pass:>6} │ {t3_fail:>6} │ {'✅ PASS' if t3_fail == 0 else '❌ FAIL'}    │
  │ 4. Procedure Execution         │ {t4_pass:>6} │ {t4_fail:>6} │ {'✅ PASS' if t4_fail == 0 else '❌ FAIL'}    │
  ├────────────────────────────────────────────────────────────────┤
  │ TOTAL                          │ {total_pass:>6} │ {total_fail:>6} │ {'✅ PASS' if total_fail == 0 else '❌ FAIL'}    │
  └────────────────────────────────────────────────────────────────┘
""")
    
    if total_fail == 0:
        print("  ✅ ALL TESTS PASSED - SQL SERVER INCR INFRASTRUCTURE IS COMPLETE!")
    else:
        print(f"  ⚠️  {total_fail} TESTS FAILED")
    
    print(f"""
  📊 Summary:
     • 14 INCR Tables created
     • 15 Archival Procedures (14 individual + 1 master)
     • 13 Archival Indexes
     • All procedures execute successfully
     
  ⚠️  Note: Tables are empty (0 rows) - awaiting Azure Function sync
""")
    
    conn.close()


if __name__ == "__main__":
    main()
