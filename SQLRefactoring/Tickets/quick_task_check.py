"""Quick task status check"""
from snowrefactor.snowflake_conn import connect
from datetime import datetime

print("="*60)
print(f"TASK STATUS CHECK - {datetime.now().strftime('%H:%M:%S')}")
print("="*60)

with connect() as conn:
    cur = conn.cursor()
    cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
    
    # Check task history
    cur.execute("""
        SELECT name, state, scheduled_time, completed_time, return_value
        FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
            SCHEDULED_TIME_RANGE_START => DATEADD(hour, -2, CURRENT_TIMESTAMP()),
            RESULT_LIMIT => 20
        ))
        WHERE name LIKE 'LH_%'
        ORDER BY scheduled_time DESC
    """)
    rows = cur.fetchall()
    
    if rows:
        print(f"\n✅ Task executions found: {len(rows)}")
        print("-"*60)
        for r in rows:
            name = r[0]
            state = r[1]
            scheduled = r[2].strftime('%H:%M:%S') if r[2] else "-"
            result = r[4][:60] if r[4] else "-"
            print(f"{name}: {state} @ {scheduled}")
            print(f"   Result: {result}")
    else:
        print("\n⏳ No task executions yet.")
        print("\nChecking task state...")
        cur.execute("SHOW TASKS LIKE 'LH_%' IN SCHEMA DEV_API_REF.FUSE")
        for r in cur.fetchall():
            print(f"  {r[1]}: state={r[9]}")
