"""
regression_test_incr_full_cycle.py
==================================
Complete regression test for INCR infrastructure across:
- Snowflake (DEV_API_REF.FUSE)
- SQL Server (SNOWFLAKE_WG)

Validates tables, procedures, and mappings between systems.

Author: Carlos Carrillo
Date: 2026-01-28
"""

import snowflake.connector
import pyodbc
import struct
from azure.identity import InteractiveBrowserCredential
from datetime import datetime
import os

# =============================================================================
# CONNECTION CONFIGURATION
# =============================================================================

# Snowflake - use environment variable for account
SNOWFLAKE_ACCOUNT = os.environ.get("CONN_LIB_SNOWFLAKE_ACCOUNT", "freeportmcmoran-fcxprd")
SNOWFLAKE_USER = os.environ.get("SNOWFLAKE_USER", "CARLOS.CARRILLO2@FREEPORTMCMORAN.COM")
SNOWFLAKE_WAREHOUSE = "DEV_WH"
SNOWFLAKE_DATABASE = "DEV_API_REF"
SNOWFLAKE_SCHEMA = "FUSE"

# SQL Server
SQL_SERVER = "azwd22midbx02.eb8a77f2eea6.database.windows.net"
SQL_DATABASE = "SNOWFLAKE_WG"

# Expected objects mapping
EXPECTED_OBJECTS = [
    # (table_name_snowflake, table_name_sqlserver, procedure_snowflake, procedure_sqlserver, archive_column)
    ("BLAST_PLAN_INCR", "DRILL_BLAST__BLAST_PLAN_INCR", "BLAST_PLAN_INCR_P", "usp_Archive_BLAST_PLAN_INCR", "DW_MODIFY_TS"),
    ("BLAST_PLAN_EXECUTION_INCR", "DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR", "BLAST_PLAN_EXECUTION_INCR_P", "usp_Archive_BLAST_PLAN_EXECUTION_INCR", "DW_MODIFY_TS"),
    ("BL_DW_BLAST_INCR", "DRILL_BLAST__BL_DW_BLAST_INCR", "BL_DW_BLAST_INCR_P", "usp_Archive_BL_DW_BLAST_INCR", "DW_MODIFY_TS"),
    ("BL_DW_BLASTPROPERTYVALUE_INCR", "DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR", "BL_DW_BLASTPROPERTYVALUE_INCR_P", "usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR", "DW_MODIFY_TS"),
    ("BL_DW_HOLE_INCR", "DRILL_BLAST__BL_DW_HOLE_INCR", "BL_DW_HOLE_INCR_P", "usp_Archive_BL_DW_HOLE_INCR", "DW_MODIFY_TS"),
    ("DRILLBLAST_EQUIPMENT_INCR", "DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR", "DRILLBLAST_EQUIPMENT_INCR_P", "usp_Archive_DRILLBLAST_EQUIPMENT_INCR", "DW_MODIFY_TS"),
    ("DRILLBLAST_OPERATOR_INCR", "DRILL_BLAST__DRILLBLAST_OPERATOR_INCR", "DRILLBLAST_OPERATOR_INCR_P", "usp_Archive_DRILLBLAST_OPERATOR_INCR", "DW_MODIFY_TS"),
    ("DRILLBLAST_SHIFT_INCR", "DRILL_BLAST__DRILLBLAST_SHIFT_INCR", "DRILLBLAST_SHIFT_INCR_P", "usp_Archive_DRILLBLAST_SHIFT_INCR", "DW_MODIFY_TS"),
    ("DRILL_CYCLE_INCR", "DRILL_BLAST__DRILL_CYCLE_INCR", "DRILL_CYCLE_INCR_P", "usp_Archive_DRILL_CYCLE_INCR", "DW_MODIFY_TS"),
    ("DRILL_PLAN_INCR", "DRILL_BLAST__DRILL_PLAN_INCR", "DRILL_PLAN_INCR_P", "usp_Archive_DRILL_PLAN_INCR", "DW_MODIFY_TS"),
    ("LH_HAUL_CYCLE_INCR", "LOAD_HAUL__LH_HAUL_CYCLE_INCR", "LH_HAUL_CYCLE_INCR_P", "usp_Archive_LH_HAUL_CYCLE_INCR", "DW_MODIFY_TS"),
    ("LH_EQUIPMENT_STATUS_EVENT_INCR", "LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR", "LH_EQUIPMENT_STATUS_EVENT_INCR_P", "usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR", "START_TS_LOCAL"),
    ("LH_LOADING_CYCLE_INCR", "LOAD_HAUL__LH_LOADING_CYCLE_INCR", "LH_LOADING_CYCLE_INCR_P", "usp_Archive_LH_LOADING_CYCLE_INCR", "CYCLE_START_TS_LOCAL"),
    ("LH_BUCKET_INCR", "LOAD_HAUL__LH_BUCKET_INCR", "LH_BUCKET_INCR_P", "usp_Archive_LH_BUCKET_INCR", "TRIP_TS_LOCAL"),
]


def get_snowflake_connection():
    """Connect to Snowflake using browser SSO."""
    print("🔐 Connecting to Snowflake...")
    conn = snowflake.connector.connect(
        account=SNOWFLAKE_ACCOUNT,
        user=SNOWFLAKE_USER,
        authenticator="externalbrowser",
        warehouse=SNOWFLAKE_WAREHOUSE,
        database=SNOWFLAKE_DATABASE,
        schema=SNOWFLAKE_SCHEMA
    )
    print(f"✅ Connected to Snowflake: {SNOWFLAKE_DATABASE}.{SNOWFLAKE_SCHEMA}")
    return conn


def get_sqlserver_connection():
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


def test_snowflake_tables(sf_conn):
    """Test Snowflake INCR tables."""
    print("\n" + "=" * 70)
    print("  SNOWFLAKE TABLES TEST")
    print("=" * 70)
    
    cursor = sf_conn.cursor()
    results = []
    
    cursor.execute("""
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'FUSE' 
        AND TABLE_NAME LIKE '%_INCR'
        ORDER BY TABLE_NAME
    """)
    existing_tables = {row[0] for row in cursor.fetchall()}
    
    print(f"\n  Found {len(existing_tables)} INCR tables in Snowflake:\n")
    
    for sf_table, _, _, _, archive_col in EXPECTED_OBJECTS:
        if sf_table in existing_tables:
            cursor.execute(f"SELECT COUNT(*) FROM {SNOWFLAKE_DATABASE}.{SNOWFLAKE_SCHEMA}.{sf_table}")
            row_count = cursor.fetchone()[0]
            status = "✅"
            results.append((sf_table, True, row_count))
        else:
            status = "❌"
            row_count = 0
            results.append((sf_table, False, 0))
        
        print(f"    {status} {sf_table}: {row_count:,} rows")
    
    passed = sum(1 for _, exists, _ in results if exists)
    return passed, len(EXPECTED_OBJECTS), results


def test_snowflake_procedures(sf_conn):
    """Test Snowflake INCR procedures."""
    print("\n" + "=" * 70)
    print("  SNOWFLAKE PROCEDURES TEST")
    print("=" * 70)
    
    cursor = sf_conn.cursor()
    results = []
    
    cursor.execute("""
        SELECT PROCEDURE_NAME 
        FROM INFORMATION_SCHEMA.PROCEDURES 
        WHERE PROCEDURE_SCHEMA = 'FUSE' 
        AND PROCEDURE_NAME LIKE '%_INCR_P'
        ORDER BY PROCEDURE_NAME
    """)
    existing_procs = {row[0] for row in cursor.fetchall()}
    
    print(f"\n  Found {len(existing_procs)} INCR procedures in Snowflake:\n")
    
    for _, _, sf_proc, _, _ in EXPECTED_OBJECTS:
        if sf_proc in existing_procs:
            status = "✅"
            results.append((sf_proc, True))
        else:
            status = "❌"
            results.append((sf_proc, False))
        
        print(f"    {status} {sf_proc}")
    
    passed = sum(1 for _, exists in results if exists)
    return passed, len(EXPECTED_OBJECTS), results


def test_sqlserver_tables(sql_conn):
    """Test SQL Server INCR tables."""
    print("\n" + "=" * 70)
    print("  SQL SERVER TABLES TEST")
    print("=" * 70)
    
    cursor = sql_conn.cursor()
    results = []
    
    cursor.execute("""
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_TYPE = 'BASE TABLE' 
        AND TABLE_NAME LIKE '%_INCR'
        ORDER BY TABLE_NAME
    """)
    existing_tables = {row[0] for row in cursor.fetchall()}
    
    print(f"\n  Found {len(existing_tables)} INCR tables in SQL Server:\n")
    
    for _, sql_table, _, _, archive_col in EXPECTED_OBJECTS:
        if sql_table in existing_tables:
            cursor.execute(f"SELECT COUNT(*) FROM [{sql_table}]")
            row_count = cursor.fetchone()[0]
            status = "✅"
            results.append((sql_table, True, row_count))
        else:
            status = "❌"
            row_count = 0
            results.append((sql_table, False, 0))
        
        print(f"    {status} {sql_table}: {row_count:,} rows")
    
    passed = sum(1 for _, exists, _ in results if exists)
    return passed, len(EXPECTED_OBJECTS), results


def test_sqlserver_procedures(sql_conn):
    """Test SQL Server archival procedures."""
    print("\n" + "=" * 70)
    print("  SQL SERVER PROCEDURES TEST")
    print("=" * 70)
    
    cursor = sql_conn.cursor()
    results = []
    
    cursor.execute("""
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'PROCEDURE' 
        AND ROUTINE_NAME LIKE 'usp_Archive_%INCR%'
        ORDER BY ROUTINE_NAME
    """)
    existing_procs = {row[0] for row in cursor.fetchall()}
    
    # Add master procedure check
    cursor.execute("""
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_NAME = 'usp_Archive_All_INCR_Tables'
    """)
    has_master = cursor.fetchone() is not None
    
    print(f"\n  Found {len(existing_procs)} archival procedures in SQL Server:\n")
    
    for _, _, _, sql_proc, _ in EXPECTED_OBJECTS:
        if sql_proc in existing_procs:
            status = "✅"
            results.append((sql_proc, True))
        else:
            status = "❌"
            results.append((sql_proc, False))
        
        print(f"    {status} {sql_proc}")
    
    # Master procedure
    if has_master:
        print(f"    ✅ usp_Archive_All_INCR_Tables (MASTER)")
        results.append(("usp_Archive_All_INCR_Tables", True))
    else:
        print(f"    ❌ usp_Archive_All_INCR_Tables (MASTER)")
        results.append(("usp_Archive_All_INCR_Tables", False))
    
    passed = sum(1 for _, exists in results if exists)
    return passed, len(EXPECTED_OBJECTS) + 1, results  # +1 for master


def test_sqlserver_indexes(sql_conn):
    """Test SQL Server archival indexes."""
    print("\n" + "=" * 70)
    print("  SQL SERVER INDEXES TEST")
    print("=" * 70)
    
    cursor = sql_conn.cursor()
    
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
    
    print(f"\n  Found {len(indexes)} archival indexes:\n")
    
    results = []
    for table, idx_name, col_name in indexes:
        print(f"    ✅ {table}")
        print(f"       Index: {idx_name}")
        print(f"       Column: {col_name}")
        results.append((table, idx_name, col_name))
    
    return len(indexes), results


def test_procedure_execution(sql_conn):
    """Test SQL Server procedure execution."""
    print("\n" + "=" * 70)
    print("  SQL SERVER PROCEDURE EXECUTION TEST")
    print("=" * 70)
    
    cursor = sql_conn.cursor()
    results = []
    
    print(f"\n  Testing procedure execution with @NumberOfDays = 365:\n")
    
    for _, sql_table, _, sql_proc, archive_col in EXPECTED_OBJECTS:
        try:
            cursor.execute(f"EXEC {sql_proc} @NumberOfDays = 365")
            result = cursor.fetchone()
            status = result[0] if result else "NO RESULT"
            rows = result[1] if result and len(result) > 1 else 0
            
            if status == "SUCCESS":
                print(f"    ✅ {sql_proc}")
                print(f"       Archive Column: {archive_col}, Rows Deleted: {rows}")
                results.append((sql_proc, True, rows))
            else:
                print(f"    ❌ {sql_proc}: {status}")
                results.append((sql_proc, False, 0))
        except Exception as e:
            print(f"    ❌ {sql_proc}: {str(e)[:50]}")
            results.append((sql_proc, False, 0))
    
    passed = sum(1 for _, success, _ in results if success)
    return passed, len(EXPECTED_OBJECTS), results


def test_column_mapping(sf_conn, sql_conn):
    """Test that archive columns exist in both systems."""
    print("\n" + "=" * 70)
    print("  ARCHIVE COLUMN MAPPING TEST")
    print("=" * 70)
    
    sf_cursor = sf_conn.cursor()
    sql_cursor = sql_conn.cursor()
    
    print(f"\n  Verifying archive columns exist in both systems:\n")
    
    results = []
    for sf_table, sql_table, _, _, archive_col in EXPECTED_OBJECTS:
        # Check Snowflake
        sf_cursor.execute(f"""
            SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = 'FUSE' 
            AND TABLE_NAME = '{sf_table}' 
            AND COLUMN_NAME = '{archive_col}'
        """)
        sf_has_col = sf_cursor.fetchone()[0] > 0
        
        # Check SQL Server
        sql_cursor.execute(f"""
            SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = '{sql_table}' 
            AND COLUMN_NAME = '{archive_col}'
        """)
        sql_has_col = sql_cursor.fetchone()[0] > 0
        
        if sf_has_col and sql_has_col:
            print(f"    ✅ {archive_col}")
            print(f"       Snowflake: {sf_table} ✓")
            print(f"       SQL Server: {sql_table} ✓")
            results.append((archive_col, True))
        else:
            print(f"    ❌ {archive_col}")
            print(f"       Snowflake: {sf_table} {'✓' if sf_has_col else '✗'}")
            print(f"       SQL Server: {sql_table} {'✓' if sql_has_col else '✗'}")
            results.append((archive_col, False))
    
    passed = sum(1 for _, success in results if success)
    return passed, len(EXPECTED_OBJECTS), results


def print_diagram():
    """Print ASCII diagram of the INCR architecture."""
    diagram = """
╔══════════════════════════════════════════════════════════════════════════════════════════════╗
║                           INCR INCREMENTAL DATA ARCHITECTURE                                  ║
║                                  Complete Data Flow Diagram                                   ║
╚══════════════════════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    SOURCE LAYER (PROD)                                       │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐                        │
│  │   PROD_WG.DRILL_BLAST       │     │   PROD_WG.LOAD_HAUL         │                        │
│  │  ┌─────────────────────┐    │     │  ┌─────────────────────┐    │                        │
│  │  │ DRILL_CYCLE         │    │     │  │ LH_HAUL_CYCLE       │    │                        │
│  │  │ DRILL_PLAN          │    │     │  │ LH_LOADING_CYCLE    │    │                        │
│  │  │ BLAST_PLAN          │    │     │  │ LH_BUCKET           │    │                        │
│  │  │ BLAST_PLAN_EXECUTION│    │     │  │ LH_EQUIPMENT_STATUS │    │                        │
│  │  │ BL_DW_BLAST         │    │     │  └─────────────────────┘    │                        │
│  │  │ BL_DW_HOLE          │    │     │            4 tables         │                        │
│  │  │ BL_DW_BLASTPROPVAL  │    │     └─────────────────────────────┘                        │
│  │  │ DRILLBLAST_EQUIPMENT│    │                                                            │
│  │  │ DRILLBLAST_OPERATOR │    │                                                            │
│  │  │ DRILLBLAST_SHIFT    │    │                                                            │
│  │  └─────────────────────┘    │                                                            │
│  │          10 tables          │                                                            │
│  └─────────────────────────────┘                                                            │
└────────────────────────────────────────────┬────────────────────────────────────────────────┘
                                             │
                                             │ MERGE (3-day window)
                                             │ DW_MODIFY_TS > DATEADD(-3, CURRENT_DATE)
                                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              SNOWFLAKE API LAYER (DEV_API_REF.FUSE)                          │
│                                                                                              │
│  ┌────────────────────────────────────────┐    ┌────────────────────────────────────────┐   │
│  │         14 INCR TABLES                 │    │        14 INCR PROCEDURES              │   │
│  │  ┌──────────────────────────────────┐  │    │  ┌──────────────────────────────────┐  │   │
│  │  │ DRILL_BLAST Tables (10):         │  │    │  │ Pattern: {TABLE}_INCR_P          │  │   │
│  │  │  • BLAST_PLAN_INCR               │  │    │  │                                  │  │   │
│  │  │  • BLAST_PLAN_EXECUTION_INCR     │  │    │  │ Logic:                           │  │   │
│  │  │  • BL_DW_BLAST_INCR              │  │    │  │  1. PURGE old data (DELETE)      │  │   │
│  │  │  • BL_DW_BLASTPROPERTYVALUE_INCR │  │    │  │  2. MERGE new data (UPSERT)      │  │   │
│  │  │  • BL_DW_HOLE_INCR               │  │    │  │  3. SOFT DELETE (flag 'Y')       │  │   │
│  │  │  • DRILLBLAST_EQUIPMENT_INCR     │  │    │  │                                  │  │   │
│  │  │  • DRILLBLAST_OPERATOR_INCR      │  │    │  │ Archive Columns:                 │  │   │
│  │  │  • DRILLBLAST_SHIFT_INCR         │  │    │  │  • Most: DW_MODIFY_TS            │  │   │
│  │  │  • DRILL_CYCLE_INCR              │  │    │  │  • LH_EQUIP: START_TS_LOCAL      │  │   │
│  │  │  • DRILL_PLAN_INCR               │  │    │  │  • LH_LOADING: CYCLE_START_TS    │  │   │
│  │  │                                  │  │    │  │  • LH_BUCKET: TRIP_TS_LOCAL      │  │   │
│  │  │ LOAD_HAUL Tables (4):            │  │    │  └──────────────────────────────────┘  │   │
│  │  │  • LH_HAUL_CYCLE_INCR            │  │    │                                        │   │
│  │  │  • LH_EQUIPMENT_STATUS_EVENT_INCR│  │    │                                        │   │
│  │  │  • LH_LOADING_CYCLE_INCR         │  │    │                                        │   │
│  │  │  • LH_BUCKET_INCR                │  │    │                                        │   │
│  │  └──────────────────────────────────┘  │    │                                        │   │
│  └────────────────────────────────────────┘    └────────────────────────────────────────┘   │
└────────────────────────────────────────────┬────────────────────────────────────────────────┘
                                             │
                                             │ AZURE FUNCTION SYNC
                                             │ (DI-SNFLK-AzureFunction-MSSQL)
                                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              SQL SERVER LAYER (SNOWFLAKE_WG)                                 │
│                                                                                              │
│  ┌────────────────────────────────────────┐    ┌────────────────────────────────────────┐   │
│  │         14 INCR TABLES                 │    │     15 ARCHIVAL PROCEDURES             │   │
│  │  ┌──────────────────────────────────┐  │    │  ┌──────────────────────────────────┐  │   │
│  │  │ DRILL_BLAST__ prefix (10):       │  │    │  │ Pattern: usp_Archive_{TABLE}_INCR│  │   │
│  │  │  • DRILL_BLAST__BLAST_PLAN_INCR  │  │    │  │                                  │  │   │
│  │  │  • DRILL_BLAST__BLAST_PLAN_EXEC..│  │    │  │ 14 Individual Procedures +       │  │   │
│  │  │  • DRILL_BLAST__BL_DW_BLAST_INCR │  │    │  │ 1 Master Procedure               │  │   │
│  │  │  • DRILL_BLAST__BL_DW_BLASTPROP..│  │    │  │                                  │  │   │
│  │  │  • DRILL_BLAST__BL_DW_HOLE_INCR  │  │    │  │ Logic:                           │  │   │
│  │  │  • DRILL_BLAST__DRILLBLAST_EQUIP.│  │    │  │  DELETE WHERE archive_col <      │  │   │
│  │  │  • DRILL_BLAST__DRILLBLAST_OPER..│  │    │  │    DATEADD(-N, GETDATE())        │  │   │
│  │  │  • DRILL_BLAST__DRILLBLAST_SHIFT.│  │    │  │                                  │  │   │
│  │  │  • DRILL_BLAST__DRILL_CYCLE_INCR │  │    │  │ usp_Archive_All_INCR_Tables:     │  │   │
│  │  │  • DRILL_BLAST__DRILL_PLAN_INCR  │  │    │  │  Calls all 14 procedures         │  │   │
│  │  │                                  │  │    │  │  Returns summary results         │  │   │
│  │  │ LOAD_HAUL__ prefix (4):          │  │    │  └──────────────────────────────────┘  │   │
│  │  │  • LOAD_HAUL__LH_HAUL_CYCLE_INCR │  │    │                                        │   │
│  │  │  • LOAD_HAUL__LH_EQUIPMENT_STAT..│  │    │  ┌──────────────────────────────────┐  │   │
│  │  │  • LOAD_HAUL__LH_LOADING_CYCLE.. │  │    │  │      13 ARCHIVAL INDEXES         │  │   │
│  │  │  • LOAD_HAUL__LH_BUCKET_INCR     │  │    │  │  IX_{TABLE}_INCR_{ARCHIVE_COL}   │  │   │
│  │  └──────────────────────────────────┘  │    │  │  Optimized for DELETE queries    │  │   │
│  └────────────────────────────────────────┘    │  └──────────────────────────────────┘  │   │
│                                                └────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

╔══════════════════════════════════════════════════════════════════════════════════════════════╗
║                                    OBJECT SUMMARY                                             ║
╠══════════════════════════════════════════════════════════════════════════════════════════════╣
║  LAYER              │ TABLES │ PROCEDURES │ INDEXES │ TOTAL OBJECTS                          ║
╠══════════════════════════════════════════════════════════════════════════════════════════════╣
║  PROD (Source)      │   14   │     -      │    -    │     14                                 ║
║  Snowflake API      │   14   │    14      │    -    │     28                                 ║
║  SQL Server         │   14   │    15*     │   13    │     42                                 ║
╠══════════════════════════════════════════════════════════════════════════════════════════════╣
║  TOTAL              │   42   │    29      │   13    │     84                                 ║
╚══════════════════════════════════════════════════════════════════════════════════════════════╝
                      * 15 = 14 individual + 1 master procedure

╔══════════════════════════════════════════════════════════════════════════════════════════════╗
║                               SPECIAL ARCHIVE COLUMNS                                         ║
╠══════════════════════════════════════════════════════════════════════════════════════════════╣
║  TABLE                           │ ARCHIVE COLUMN          │ REASON                          ║
╠══════════════════════════════════════════════════════════════════════════════════════════════╣
║  Most tables (11)                │ DW_MODIFY_TS            │ Standard warehouse timestamp    ║
║  LH_EQUIPMENT_STATUS_EVENT_INCR  │ START_TS_LOCAL          │ Business event start time       ║
║  LH_LOADING_CYCLE_INCR           │ CYCLE_START_TS_LOCAL    │ Loading cycle start time        ║
║  LH_BUCKET_INCR                  │ TRIP_TS_LOCAL           │ Bucket trip timestamp           ║
╚══════════════════════════════════════════════════════════════════════════════════════════════╝
"""
    print(diagram)


def main():
    print("=" * 90)
    print("  INCR INFRASTRUCTURE - COMPLETE REGRESSION TEST")
    print(f"  Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 90)
    
    # Print architecture diagram first
    print_diagram()
    
    # Connect to both systems
    sf_conn = get_snowflake_connection()
    sql_conn = get_sqlserver_connection()
    
    # Run all tests
    results = {}
    
    # Snowflake tests
    sf_tables_passed, sf_tables_total, _ = test_snowflake_tables(sf_conn)
    sf_procs_passed, sf_procs_total, _ = test_snowflake_procedures(sf_conn)
    
    # SQL Server tests
    sql_tables_passed, sql_tables_total, _ = test_sqlserver_tables(sql_conn)
    sql_procs_passed, sql_procs_total, _ = test_sqlserver_procedures(sql_conn)
    sql_indexes_count, _ = test_sqlserver_indexes(sql_conn)
    
    # Cross-system tests
    mapping_passed, mapping_total, _ = test_column_mapping(sf_conn, sql_conn)
    
    # Execution tests
    exec_passed, exec_total, _ = test_procedure_execution(sql_conn)
    
    # Final Summary
    print("\n" + "=" * 90)
    print("  REGRESSION TEST SUMMARY")
    print("=" * 90)
    
    all_passed = True
    
    print(f"""
  ┌─────────────────────────────────────────────────────────────────┐
  │ TEST                              │ PASSED │ TOTAL │ STATUS    │
  ├─────────────────────────────────────────────────────────────────┤
  │ Snowflake Tables                  │ {sf_tables_passed:>6} │ {sf_tables_total:>5} │ {'✅ PASS' if sf_tables_passed == sf_tables_total else '❌ FAIL'}    │
  │ Snowflake Procedures              │ {sf_procs_passed:>6} │ {sf_procs_total:>5} │ {'✅ PASS' if sf_procs_passed == sf_procs_total else '❌ FAIL'}    │
  │ SQL Server Tables                 │ {sql_tables_passed:>6} │ {sql_tables_total:>5} │ {'✅ PASS' if sql_tables_passed == sql_tables_total else '❌ FAIL'}    │
  │ SQL Server Procedures             │ {sql_procs_passed:>6} │ {sql_procs_total:>5} │ {'✅ PASS' if sql_procs_passed == sql_procs_total else '❌ FAIL'}    │
  │ SQL Server Indexes                │ {sql_indexes_count:>6} │ {14:>5} │ {'✅ PASS' if sql_indexes_count >= 13 else '⚠️ WARN'}    │
  │ Archive Column Mapping            │ {mapping_passed:>6} │ {mapping_total:>5} │ {'✅ PASS' if mapping_passed == mapping_total else '❌ FAIL'}    │
  │ Procedure Execution               │ {exec_passed:>6} │ {exec_total:>5} │ {'✅ PASS' if exec_passed == exec_total else '❌ FAIL'}    │
  └─────────────────────────────────────────────────────────────────┘
""")
    
    total_passed = (sf_tables_passed + sf_procs_passed + sql_tables_passed + 
                   sql_procs_passed + mapping_passed + exec_passed)
    total_tests = (sf_tables_total + sf_procs_total + sql_tables_total + 
                  sql_procs_total + mapping_total + exec_total)
    
    if total_passed == total_tests:
        print("  ✅ ALL TESTS PASSED - INCR INFRASTRUCTURE IS COMPLETE!")
    else:
        print(f"  ⚠️  {total_tests - total_passed} TESTS FAILED")
    
    print(f"\n  Total: {total_passed}/{total_tests} tests passed")
    
    sf_conn.close()
    sql_conn.close()


if __name__ == "__main__":
    main()
