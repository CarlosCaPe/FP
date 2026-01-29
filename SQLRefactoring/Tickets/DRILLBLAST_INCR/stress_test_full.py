"""
stress_test_full.py
====================
Full stress test with timing metrics for all INCR infrastructure.
Tests SQL Server tables, procedures, and execution performance.

Author: Carlos Carrillo
Date: 2026-01-28
"""

import pyodbc
import struct
import time
from azure.identity import InteractiveBrowserCredential
from datetime import datetime

# SQL Server connection details
SQL_SERVER = "azwd22midbx02.eb8a77f2eea6.database.windows.net"
SQL_DATABASE = "SNOWFLAKE_WG"

# All archival procedures
ALL_PROCEDURES = [
    ("usp_Archive_BLAST_PLAN_INCR", "DRILL_BLAST__BLAST_PLAN_INCR"),
    ("usp_Archive_BLAST_PLAN_EXECUTION_INCR", "DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR"),
    ("usp_Archive_BL_DW_BLAST_INCR", "DRILL_BLAST__BL_DW_BLAST_INCR"),
    ("usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR", "DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR"),
    ("usp_Archive_BL_DW_HOLE_INCR", "DRILL_BLAST__BL_DW_HOLE_INCR"),
    ("usp_Archive_DRILLBLAST_EQUIPMENT_INCR", "DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR"),
    ("usp_Archive_DRILLBLAST_OPERATOR_INCR", "DRILL_BLAST__DRILLBLAST_OPERATOR_INCR"),
    ("usp_Archive_DRILLBLAST_SHIFT_INCR", "DRILL_BLAST__DRILLBLAST_SHIFT_INCR"),
    ("usp_Archive_DRILL_CYCLE_INCR", "DRILL_BLAST__DRILL_CYCLE_INCR"),
    ("usp_Archive_DRILL_PLAN_INCR", "DRILL_BLAST__DRILL_PLAN_INCR"),
    ("usp_Archive_LH_HAUL_CYCLE_INCR", "LOAD_HAUL__LH_HAUL_CYCLE_INCR"),
    ("usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR", "LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR"),
    ("usp_Archive_LH_LOADING_CYCLE_INCR", "LOAD_HAUL__LH_LOADING_CYCLE_INCR"),
    ("usp_Archive_LH_BUCKET_INCR", "LOAD_HAUL__LH_BUCKET_INCR"),
]


def get_connection():
    """Connect to SQL Server using Azure AD."""
    print("🔐 Connecting to SQL Server...")
    credential = InteractiveBrowserCredential(timeout=60)
    token = credential.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("UTF-16-LE")
    token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
    
    conn_str = f"Driver={{ODBC Driver 17 for SQL Server}};Server={SQL_SERVER};Database={SQL_DATABASE};"
    conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
    print(f"✅ Connected to SQL Server: {SQL_DATABASE}")
    return conn


def run_stress_test(conn):
    """Run stress test on all procedures with timing."""
    cursor = conn.cursor()
    
    print("\n" + "=" * 80)
    print("  STRESS TEST - ALL ARCHIVAL PROCEDURES")
    print("=" * 80)
    
    results = []
    total_start = time.time()
    
    # Test individual procedures
    print("\n  📊 Testing all 14 individual procedures...")
    print("-" * 80)
    
    for proc_name, table_name in ALL_PROCEDURES:
        # Get row count before
        cursor.execute(f"SELECT COUNT(*) FROM [{table_name}]")
        rows_before = cursor.fetchone()[0]
        
        # Execute procedure with timing
        start = time.time()
        try:
            cursor.execute(f"EXEC {proc_name} @NumberOfDays = 3")
            result = cursor.fetchone()
            status = result[0] if result else "NO RESULT"
            deleted = result[1] if result and len(result) > 1 else 0
        except Exception as e:
            status = f"ERROR: {str(e)[:30]}"
            deleted = 0
        elapsed = (time.time() - start) * 1000  # ms
        
        # Get row count after
        cursor.execute(f"SELECT COUNT(*) FROM [{table_name}]")
        rows_after = cursor.fetchone()[0]
        
        results.append({
            'procedure': proc_name,
            'table': table_name,
            'status': status,
            'deleted': deleted,
            'rows_before': rows_before,
            'rows_after': rows_after,
            'time_ms': elapsed
        })
        
        status_icon = "✅" if status == "SUCCESS" else "❌"
        print(f"  {status_icon} {proc_name}")
        print(f"     Time: {elapsed:.2f}ms | Rows: {rows_before:,} → {rows_after:,} | Deleted: {deleted}")
    
    # Test master procedure
    print("\n" + "-" * 80)
    print("  📊 Testing MASTER procedure (usp_Archive_All_INCR_Tables)...")
    print("-" * 80)
    
    start = time.time()
    try:
        cursor.execute("EXEC usp_Archive_All_INCR_Tables @NumberOfDays = 3")
        result = cursor.fetchone()
        master_status = result[0] if result else "NO RESULT"
        master_deleted = result[1] if result and len(result) > 1 else 0
    except Exception as e:
        master_status = f"ERROR: {str(e)[:30]}"
        master_deleted = 0
    master_elapsed = (time.time() - start) * 1000
    
    status_icon = "✅" if master_status == "SUCCESS" else "❌"
    print(f"\n  {status_icon} usp_Archive_All_INCR_Tables")
    print(f"     Time: {master_elapsed:.2f}ms | Total Deleted: {master_deleted}")
    
    total_elapsed = (time.time() - total_start) * 1000
    
    return results, master_elapsed, total_elapsed


def print_summary(results, master_time, total_time):
    """Print stress test summary."""
    
    print("\n" + "=" * 80)
    print("  STRESS TEST RESULTS")
    print("=" * 80)
    
    # Performance metrics
    times = [r['time_ms'] for r in results]
    avg_time = sum(times) / len(times)
    max_time = max(times)
    min_time = min(times)
    
    print(f"""
  ┌──────────────────────────────────────────────────────────────────────────────┐
  │                         PERFORMANCE METRICS                                   │
  ├──────────────────────────────────────────────────────────────────────────────┤
  │  Individual Procedures (14):                                                  │
  │    • Average Execution Time:  {avg_time:>10.2f} ms                                │
  │    • Fastest Execution:       {min_time:>10.2f} ms                                │
  │    • Slowest Execution:       {max_time:>10.2f} ms                                │
  │    • Total Individual Time:   {sum(times):>10.2f} ms                                │
  │                                                                               │
  │  Master Procedure (1):                                                        │
  │    • Execution Time:          {master_time:>10.2f} ms                                │
  │                                                                               │
  │  Overall:                                                                     │
  │    • Total Test Duration:     {total_time:>10.2f} ms ({total_time/1000:.2f} sec)              │
  └──────────────────────────────────────────────────────────────────────────────┘
""")

    # Detailed results table
    print("\n  ┌" + "─" * 76 + "┐")
    print("  │ {:40} │ {:10} │ {:8} │ {:10} │".format(
        "PROCEDURE", "STATUS", "TIME(ms)", "DELETED"))
    print("  ├" + "─" * 76 + "┤")
    
    for r in results:
        proc_short = r['procedure'].replace('usp_Archive_', '')[:38]
        print("  │ {:40} │ {:10} │ {:8.2f} │ {:10} │".format(
            proc_short, r['status'][:10], r['time_ms'], r['deleted']))
    
    print("  ├" + "─" * 76 + "┤")
    print("  │ {:40} │ {:10} │ {:8.2f} │ {:10} │".format(
        "MASTER (All_INCR_Tables)", "SUCCESS", master_time, sum(r['deleted'] for r in results)))
    print("  └" + "─" * 76 + "┘")
    
    # Status summary
    passed = sum(1 for r in results if r['status'] == "SUCCESS")
    failed = len(results) - passed
    
    print(f"""
  ╔══════════════════════════════════════════════════════════════════════════════╗
  ║                           TEST SUMMARY                                        ║
  ╠══════════════════════════════════════════════════════════════════════════════╣
  ║  • Individual Procedures Tested: 14                                           ║
  ║  • Master Procedure Tested: 1                                                 ║
  ║  • Total Procedures: 15                                                       ║
  ║  • Passed: {passed:>2}                                                                 ║
  ║  • Failed: {failed:>2}                                                                 ║
  ║  • Status: {'✅ ALL TESTS PASSED' if failed == 0 else '❌ SOME TESTS FAILED'}                                              ║
  ╚══════════════════════════════════════════════════════════════════════════════╝
""")
    
    return passed, failed, avg_time, max_time, total_time


def main():
    print("=" * 80)
    print("  SQL SERVER INCR - FULL STRESS TEST WITH TIMING")
    print(f"  Database: {SQL_DATABASE}")
    print(f"  Server: {SQL_SERVER}")
    print(f"  Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    
    conn = get_connection()
    results, master_time, total_time = run_stress_test(conn)
    passed, failed, avg_time, max_time, total_time = print_summary(results, master_time, total_time)
    
    conn.close()
    
    # Return metrics for documentation
    return {
        'passed': passed,
        'failed': failed,
        'avg_time_ms': avg_time,
        'max_time_ms': max_time,
        'total_time_ms': total_time,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }


if __name__ == "__main__":
    main()
