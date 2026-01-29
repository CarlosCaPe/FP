"""
Test SQL Server Archival Procedures - Complete Cycle
1. Deploy all archival procedures to SQL Server DEV
2. Verify tables exist
3. Execute archival procedures
4. Validate results

Author: Carlos Carrillo
Date: 2026-01-28
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct
import os

# SQL Server connection details
server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'SNOWFLAKE_WG'

print("=" * 80)
print("SQL SERVER ARCHIVAL PROCEDURES - COMPLETE TEST CYCLE")
print("=" * 80)
print(f"Server: {server}")
print(f"Database: {database}")
print()

# Authenticate
print("🔐 Authenticating with Azure AD...")
credential = InteractiveBrowserCredential()
token = credential.get_token('https://database.windows.net/.default')
token_bytes = token.token.encode('utf-16-le')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

conn_str = f'Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()
print("✅ Connected to SQL Server\n")

# Define all archival procedures with their table mappings
archival_procs = [
    # DRILL_BLAST tables (use DW_MODIFY_TS)
    ("usp_Archive_BLAST_PLAN_INCR", "DRILL_BLAST__BLAST_PLAN_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_BLAST_PLAN_EXECUTION_INCR", "DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_BL_DW_BLAST_INCR", "DRILL_BLAST__BL_DW_BLAST_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR", "DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_BL_DW_HOLE_INCR", "DRILL_BLAST__BL_DW_HOLE_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_DRILLBLAST_EQUIPMENT_INCR", "DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_DRILLBLAST_OPERATOR_INCR", "DRILL_BLAST__DRILLBLAST_OPERATOR_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_DRILLBLAST_SHIFT_INCR", "DRILL_BLAST__DRILLBLAST_SHIFT_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_CYCLE_INCR", "DRILL_BLAST__DRILL_CYCLE_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_PLAN_INCR", "DRILL_BLAST__DRILL_PLAN_INCR", "DW_MODIFY_TS"),
    # LOAD_HAUL tables
    ("usp_Archive_LH_HAUL_CYCLE_INCR", "LOAD_HAUL__LH_HAUL_CYCLE_INCR", "DW_MODIFY_TS"),
    ("usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR", "LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR", "START_TS_LOCAL"),
    ("usp_Archive_LH_LOADING_CYCLE_INCR", "LOAD_HAUL__LH_LOADING_CYCLE_INCR", "CYCLE_START_TS_LOCAL"),
    ("usp_Archive_LH_BUCKET_INCR", "LOAD_HAUL__LH_BUCKET_INCR", "TRIP_TS_LOCAL"),
]

# ============================================================
# STEP 1: Check which tables exist
# ============================================================
print("📋 STEP 1: Checking existing INCR tables in SQL Server...")
print("-" * 60)

existing_tables = []
missing_tables = []

for proc_name, table_name, incr_col in archival_procs:
    cursor.execute(f"""
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = '{table_name}'
    """)
    exists = cursor.fetchone()[0] > 0
    
    if exists:
        # Get row count
        cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
        row_count = cursor.fetchone()[0]
        existing_tables.append((table_name, row_count, incr_col))
        print(f"  ✅ {table_name}: {row_count:,} rows")
    else:
        missing_tables.append(table_name)
        print(f"  ❌ {table_name}: NOT FOUND")

print()
print(f"Summary: {len(existing_tables)} tables exist, {len(missing_tables)} missing")
print()

if not existing_tables:
    print("⚠️ No INCR tables found in SQL Server. Cannot test archival procedures.")
    print("   Tables need to be created and populated first via Azure Function sync.")
    cursor.close()
    conn.close()
    exit(0)

# ============================================================
# STEP 2: Deploy archival procedures
# ============================================================
print("📋 STEP 2: Deploying archival procedures...")
print("-" * 60)

base_path = r"C:\Users\ccarrill2\Documents\repos\FP\SQLRefactoring\Tickets\DRILLBLAST_INCR\DDL-Scripts\SQL_SERVER\PROCEDURES"

deployed_procs = []
failed_procs = []

for proc_name, table_name, incr_col in archival_procs:
    # Only deploy if the corresponding table exists
    if table_name not in [t[0] for t in existing_tables]:
        print(f"  ⏭️ {proc_name}: Skipped (table doesn't exist)")
        continue
    
    proc_file = os.path.join(base_path, f"{proc_name}.sql")
    
    if not os.path.exists(proc_file):
        print(f"  ❌ {proc_name}: File not found")
        failed_procs.append((proc_name, "File not found"))
        continue
    
    try:
        with open(proc_file, 'r') as f:
            sql = f.read()
        
        # Remove GO statements for pyodbc execution
        sql = sql.replace('\nGO\n', '\n').replace('\nGO', '').replace('GO\n', '')
        
        cursor.execute(sql)
        conn.commit()
        deployed_procs.append(proc_name)
        print(f"  ✅ {proc_name}: Deployed")
    except Exception as e:
        failed_procs.append((proc_name, str(e)))
        print(f"  ❌ {proc_name}: {str(e)[:60]}")

print()
print(f"Summary: {len(deployed_procs)} deployed, {len(failed_procs)} failed")
print()

# ============================================================
# STEP 3: Execute archival procedures (dry run with 3 days)
# ============================================================
print("📋 STEP 3: Executing archival procedures (3-day retention)...")
print("-" * 60)

results = []

for proc_name in deployed_procs:
    try:
        # Get table name for this procedure
        table_name = None
        for p, t, c in archival_procs:
            if p == proc_name:
                table_name = t
                break
        
        # Get count before
        cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
        count_before = cursor.fetchone()[0]
        
        # Execute the archival procedure
        cursor.execute(f"EXEC [dbo].[{proc_name}] @NumberOfDays = 3")
        result = cursor.fetchone()
        
        if result:
            status = result[0]
            rows_deleted = result[1] if len(result) > 1 else 0
        else:
            status = "UNKNOWN"
            rows_deleted = 0
        
        conn.commit()
        
        # Get count after
        cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
        count_after = cursor.fetchone()[0]
        
        results.append({
            'proc': proc_name,
            'table': table_name,
            'status': status,
            'deleted': rows_deleted,
            'before': count_before,
            'after': count_after
        })
        
        print(f"  ✅ {proc_name}")
        print(f"     Status: {status}, Deleted: {rows_deleted:,}")
        print(f"     Rows: {count_before:,} → {count_after:,}")
        
    except Exception as e:
        results.append({
            'proc': proc_name,
            'table': table_name,
            'status': 'ERROR',
            'deleted': 0,
            'error': str(e)
        })
        print(f"  ❌ {proc_name}: {str(e)[:60]}")

print()

# ============================================================
# STEP 4: Deploy and test master procedure
# ============================================================
print("📋 STEP 4: Deploying master procedure...")
print("-" * 60)

try:
    master_file = os.path.join(base_path, "usp_Archive_All_INCR_Tables.sql")
    with open(master_file, 'r') as f:
        sql = f.read()
    sql = sql.replace('\nGO\n', '\n').replace('\nGO', '').replace('GO\n', '')
    cursor.execute(sql)
    conn.commit()
    print("  ✅ usp_Archive_All_INCR_Tables: Deployed")
except Exception as e:
    print(f"  ❌ usp_Archive_All_INCR_Tables: {str(e)[:60]}")

print()

# ============================================================
# SUMMARY
# ============================================================
print("=" * 80)
print("SUMMARY")
print("=" * 80)

print(f"\n📊 Tables Found: {len(existing_tables)}/{len(archival_procs)}")
for table, count, col in existing_tables:
    print(f"   • {table}: {count:,} rows (using {col})")

print(f"\n📦 Procedures Deployed: {len(deployed_procs)}/{len(archival_procs)}")

successful = [r for r in results if r.get('status') == 'SUCCESS']
print(f"\n✅ Successful Executions: {len(successful)}/{len(results)}")

total_deleted = sum(r.get('deleted', 0) for r in results)
print(f"\n🗑️ Total Rows Archived: {total_deleted:,}")

if failed_procs:
    print(f"\n❌ Failed Deployments:")
    for proc, error in failed_procs:
        print(f"   • {proc}: {error[:50]}")

errors = [r for r in results if r.get('status') == 'ERROR']
if errors:
    print(f"\n❌ Execution Errors:")
    for r in errors:
        print(f"   • {r['proc']}: {r.get('error', 'Unknown')[:50]}")

print("\n" + "=" * 80)
print("TEST COMPLETE")
print("=" * 80)

cursor.close()
conn.close()
