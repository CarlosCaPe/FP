"""Check task history after manual execution"""
from snowrefactor.snowflake_conn import connect
import time

conn = connect()
cur = conn.cursor()

print("Waiting 5 seconds for task to complete...")
time.sleep(5)

cur.execute("""
    SELECT name, state, scheduled_time, completed_time, return_value, error_message
    FROM TABLE(DEV_API_REF.INFORMATION_SCHEMA.TASK_HISTORY(
        SCHEDULED_TIME_RANGE_START => DATEADD(minute, -10, CURRENT_TIMESTAMP())
    ))
    ORDER BY scheduled_time DESC
    LIMIT 10
""")
rows = cur.fetchall()
print(f"Task history (last 10 min): {len(rows)} rows")
print("-"*70)
for r in rows:
    name = r[0]
    state = r[1]
    scheduled = r[2]
    completed = r[3]
    result = r[4][:60] if r[4] else "-"
    error = r[5] if r[5] else "-"
    
    print(f"{name}: {state}")
    print(f"  scheduled: {scheduled}")
    print(f"  completed: {completed}")
    print(f"  result: {result}")
    if error != "-":
        print(f"  ERROR: {error}")
    print()
