"""
DRILLBLAST_INCR - Deploy to DEV NOW
Uses Python 3.12 for Snowflake connector compatibility
Deploys all 28 objects from DEPLOY_DEV folder
"""

import os
import sys
import re
from datetime import datetime
from pathlib import Path

# Ensure we use Python 3.12
if sys.version_info[:2] != (3, 12):
    import subprocess
    print(f"Current Python: {sys.version}")
    print("Switching to Python 3.12...")
    result = subprocess.run(
        ["py", "-3.12", __file__],
        cwd=os.path.dirname(os.path.abspath(__file__))
    )
    sys.exit(result.returncode)

# Install dependencies if needed
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


def main():
    script_dir = Path(__file__).parent
    deploy_dev = script_dir / "DEPLOY_DEV"
    
    print("=" * 70)
    print("DRILLBLAST_INCR - DEPLOY ALL TO DEV")
    print("=" * 70)
    print(f"Started: {datetime.now().isoformat()}")
    print(f"Target:  DEV_API_REF.FUSE")
    print(f"Source:  {deploy_dev}")
    print("=" * 70)
    
    # Collect files
    tables_dir = deploy_dev / "TABLES"
    procs_dir = deploy_dev / "PROCEDURES"
    
    table_files = sorted(tables_dir.glob("*.sql"))
    proc_files = sorted(procs_dir.glob("*.sql"))
    
    print(f"\n📁 Found {len(table_files)} tables, {len(proc_files)} procedures")
    
    # Connect
    print("\n📋 Connecting to Snowflake (browser auth)...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    print("✅ Connected!\n")
    
    # Set context
    cursor.execute("USE DATABASE DEV_API_REF;")
    cursor.execute("USE SCHEMA FUSE;")
    cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD;")
    
    success = {"tables": [], "procedures": []}
    errors = []
    
    # Deploy TABLES first
    print("=" * 70)
    print("DEPLOYING TABLES")
    print("=" * 70)
    
    for f in table_files:
        name = f.stem.replace("R__", "")
        sql = f.read_text(encoding="utf-8")
        
        try:
            cursor.execute(sql)
            success["tables"].append(name)
            print(f"  ✅ {name}")
        except Exception as e:
            errors.append((name, str(e)))
            print(f"  ❌ {name}: {e}")
    
    # Deploy PROCEDURES
    print("\n" + "=" * 70)
    print("DEPLOYING PROCEDURES")
    print("=" * 70)
    
    for f in proc_files:
        name = f.stem.replace("R__", "")
        sql = f.read_text(encoding="utf-8")
        
        try:
            cursor.execute(sql)
            success["procedures"].append(name)
            print(f"  ✅ {name}")
        except Exception as e:
            errors.append((name, str(e)))
            print(f"  ❌ {name}: {e}")
    
    # Summary
    print("\n" + "=" * 70)
    print("DEPLOYMENT SUMMARY")
    print("=" * 70)
    print(f"  Tables:     {len(success['tables'])}/{len(table_files)} ✅")
    print(f"  Procedures: {len(success['procedures'])}/{len(proc_files)} ✅")
    
    if errors:
        print(f"\n  ⚠️  ERRORS: {len(errors)}")
        for name, err in errors:
            print(f"    - {name}: {err[:80]}...")
    else:
        print("\n  🎉 ALL OBJECTS DEPLOYED SUCCESSFULLY!")
    
    # Test LH_HAUL_CYCLE_INCR_P (Hidayath's fix) with timer
    print("\n" + "=" * 70)
    print("TESTING LH_HAUL_CYCLE_INCR_P (Hidayath's fix)")
    print("=" * 70)
    print("  ⏳ This may take 2-5 minutes (340+ columns, thousands of rows)...")
    
    import threading
    import time as time_module
    
    stop_timer = False
    
    def show_progress():
        start = time_module.time()
        spinner = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
        i = 0
        while not stop_timer:
            elapsed = int(time_module.time() - start)
            mins, secs = divmod(elapsed, 60)
            print(f"\r  {spinner[i % 10]} Running... {mins:02d}:{secs:02d}", end="", flush=True)
            time_module.sleep(0.2)
            i += 1
        elapsed = int(time_module.time() - start)
        mins, secs = divmod(elapsed, 60)
        print(f"\r  ⏱️  Completed in {mins:02d}:{secs:02d}              ")
    
    timer_thread = threading.Thread(target=show_progress)
    timer_thread.start()
    
    try:
        cursor.execute("CALL DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P('3');")
        result = cursor.fetchone()
        stop_timer = True
        timer_thread.join()
        print(f"  Result: {result[0]}")
        print("  ✅ Procedure executed successfully!")
    except Exception as e:
        stop_timer = True
        timer_thread.join()
        print(f"  ❌ Error: {e}")
    
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 70)
    print(f"Completed: {datetime.now().isoformat()}")
    print("=" * 70)


if __name__ == "__main__":
    main()
