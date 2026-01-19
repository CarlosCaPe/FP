"""Resume tasks and check status"""
from snowrefactor.snowflake_conn import connect
from datetime import datetime

print("="*60)
print("RESUME TASKS & VERIFY STATUS")
print("="*60)

with connect() as conn:
    cur = conn.cursor()
    cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
    cur.execute("USE DATABASE DEV_API_REF")
    cur.execute("USE SCHEMA FUSE")
    
    # Resume tasks
    print("\n[1] Resuming LH_BUCKET_CT_T...")
    cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_BUCKET_CT_T RESUME")
    print("    ✓ RESUMED")
    
    print("\n[2] Resuming LH_LOADING_CYCLE_CT_T...")
    cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_T RESUME")
    print("    ✓ RESUMED")
    
    # Show current state
    print("\n[3] Task status:")
    cur.execute("SHOW TASKS LIKE 'LH_%' IN SCHEMA DEV_API_REF.FUSE")
    rows = cur.fetchall()
    for r in rows:
        name = r[1]
        state = r[9] if len(r) > 9 else "unknown"
        print(f"    - {name}: state={state}")
    
    # Check table row counts
    print("\n[4] Current row counts:")
    cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_CT")
    print(f"    LH_BUCKET_CT: {cur.fetchone()[0]:,} rows")
    cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT")
    print(f"    LH_LOADING_CYCLE_CT: {cur.fetchone()[0]:,} rows")

print("\n" + "="*60)
print(f"Done at {datetime.now().strftime('%H:%M:%S')}")
print("Tasks will run every 15 min. Check back in 1 hour.")
print("="*60)
