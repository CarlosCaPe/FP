"""
DRILLBLAST_INCR Stress Test
===========================
Tests each source table with 30 different day lookback windows (1-30 days).
Uses one thread per table for parallel execution.

This stress test:
1. Verifies data exists in source tables
2. Tests incremental query performance with different date ranges
3. Measures row counts and query duration for each lookback window

Usage:
    python stress_test_incr.py           # Full test
    python stress_test_incr.py --dry-run # Preview only
    python stress_test_incr.py --quick   # Quick test (days 1,7,14,30)
"""

import os
import json
import threading
import time
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import snowflake.connector
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Snowflake connection parameters - from .env
SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "PROD_WG",
    "schema": "LOAD_HAUL",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
    "client_session_keep_alive": True,
    "network_timeout": 3600
}

# List of source tables to test (verify data exists and test query performance)
SOURCE_TABLES = [
    {"name": "LH_HAUL_CYCLE", "source": "PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE_V", "ts_col": "CYCLE_END_TS_LOCAL"},
    {"name": "BL_DW_BLAST", "source": "PROD_WG.DRILLBLAST.BL_DW_BLAST", "ts_col": "DW_MODIFY_TS"},
    {"name": "BL_DW_BLASTPROPERTYVALUE", "source": "PROD_WG.DRILLBLAST.BL_DW_BLASTPROPERTYVALUE", "ts_col": "DW_MODIFY_TS"},
    {"name": "BL_DW_HOLE", "source": "PROD_WG.DRILLBLAST.BL_DW_HOLE", "ts_col": "DW_MODIFY_TS"},
    {"name": "BLAST_PLAN", "source": "PROD_WG.DRILL_BLAST.BLAST_PLAN", "ts_col": "DW_MODIFY_TS"},
    {"name": "BLAST_PLAN_EXECUTION", "source": "PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION", "ts_col": "DW_MODIFY_TS"},
    {"name": "DRILL_CYCLE", "source": "PROD_WG.DRILL_BLAST.DRILL_CYCLE", "ts_col": "DW_MODIFY_TS"},
    {"name": "DRILL_PLAN", "source": "PROD_WG.DRILL_BLAST.DRILL_PLAN", "ts_col": "DW_MODIFY_TS"},
    {"name": "DRILLBLAST_EQUIPMENT", "source": "PROD_WG.DRILL_BLAST.DRILLBLAST_EQUIPMENT", "ts_col": "DW_MODIFY_TS"},
    {"name": "DRILLBLAST_OPERATOR", "source": "PROD_WG.DRILL_BLAST.DRILLBLAST_OPERATOR", "ts_col": "DW_MODIFY_TS"},
    {"name": "DRILLBLAST_SHIFT", "source": "PROD_WG.DRILL_BLAST.DRILLBLAST_SHIFT", "ts_col": "DW_MODIFY_TS"},
]

# Shared connection (externalbrowser only allows one auth)
_shared_connection = None
_connection_lock = threading.Lock()


def get_connection():
    """Get shared Snowflake connection (thread-safe singleton)."""
    global _shared_connection
    with _connection_lock:
        if _shared_connection is None:
            print("[Main] Creating Snowflake connection (browser auth)...")
            _shared_connection = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
            print("[Main] ✅ Snowflake connected!")
        return _shared_connection


def run_incremental_query(table_info: dict, days_back: int) -> dict:
    """
    Run a count query with the given days_back lookback window.
    
    Returns:
        dict with execution results
    """
    start_time = time.time()
    table_name = table_info["name"]
    source = table_info["source"]
    ts_col = table_info["ts_col"]
    
    result = {
        "table": table_name,
        "source": source,
        "days_back": days_back,
        "start_time": datetime.now().isoformat(),
        "status": "PENDING",
        "row_count": 0,
        "duration_seconds": 0,
        "error": None
    }
    
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Count rows in the incremental window
        # Note: Do NOT use TRY_TO_TIMESTAMP - these columns are already TIMESTAMP type
        # Using TRY_TO_TIMESTAMP on TIMESTAMP columns causes: "Function TRY_CAST cannot be used with arguments of types TIMESTAMP_NTZ"
        # Handle VARCHAR timestamp columns with TRY_TO_TIMESTAMP
        sql = f"""
            SELECT COUNT(*) AS row_count
            FROM {source}
            WHERE TRY_TO_TIMESTAMP({ts_col}) >= DATEADD(day, -{days_back}, CURRENT_TIMESTAMP())
               OR {ts_col} >= DATEADD(day, -{days_back}, CURRENT_TIMESTAMP())::VARCHAR
        """
        try:
            cursor.execute(sql)
        except Exception as sql_err:
            # Fallback: Try without TRY_TO_TIMESTAMP for native TIMESTAMP columns
            sql = f"""
                SELECT COUNT(*) AS row_count
                FROM {source}
                WHERE {ts_col} >= DATEADD(day, -{days_back}, CURRENT_TIMESTAMP())
            """
            cursor.execute(sql)
        
        row = cursor.fetchone()
        if row:
            result["row_count"] = row[0] or 0
            result["status"] = "SUCCESS"
        else:
            result["status"] = "NO_DATA"
        
        cursor.close()
        
    except Exception as e:
        result["status"] = "ERROR"
        result["error"] = str(e)
    
    result["duration_seconds"] = round(time.time() - start_time, 2)
    result["end_time"] = datetime.now().isoformat()
    
    return result


def stress_test_table(table_info: dict, days_list: list) -> list:
    """
    Run stress test for a single table with multiple day lookback values.
    
    Args:
        table_info: Dict with name, source, ts_col
        days_list: List of days to test (e.g., [1,2,3,...,30])
        
    Returns:
        List of result dictionaries
    """
    table_name = table_info["name"]
    thread_name = threading.current_thread().name
    print(f"\n[{thread_name}] Starting stress test for {table_name}")
    
    results = []
    
    for i, day in enumerate(days_list, 1):
        result = run_incremental_query(table_info, day)
        results.append(result)
        
        # Log progress
        status_icon = "✅" if result["status"] == "SUCCESS" else "❌"
        print(f"[{thread_name}] {status_icon} {table_name} Day={day}: "
              f"{result['duration_seconds']}s, rows={result.get('row_count', 0):,}")
    
    print(f"[{thread_name}] ✅ Completed {table_name} - {len(days_list)} iterations")
    return results


def run_stress_test(days_list: list = None):
    """
    Run the full stress test with one thread per table.
    """
    if days_list is None:
        days_list = list(range(1, 31))  # Default: 1-30
    
    print("=" * 80)
    print("DRILLBLAST_INCR SOURCE DATA STRESS TEST")
    print("=" * 80)
    print(f"Started: {datetime.now().isoformat()}")
    print(f"Tables: {len(SOURCE_TABLES)}")
    print(f"Days to test: {days_list}")
    print(f"Iterations per table: {len(days_list)}")
    print(f"Total queries: {len(SOURCE_TABLES) * len(days_list)}")
    print("=" * 80)
    
    # Pre-authenticate (single browser popup)
    print("\n📋 Authenticating to Snowflake...")
    get_connection()
    
    all_results = {}
    start_time = time.time()
    
    # Sequential execution to avoid connection issues
    for table_info in SOURCE_TABLES:
        table_name = table_info["name"]
        results = stress_test_table(table_info, days_list)
        all_results[table_name] = results
    
    total_duration = round(time.time() - start_time, 2)
    
    # Generate summary
    print("\n" + "=" * 80)
    print("STRESS TEST SUMMARY")
    print("=" * 80)
    
    summary = {
        "test_info": {
            "started": datetime.now().isoformat(),
            "total_duration_seconds": total_duration,
            "total_tables": len(SOURCE_TABLES),
            "days_tested": days_list,
            "iterations_per_table": len(days_list),
            "total_queries": len(SOURCE_TABLES) * len(days_list)
        },
        "results_by_table": {}
    }
    
    for table_info in SOURCE_TABLES:
        table_name = table_info["name"]
        results = all_results.get(table_name, [])
        
        successful = sum(1 for r in results if r.get("status") == "SUCCESS")
        failed = sum(1 for r in results if r.get("status") != "SUCCESS")
        total_rows = sum(r.get("row_count", 0) for r in results)
        max_rows = max((r.get("row_count", 0) for r in results), default=0)
        durations = [r.get("duration_seconds", 0) for r in results]
        avg_duration = round(sum(durations) / len(durations), 2) if durations else 0
        min_duration = round(min(durations), 2) if durations else 0
        max_duration = round(max(durations), 2) if durations else 0
        
        table_summary = {
            "source": table_info["source"],
            "successful": successful,
            "failed": failed,
            "max_row_count": max_rows,
            "avg_duration_seconds": avg_duration,
            "min_duration_seconds": min_duration,
            "max_duration_seconds": max_duration,
            "iterations": results
        }
        
        summary["results_by_table"][table_name] = table_summary
        
        status_icon = "✅" if failed == 0 and max_rows > 0 else ("⚠️" if max_rows == 0 else "❌")
        print(f"{status_icon} {table_name}:")
        print(f"   Source: {table_info['source']}")
        print(f"   Success: {successful}/{len(days_list)} | Max Rows (30d): {max_rows:,}")
        print(f"   Duration: avg={avg_duration}s, min={min_duration}s, max={max_duration}s")
    
    # Save results to JSON
    output_file = f"stress_test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path = os.path.join(os.path.dirname(__file__), output_file)
    
    with open(output_path, 'w') as f:
        json.dump(summary, f, indent=2, default=str)
    
    print("\n" + "=" * 80)
    print(f"Total Duration: {total_duration}s")
    print(f"Results saved to: {output_file}")
    print("=" * 80)
    
    # Data availability summary
    print("\n📊 DATA AVAILABILITY SUMMARY:")
    for table_info in SOURCE_TABLES:
        table_name = table_info["name"]
        max_rows = summary["results_by_table"][table_name]["max_row_count"]
        if max_rows > 0:
            print(f"   ✅ {table_name}: {max_rows:,} rows (30-day window)")
        else:
            print(f"   ❌ {table_name}: NO DATA FOUND")
    
    return summary


def run_dry_run():
    """
    Dry run to test the script without actually querying.
    """
    print("=" * 80)
    print("DRILLBLAST_INCR STRESS TEST - DRY RUN")
    print("=" * 80)
    print(f"This would execute {len(SOURCE_TABLES)} tables x 30 day values = {len(SOURCE_TABLES) * 30} queries")
    print("\nSource tables to test:")
    for i, t in enumerate(SOURCE_TABLES, 1):
        print(f"  {i:2}. {t['name']}")
        print(f"      Source: {t['source']}")
        print(f"      Timestamp: {t['ts_col']}")
    print("\nEach table will be queried with days_back = 1, 2, 3, ..., 30")
    print("=" * 80)


def run_quick_test():
    """
    Quick test with just 4 day values: 1, 7, 14, 30
    """
    return run_stress_test(days_list=[1, 7, 14, 30])


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "--dry-run":
            run_dry_run()
        elif sys.argv[1] == "--quick":
            run_quick_test()
        else:
            print(f"Unknown option: {sys.argv[1]}")
            print("Usage: python stress_test_incr.py [--dry-run|--quick]")
    else:
        print("\n⚠️  This will execute 330 queries against Snowflake!")
        print("    (11 tables × 30 days each)")
        print("\nOptions:")
        print("  --dry-run    Show what would be executed without running")
        print("  --quick      Run quick test (4 days: 1, 7, 14, 30)")
        print("\nPress Enter to continue with full test, or Ctrl+C to cancel...")
        
        try:
            input()
            run_stress_test()
        except KeyboardInterrupt:
            print("\n\nCancelled by user.")
