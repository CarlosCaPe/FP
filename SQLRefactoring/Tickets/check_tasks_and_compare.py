"""Check task history and compare performance with Hidayath's tables"""
from snowrefactor.snowflake_conn import connect
from datetime import datetime
import time

print("="*70)
print("TASK STATUS & PERFORMANCE COMPARISON")
print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print("="*70)

with connect() as conn:
    cur = conn.cursor()
    cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
    cur.execute("USE DATABASE DEV_API_REF")
    cur.execute("USE SCHEMA FUSE")
    
    # ========================================
    # 1. CHECK TASK HISTORY
    # ========================================
    print("\n📋 TASK EXECUTION HISTORY (last 2 hours):")
    print("-"*70)
    
    cur.execute("""
        SELECT 
            name,
            state,
            scheduled_time,
            completed_time,
            DATEDIFF('second', scheduled_time, completed_time) as duration_sec,
            return_value
        FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
            SCHEDULED_TIME_RANGE_START => DATEADD(hour, -2, CURRENT_TIMESTAMP()),
            RESULT_LIMIT => 20
        ))
        WHERE name LIKE 'LH_%'
        ORDER BY scheduled_time DESC
    """)
    rows = cur.fetchall()
    
    if rows:
        print(f"{'Task':<30} | {'State':<12} | {'Scheduled':<20} | {'Duration':<10}")
        print("-"*70)
        for r in rows:
            name = r[0][:28] if r[0] else ""
            state = r[1] if r[1] else ""
            scheduled = r[2].strftime('%H:%M:%S') if r[2] else ""
            duration = f"{r[4]}s" if r[4] else "-"
            print(f"{name:<30} | {state:<12} | {scheduled:<20} | {duration:<10}")
    else:
        print("  No task executions found in last 2 hours.")
        print("  Tasks may not have run yet (next run at :00, :15, :30, :45)")
    
    # ========================================
    # 2. CURRENT ROW COUNTS
    # ========================================
    print("\n\n📊 CURRENT ROW COUNTS:")
    print("-"*70)
    
    tables = [
        "DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT",  # Hidayath's
        "DEV_API_REF.FUSE.LH_EQUIPMENT_STATUS_EVENT_CT",  # Hidayath's
        "DEV_API_REF.FUSE.LH_BUCKET_CT",  # Ours
        "DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT"  # Ours
    ]
    
    for table in tables:
        try:
            cur.execute(f"SELECT COUNT(*) FROM {table}")
            count = cur.fetchone()[0]
            owner = "Hidayath" if "DRILL" in table or "EQUIPMENT" in table else "Carlos"
            print(f"  {table.split('.')[-1]:<35} | {count:>12,} rows | ({owner})")
        except:
            print(f"  {table.split('.')[-1]:<35} | ERROR")
    
    # ========================================
    # 3. PERFORMANCE COMPARISON
    # ========================================
    print("\n\n⚡ PERFORMANCE COMPARISON (Hidayath vs Carlos):")
    print("-"*70)
    print("Running stress tests with same day ranges...")
    print()
    
    TEST_DAYS = [1, 3, 7, 14, 30]
    
    results = {
        "DRILLBLAST_DRILL_CYCLE_CT_P": [],
        "LH_BUCKET_CT_P": [],
        "LH_LOADING_CYCLE_CT_P": []
    }
    
    for proc in results.keys():
        table = proc.replace("_P", "")
        print(f"\n  Testing {proc}...")
        
        for days in TEST_DAYS:
            try:
                # Truncate for clean test
                cur.execute(f"TRUNCATE TABLE DEV_API_REF.FUSE.{table}")
                
                # Run procedure
                start = time.time()
                cur.execute(f"CALL DEV_API_REF.FUSE.{proc}('{days}')")
                duration = time.time() - start
                
                # Get row count
                cur.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}")
                rows = cur.fetchone()[0]
                
                results[proc].append({
                    "days": days,
                    "duration": round(duration, 2),
                    "rows": rows
                })
                print(f"    {days}d: {duration:.2f}s ({rows:,} rows)")
                
            except Exception as e:
                print(f"    {days}d: ERROR - {str(e)[:50]}")
                results[proc].append({"days": days, "error": str(e)[:50]})
    
    # ========================================
    # 4. COMPARISON TABLE
    # ========================================
    print("\n\n📈 COMPARISON TABLE (seconds):")
    print("-"*70)
    print(f"{'Days':<6} | {'DRILLBLAST (H)':<18} | {'LH_BUCKET (C)':<18} | {'LH_LOADING (C)':<18}")
    print("-"*70)
    
    for i, days in enumerate(TEST_DAYS):
        drill = results["DRILLBLAST_DRILL_CYCLE_CT_P"][i] if i < len(results["DRILLBLAST_DRILL_CYCLE_CT_P"]) else {}
        bucket = results["LH_BUCKET_CT_P"][i] if i < len(results["LH_BUCKET_CT_P"]) else {}
        loading = results["LH_LOADING_CYCLE_CT_P"][i] if i < len(results["LH_LOADING_CYCLE_CT_P"]) else {}
        
        drill_str = f"{drill.get('duration', '-')}s ({drill.get('rows', 0):,}r)" if 'duration' in drill else "ERROR"
        bucket_str = f"{bucket.get('duration', '-')}s ({bucket.get('rows', 0):,}r)" if 'duration' in bucket else "ERROR"
        loading_str = f"{loading.get('duration', '-')}s ({loading.get('rows', 0):,}r)" if 'duration' in loading else "ERROR"
        
        print(f"{days:<6} | {drill_str:<18} | {bucket_str:<18} | {loading_str:<18}")
    
    print("-"*70)
    print("(H) = Hidayath | (C) = Carlos")

print("\n" + "="*70)
print("DONE!")
print("="*70)
