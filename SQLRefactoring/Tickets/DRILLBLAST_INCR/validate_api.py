"""
Validate DRILLBLAST_INCR tables from SQL Azure API perspective
Simulates exactly what Vikas would do when calling the API
"""

import snowflake.connector
import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

# Use same connection pattern as the API
SNOWFLAKE_CONFIG = {
    "account": os.getenv("CONN_LIB_SNOWFLAKE_ACCOUNT", "fcx.west-us-2.azure"),
    "user": os.getenv("CONN_LIB_SNOWFLAKE_USER", "CCARRILL2@fmi.com"),
    "authenticator": os.getenv("CONN_LIB_SNOWFLAKE_AUTHENTICATOR", "externalbrowser"),
    "role": os.getenv("CONN_LIB_SNOWFLAKE_ROLE", "SG-AZW-SFLK-ENG-GENERAL"),
    "warehouse": os.getenv("CONN_LIB_SNOWFLAKE_WAREHOUSE", "WH_BATCH_DE_NONPROD"),
    "database": "DEV_API_REF",
    "schema": "FUSE",
}

# Tables and their corresponding procedures (CORRECT naming convention: _P suffix)
OBJECTS = [
    ("BL_DW_BLAST_INCR", "BL_DW_BLAST_INCR_P"),
    ("BL_DW_BLASTPROPERTYVALUE_INCR", "BL_DW_BLASTPROPERTYVALUE_INCR_P"),
    ("BL_DW_HOLE_INCR", "BL_DW_HOLE_INCR_P"),
    ("BLAST_PLAN_INCR", "BLAST_PLAN_INCR_P"),  # CORRECT: _P suffix, NOT SP_ prefix
    ("BLAST_PLAN_EXECUTION_INCR", "BLAST_PLAN_EXECUTION_INCR_P"),  # CORRECT: _P suffix
    ("DRILL_CYCLE_INCR", "DRILL_CYCLE_INCR_P"),  # CORRECT: _P suffix
    ("DRILL_PLAN_INCR", "DRILL_PLAN_INCR_P"),  # CORRECT: _P suffix
    ("DRILLBLAST_EQUIPMENT_INCR", "DRILLBLAST_EQUIPMENT_INCR_P"),
    ("DRILLBLAST_OPERATOR_INCR", "DRILLBLAST_OPERATOR_INCR_P"),
    ("DRILLBLAST_SHIFT_INCR", "DRILLBLAST_SHIFT_INCR_P"),
    ("LH_HAUL_CYCLE_INCR", "LH_HAUL_CYCLE_INCR_P"),
]

print("=" * 80)
print("SQL AZURE API VALIDATION - DRILLBLAST_INCR")
print("=" * 80)
print(f"Time: {datetime.now().isoformat()}")
print(f"Target: DEV_API_REF.FUSE")
print()

# Connect like the API would
print("📡 Connecting to Snowflake (API style)...")
conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
cursor = conn.cursor()
print("✅ Connected!\n")

results = []

print("=" * 80)
print("🔍 VALIDATING EACH TABLE (API SELECT QUERIES)")
print("=" * 80)

for table, proc in OBJECTS:
    try:
        # Query 1: Check table exists and get count
        cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}")
        count = cursor.fetchone()[0]
        
        # Query 2: Get sample data (like API would return)
        cursor.execute(f"SELECT * FROM DEV_API_REF.FUSE.{table} LIMIT 5")
        sample = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        
        # Query 3: Check latest data timestamp
        cursor.execute(f"SELECT MAX(DW_MODIFY_TS) FROM DEV_API_REF.FUSE.{table}")
        max_ts = cursor.fetchone()[0]
        
        results.append({
            "table": table,
            "procedure": proc,
            "count": count,
            "sample_rows": len(sample),
            "columns": len(columns),
            "latest_data": str(max_ts) if max_ts else "No data",
            "status": "✅"
        })
        print(f"✅ {table}")
        print(f"   Rows: {count:,} | Columns: {len(columns)} | Latest: {max_ts}")
        
    except Exception as e:
        results.append({
            "table": table,
            "procedure": proc,
            "count": 0,
            "sample_rows": 0,
            "columns": 0,
            "latest_data": "ERROR",
            "status": "❌",
            "error": str(e)[:100]
        })
        print(f"❌ {table}: {str(e)[:60]}")

print("\n" + "=" * 80)
print("🔍 VALIDATING EACH PROCEDURE (API CALL)")
print("=" * 80)

proc_results = []
for table, proc in OBJECTS:
    try:
        cursor.execute(f"CALL DEV_API_REF.FUSE.{proc}('1')")  # Just 1 day to be quick
        result = cursor.fetchone()[0]
        proc_results.append({"procedure": proc, "status": "✅", "result": result[:50] if len(str(result)) > 50 else result})
        print(f"✅ {proc}: {result[:60] if len(str(result)) > 60 else result}")
    except Exception as e:
        proc_results.append({"procedure": proc, "status": "❌", "error": str(e)[:100]})
        print(f"❌ {proc}: {str(e)[:60]}")

# Summary
print("\n" + "=" * 80)
print("📋 FINAL VALIDATION SUMMARY")
print("=" * 80)

tables_ok = sum(1 for r in results if r["status"] == "✅")
procs_ok = sum(1 for r in proc_results if r["status"] == "✅")
total_rows = sum(r["count"] for r in results if isinstance(r.get("count"), int))

print(f"""
┌─────────────────────────────────────────────────────────────┐
│                  SQL AZURE API VALIDATION                    │
├─────────────────────────────────────────────────────────────┤
│  Database:     DEV_API_REF                                  │
│  Schema:       FUSE                                         │
│  Tables:       {tables_ok}/11 ✅                                         │
│  Procedures:   {procs_ok}/11 ✅                                         │
│  Total Rows:   {total_rows:,}                                      │
├─────────────────────────────────────────────────────────────┤
│  STATUS:       {"✅ ALL SYSTEMS GO" if tables_ok == 11 and procs_ok == 11 else "⚠️ ISSUES DETECTED"}                                │
└─────────────────────────────────────────────────────────────┘
""")

print("\n📊 DETAILED TABLE REPORT:")
print("-" * 80)
print(f"{'Table':<35} {'Rows':>10} {'Cols':>6} {'Latest Data':>25}")
print("-" * 80)
for r in results:
    print(f"{r['table']:<35} {r['count']:>10,} {r['columns']:>6} {r['latest_data'][:25]:>25}")

print("-" * 80)
print(f"{'TOTAL':<35} {total_rows:>10,}")

cursor.close()
conn.close()

print("\n🎉 Validation complete! Ready for Vikas to test.")
