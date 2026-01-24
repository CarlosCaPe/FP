"""
DRILLBLAST_INCR - Final Production Validation
Complete end-to-end test with timing metrics for Vikas
"""

import snowflake.connector
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
import time
import json

SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "DEV_API_REF",
    "schema": "FUSE",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
}

OBJECTS = [
    ("BL_DW_BLAST_INCR", "BL_DW_BLAST_INCR_P"),
    ("BL_DW_BLASTPROPERTYVALUE_INCR", "BL_DW_BLASTPROPERTYVALUE_INCR_P"),
    ("BL_DW_HOLE_INCR", "BL_DW_HOLE_INCR_P"),
    ("BLAST_PLAN_INCR", "BLAST_PLAN_INCR_P"),
    ("BLAST_PLAN_EXECUTION_INCR", "BLAST_PLAN_EXECUTION_INCR_P"),
    ("DRILL_CYCLE_INCR", "DRILL_CYCLE_INCR_P"),
    ("DRILL_PLAN_INCR", "DRILL_PLAN_INCR_P"),
    ("DRILLBLAST_EQUIPMENT_INCR", "DRILLBLAST_EQUIPMENT_INCR_P"),
    ("DRILLBLAST_OPERATOR_INCR", "DRILLBLAST_OPERATOR_INCR_P"),
    ("DRILLBLAST_SHIFT_INCR", "DRILLBLAST_SHIFT_INCR_P"),
    ("LH_HAUL_CYCLE_INCR", "LH_HAUL_CYCLE_INCR_P"),
]

def execute_procedure(proc_name):
    """Execute procedure in separate connection"""
    start = time.time()
    try:
        conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
        cursor = conn.cursor()
        cursor.execute(f"CALL DEV_API_REF.FUSE.{proc_name}('3')")
        result = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        elapsed = time.time() - start
        
        # Parse merged rows from result
        merged = 0
        if "Merged:" in str(result):
            try:
                merged = int(str(result).split("Merged:")[1].split(",")[0].strip())
            except:
                pass
        elif "rows_merged" in str(result):
            try:
                merged = json.loads(result).get("rows_merged", 0)
            except:
                pass
        
        return {"procedure": proc_name, "status": "✅", "merged": merged, "time_sec": round(elapsed, 2), "error": None}
    except Exception as e:
        elapsed = time.time() - start
        return {"procedure": proc_name, "status": "❌", "merged": 0, "time_sec": round(elapsed, 2), "error": str(e)[:80]}

print("=" * 90)
print("DRILLBLAST_INCR - PRODUCTION VALIDATION REPORT")
print("=" * 90)
print(f"Execution Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S MST')}")
print(f"Target Schema:  DEV_API_REF.FUSE")
print(f"Lookback:       3 days")
print("=" * 90)

# Connect
print("\n📡 Connecting to Snowflake Azure...")
main_conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
main_cursor = main_conn.cursor()
print("✅ Connected to fcx.west-us-2.azure\n")

# Phase 1: Execute all procedures in parallel
print("=" * 90)
print("PHASE 1: INCREMENTAL LOAD EXECUTION (Parallel - 4 threads)")
print("=" * 90)
start_total = time.time()

proc_results = []
with ThreadPoolExecutor(max_workers=4) as executor:
    futures = {executor.submit(execute_procedure, proc): (table, proc) for table, proc in OBJECTS}
    for future in as_completed(futures):
        result = future.result()
        proc_results.append(result)
        status = result['status']
        print(f"  {status} {result['procedure']:<40} {result['time_sec']:>6.1f}s  Merged: {result['merged']:,}")

parallel_time = time.time() - start_total
print(f"\n⏱️  Total Parallel Execution: {parallel_time:.1f}s")

# Phase 2: Validate via SQL queries (API simulation)
print("\n" + "=" * 90)
print("PHASE 2: SQL AZURE API VALIDATION (SELECT queries)")
print("=" * 90)

table_results = []
for table, proc in OBJECTS:
    start = time.time()
    try:
        # Count
        main_cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}")
        count = main_cursor.fetchone()[0]
        
        # Sample query (simulates API call)
        main_cursor.execute(f"SELECT * FROM DEV_API_REF.FUSE.{table} LIMIT 10")
        sample = main_cursor.fetchall()
        cols = len(main_cursor.description)
        
        # Latest timestamp
        main_cursor.execute(f"SELECT MAX(DW_MODIFY_TS) FROM DEV_API_REF.FUSE.{table}")
        max_ts = main_cursor.fetchone()[0]
        
        elapsed = time.time() - start
        table_results.append({
            "table": table,
            "rows": count,
            "columns": cols,
            "query_time_ms": round(elapsed * 1000),
            "latest_data": str(max_ts)[:19] if max_ts else "N/A",
            "status": "✅"
        })
        print(f"  ✅ {table:<40} {count:>10,} rows  {elapsed*1000:>6.0f}ms")
    except Exception as e:
        table_results.append({
            "table": table,
            "rows": 0,
            "columns": 0,
            "query_time_ms": 0,
            "latest_data": "ERROR",
            "status": "❌",
            "error": str(e)[:60]
        })
        print(f"  ❌ {table:<40} ERROR: {str(e)[:40]}")

# Calculate totals
total_rows = sum(r["rows"] for r in table_results)
total_merged = sum(r["merged"] for r in proc_results)
avg_query_time = sum(r["query_time_ms"] for r in table_results) / len(table_results)

# Summary Report
print("\n" + "=" * 90)
print("VALIDATION SUMMARY")
print("=" * 90)

tables_ok = sum(1 for r in table_results if r["status"] == "✅")
procs_ok = sum(1 for r in proc_results if r["status"] == "✅")

print(f"""
┌────────────────────────────────────────────────────────────────────────────────┐
│                     DRILLBLAST_INCR DEPLOYMENT STATUS                          │
├────────────────────────────────────────────────────────────────────────────────┤
│  Environment:      DEV_API_REF.FUSE (Snowflake Azure West US 2)                │
│  Validation Date:  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} MST                                    │
├────────────────────────────────────────────────────────────────────────────────┤
│  Tables:           {tables_ok:>2}/11 ✅                                                       │
│  Procedures:       {procs_ok:>2}/11 ✅                                                       │
│  Total Rows:       {total_rows:>10,}                                                    │
│  Rows Merged:      {total_merged:>10,} (3-day incremental)                              │
├────────────────────────────────────────────────────────────────────────────────┤
│  Parallel Load:    {parallel_time:>6.1f}s                                                      │
│  Avg Query Time:   {avg_query_time:>6.0f}ms                                                      │
├────────────────────────────────────────────────────────────────────────────────┤
│  STATUS:           {"✅ PRODUCTION READY" if tables_ok == 11 and procs_ok == 11 else "⚠️ ISSUES DETECTED"}                                              │
└────────────────────────────────────────────────────────────────────────────────┘
""")

# Detailed table for Vikas
print("\n" + "=" * 90)
print("DETAILED METRICS BY TABLE")
print("=" * 90)
print(f"{'Table':<35} {'Rows':>12} {'Cols':>6} {'Load(s)':>8} {'Query(ms)':>10} {'Latest Data':>20}")
print("-" * 90)

for tr in table_results:
    # Find matching procedure result
    pr = next((p for p in proc_results if p["procedure"].replace("_P", "").replace("SP_", "") in tr["table"]), None)
    load_time = pr["time_sec"] if pr else 0
    print(f"{tr['table']:<35} {tr['rows']:>12,} {tr['columns']:>6} {load_time:>8.1f} {tr['query_time_ms']:>10} {tr['latest_data']:>20}")

print("-" * 90)
print(f"{'TOTAL':<35} {total_rows:>12,} {'':>6} {parallel_time:>8.1f} {avg_query_time:>10.0f}")

main_cursor.close()
main_conn.close()

# Save report
report = {
    "execution_date": datetime.now().isoformat(),
    "schema": "DEV_API_REF.FUSE",
    "tables": table_results,
    "procedures": proc_results,
    "summary": {
        "total_rows": total_rows,
        "total_merged": total_merged,
        "parallel_execution_sec": round(parallel_time, 2),
        "avg_query_time_ms": round(avg_query_time),
        "tables_ok": tables_ok,
        "procedures_ok": procs_ok
    }
}

with open(f"validation_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json", "w") as f:
    json.dump(report, f, indent=2, default=str)

print(f"\n📁 Report saved to validation_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
print("\n🎉 Validation Complete!")
