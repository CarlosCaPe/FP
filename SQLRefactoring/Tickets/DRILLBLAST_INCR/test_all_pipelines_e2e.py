"""
END-TO-END Pipeline Test for DEV
Tests all 14 INCR procedures after BLAST_PLAN_EXECUTION fix
"""

import sys
import os
from datetime import datetime
from pathlib import Path
import threading
import time as time_module

# Ensure Python 3.12
if sys.version_info[:2] != (3, 12):
    import subprocess
    result = subprocess.run(["py", "-3.12", __file__], cwd=os.path.dirname(os.path.abspath(__file__)))
    sys.exit(result.returncode)

try:
    import snowflake.connector
except ImportError:
    import subprocess
    subprocess.check_call(["py", "-3.12", "-m", "pip", "install", "snowflake-connector-python", "-q"])
    import snowflake.connector

SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "DEV_API_REF",
    "schema": "FUSE",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
    "client_session_keep_alive": True,
}

PROCEDURES = [
    "BL_DW_BLAST_INCR_P",
    "BL_DW_BLASTPROPERTYVALUE_INCR_P",
    "BL_DW_HOLE_INCR_P",
    "BLAST_PLAN_INCR_P",
    "BLAST_PLAN_EXECUTION_INCR_P",  # Fixed - BENCH NULL issue
    "DRILL_CYCLE_INCR_P",
    "DRILL_PLAN_INCR_P",
    "DRILLBLAST_EQUIPMENT_INCR_P",
    "DRILLBLAST_OPERATOR_INCR_P",
    "DRILLBLAST_SHIFT_INCR_P",
    "LH_BUCKET_INCR_P",
    "LH_EQUIPMENT_STATUS_EVENT_INCR_P",
    "LH_HAUL_CYCLE_INCR_P",  # Fixed - Hidayath's compilation error
    "LH_LOADING_CYCLE_INCR_P",
]


def main():
    script_dir = Path(__file__).parent
    deploy_dev = script_dir / "DEPLOY_DEV"
    
    print("=" * 80)
    print("END-TO-END PIPELINE TEST - DEV ENVIRONMENT")
    print("=" * 80)
    print(f"Started: {datetime.now().isoformat()}")
    print(f"Target:  DEV_API_REF.FUSE")
    print("=" * 80)
    
    # Connect
    print("\n📋 Connecting to Snowflake...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    print("✅ Connected!\n")
    
    cursor.execute("USE DATABASE DEV_API_REF;")
    cursor.execute("USE SCHEMA FUSE;")
    cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD;")
    
    # STEP 1: Deploy fixed BLAST_PLAN_EXECUTION_INCR table
    print("=" * 80)
    print("STEP 1: Deploy fixed BLAST_PLAN_EXECUTION_INCR table")
    print("=" * 80)
    
    table_path = deploy_dev / "TABLES" / "R__BLAST_PLAN_EXECUTION_INCR.sql"
    if table_path.exists():
        sql = table_path.read_text(encoding="utf-8")
        try:
            cursor.execute(sql)
            print("  ✅ BLAST_PLAN_EXECUTION_INCR table recreated (BENCH now nullable)")
        except Exception as e:
            print(f"  ❌ Error: {e}")
    
    # STEP 2: Test all procedures
    print("\n" + "=" * 80)
    print("STEP 2: Execute all 14 procedures (3-day window)")
    print("=" * 80)
    
    results = []
    total_start = time_module.time()
    
    for i, proc in enumerate(PROCEDURES, 1):
        print(f"\n[{i:02d}/14] {proc}")
        
        stop_timer = False
        start_time = time_module.time()
        
        def show_progress():
            spinner = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
            j = 0
            while not stop_timer:
                elapsed = int(time_module.time() - start_time)
                mins, secs = divmod(elapsed, 60)
                print(f"\r        {spinner[j % 10]} Executing... {mins:02d}:{secs:02d}", end="", flush=True)
                time_module.sleep(0.2)
                j += 1
        
        timer = threading.Thread(target=show_progress)
        timer.start()
        
        try:
            cursor.execute(f"CALL DEV_API_REF.FUSE.{proc}('3');")
            result = cursor.fetchone()[0]
            stop_timer = True
            timer.join()
            elapsed = time_module.time() - start_time
            print(f"\r        ✅ {result} ({elapsed:.1f}s)")
            results.append((proc, "SUCCESS", result, elapsed))
        except Exception as e:
            stop_timer = True
            timer.join()
            elapsed = time_module.time() - start_time
            err_msg = str(e)[:60]
            print(f"\r        ❌ Error: {err_msg}")
            results.append((proc, "ERROR", err_msg, elapsed))
    
    total_elapsed = time_module.time() - total_start
    
    # STEP 3: Verify row counts
    print("\n" + "=" * 80)
    print("STEP 3: Verify table row counts")
    print("=" * 80)
    
    tables = [p.replace("_P", "") for p in PROCEDURES]
    for table in tables:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}")
            count = cursor.fetchone()[0]
            print(f"  {table}: {count:,} rows")
        except Exception as e:
            print(f"  {table}: ERROR - {e}")
    
    # SUMMARY
    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    
    success = [r for r in results if r[1] == "SUCCESS"]
    errors = [r for r in results if r[1] == "ERROR"]
    
    print(f"\n  Total Time: {total_elapsed/60:.1f} minutes")
    print(f"  ✅ Success: {len(success)}/14")
    print(f"  ❌ Errors:  {len(errors)}/14")
    
    if errors:
        print("\n  FAILED PROCEDURES:")
        for proc, status, msg, elapsed in errors:
            print(f"    - {proc}: {msg}")
    else:
        print("\n  🎉 ALL PIPELINES PASSED!")
    
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 80)
    print(f"Completed: {datetime.now().isoformat()}")
    print("=" * 80)
    
    return len(errors) == 0


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
