"""Check task history with proper time"""
from snowrefactor.snowflake_conn import connect
from datetime import datetime

print(f"Local time: {datetime.now().strftime('%H:%M:%S')}")

conn = connect()
cur = conn.cursor()
cur.execute("SELECT CURRENT_TIMESTAMP()")
sf_time = cur.fetchone()[0]
print(f"Snowflake time: {sf_time}")

# Try task_history
cur.execute("""
    SELECT name, state, scheduled_time, query_start_time, completed_time, return_value
    FROM TABLE(DEV_API_REF.INFORMATION_SCHEMA.TASK_HISTORY(
        SCHEDULED_TIME_RANGE_START => DATEADD(hour, -3, CURRENT_TIMESTAMP())
    ))
    WHERE name LIKE 'LH_%'
    ORDER BY scheduled_time DESC
    LIMIT 10
""")
rows = cur.fetchall()
print(f"\nTask history rows: {len(rows)}")
for r in rows:
    print(f"  {r[0]}: {r[1]} scheduled={r[2]} result={r[5][:40] if r[5] else '-'}")
