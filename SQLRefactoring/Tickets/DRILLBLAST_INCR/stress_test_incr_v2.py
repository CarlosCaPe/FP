"""
DRILLBLAST_INCR Stress Test v2
==============================
Fixed version that:
1. Uses correct table paths
2. Does NOT use TRY_TO_TIMESTAMP on TIMESTAMP columns
3. Handles VARCHAR timestamp columns separately

Usage:
    python stress_test_incr_v2.py --quick   # Test with [1, 7, 14, 30] days
    python stress_test_incr_v2.py           # Full test with days 1-30
"""

import os
import json
import time
from datetime import datetime
import snowflake.connector
from dotenv import load_dotenv

load_dotenv()

SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "PROD_WG",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
    "client_session_keep_alive": True,
}

# ALL 11 source tables with correct paths - Vikas requirement complete
# ts_type: 'timestamp' for native TIMESTAMP, 'varchar' for VARCHAR columns
SOURCE_TABLES = [
    # DRILL_BLAST schema - confirmed working with native TIMESTAMP
    {"name": "DRILL_CYCLE", "source": "PROD_WG.DRILL_BLAST.DRILL_CYCLE", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    {"name": "DRILL_PLAN", "source": "PROD_WG.DRILL_BLAST.DRILL_PLAN", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    {"name": "BLAST_PLAN", "source": "PROD_WG.DRILL_BLAST.BLAST_PLAN", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    {"name": "BLAST_PLAN_EXECUTION", "source": "PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    {"name": "DRILLBLAST_EQUIPMENT", "source": "PROD_WG.DRILL_BLAST.DRILLBLAST_EQUIPMENT", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    {"name": "DRILLBLAST_OPERATOR", "source": "PROD_WG.DRILL_BLAST.DRILLBLAST_OPERATOR", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    {"name": "DRILLBLAST_SHIFT", "source": "PROD_WG.DRILL_BLAST.DRILLBLAST_SHIFT", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    # BL_DW tables - discovered in DRILL_BLAST schema
    {"name": "BL_DW_BLAST", "source": "PROD_WG.DRILL_BLAST.BL_DW_BLAST", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    {"name": "BL_DW_BLASTPROPERTYVALUE", "source": "PROD_WG.DRILL_BLAST.BL_DW_BLASTPROPERTYVALUE", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    {"name": "BL_DW_HOLE", "source": "PROD_WG.DRILL_BLAST.BL_DW_HOLE", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
    # LOAD_HAUL schema - LH_HAUL_CYCLE uses DW_MODIFY_TS (native TIMESTAMP)
    {"name": "LH_HAUL_CYCLE", "source": "PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE", "ts_col": "DW_MODIFY_TS", "ts_type": "timestamp"},
]


def run_query(cursor, table_info: dict, days_back: int) -> dict:
    """Run a single query and return results."""
    source = table_info["source"]
    ts_col = table_info["ts_col"]
    ts_type = table_info.get("ts_type", "timestamp")
    
    result = {
        "table": table_info["name"],
        "source": source,
        "days_back": days_back,
        "start_time": datetime.now().isoformat(),
        "status": "PENDING",
        "row_count": 0,
        "duration_seconds": 0,
        "error": None
    }
    
    start_time = time.time()
    
    try:
        # Build query based on timestamp type
        if ts_type == "varchar":
            # VARCHAR timestamp - use TRY_TO_TIMESTAMP
            sql = f"""
                SELECT COUNT(*) AS row_count
                FROM {source}
                WHERE TRY_TO_TIMESTAMP({ts_col}) >= DATEADD(day, -{days_back}, CURRENT_TIMESTAMP())
            """
        else:
            # Native TIMESTAMP - direct comparison (NO TRY_TO_TIMESTAMP!)
            sql = f"""
                SELECT COUNT(*) AS row_count
                FROM {source}
                WHERE {ts_col} >= DATEADD(day, -{days_back}, CURRENT_TIMESTAMP())
            """
        
        cursor.execute(sql)
        row = cursor.fetchone()
        
        if row:
            result["row_count"] = row[0] or 0
            result["status"] = "SUCCESS" if result["row_count"] > 0 else "EMPTY"
        else:
            result["status"] = "NO_DATA"
            
    except Exception as e:
        result["status"] = "ERROR"
        result["error"] = str(e)[:200]
    
    result["duration_seconds"] = round(time.time() - start_time, 2)
    result["end_time"] = datetime.now().isoformat()
    
    return result


def run_stress_test(days_list: list):
    """Run stress test for all tables."""
    print("=" * 70)
    print("DRILLBLAST_INCR STRESS TEST v2")
    print("=" * 70)
    print(f"Started: {datetime.now().isoformat()}")
    print(f"Tables: {len(SOURCE_TABLES)}")
    print(f"Days to test: {days_list}")
    print(f"Total queries: {len(SOURCE_TABLES) * len(days_list)}")
    print("=" * 70)
    
    # Connect
    print("\n📋 Connecting to Snowflake...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    print("✅ Connected!\n")
    
    all_results = {}
    start_time = time.time()
    
    for table_info in SOURCE_TABLES:
        table_name = table_info["name"]
        print(f"\n[{table_name}] Testing...")
        
        table_results = []
        for day in days_list:
            result = run_query(cursor, table_info, day)
            table_results.append(result)
            
            # Print progress
            icon = "✅" if result["status"] == "SUCCESS" else ("⚪" if result["status"] == "EMPTY" else "❌")
            print(f"  {icon} Day={day}: {result['row_count']:,} rows ({result['duration_seconds']}s)")
            
            if result["error"]:
                print(f"     ERROR: {result['error'][:80]}")
        
        # Calculate stats
        successful = sum(1 for r in table_results if r["status"] == "SUCCESS")
        max_rows = max(r["row_count"] for r in table_results)
        avg_duration = round(sum(r["duration_seconds"] for r in table_results) / len(table_results), 2)
        
        all_results[table_name] = {
            "source": table_info["source"],
            "successful": successful,
            "total": len(days_list),
            "max_rows": max_rows,
            "avg_duration": avg_duration,
            "iterations": table_results
        }
        
        print(f"  Summary: {successful}/{len(days_list)} success, max {max_rows:,} rows")
    
    total_duration = round(time.time() - start_time, 2)
    
    # Close connection
    cursor.close()
    conn.close()
    
    # Print summary
    print("\n" + "=" * 70)
    print("STRESS TEST SUMMARY")
    print("=" * 70)
    
    for table_name, stats in all_results.items():
        icon = "✅" if stats["successful"] == stats["total"] else "⚠️"
        print(f"{icon} {table_name}:")
        print(f"   Source: {stats['source']}")
        print(f"   Success: {stats['successful']}/{stats['total']} | Max Rows: {stats['max_rows']:,}")
        print(f"   Avg Duration: {stats['avg_duration']}s")
    
    # Save results
    output = {
        "test_info": {
            "timestamp": datetime.now().isoformat(),
            "total_duration_seconds": total_duration,
            "tables_tested": len(SOURCE_TABLES),
            "days_tested": days_list,
        },
        "results": all_results
    }
    
    output_file = f"stress_test_v2_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path = os.path.join(os.path.dirname(__file__), output_file)
    with open(output_path, 'w') as f:
        json.dump(output, f, indent=2, default=str)
    
    print("\n" + "=" * 70)
    print(f"Total Duration: {total_duration}s")
    print(f"Results saved to: {output_file}")
    print("=" * 70)
    
    return output


if __name__ == "__main__":
    import sys
    
    if "--quick" in sys.argv:
        # Quick test with 4 sample days
        days = [1, 7, 14, 30]
    else:
        # Full test with all 30 days
        days = list(range(1, 31))
    
    run_stress_test(days)
