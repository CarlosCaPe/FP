"""Check ALL task history in FUSE schema"""
from snowrefactor.snowflake_conn import connect

conn = connect()
cur = conn.cursor()
cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")

# Check ALL tasks history (not just LH_)
cur.execute("""
    SELECT name, state, scheduled_time, completed_time, error_message, return_value
    FROM TABLE(DEV_API_REF.INFORMATION_SCHEMA.TASK_HISTORY(
        SCHEDULED_TIME_RANGE_START => DATEADD(hour, -24, CURRENT_TIMESTAMP())
    ))
    ORDER BY scheduled_time DESC
    LIMIT 20
""")
rows = cur.fetchall()

print(f"ALL task history in last 24h: {len(rows)} rows")
print("-"*80)
for r in rows:
    name = r[0]
    state = r[1]
    scheduled = r[2].strftime('%Y-%m-%d %H:%M') if r[2] else "-"
    error = r[4][:50] if r[4] else "-"
    result = r[5][:30] if r[5] else "-"
    print(f"{name}: {state} @ {scheduled}")
    if error != "-":
        print(f"   ERROR: {error}")

# Also check if there's a Hidayath task that IS running for comparison
print("\n" + "="*80)
print("Checking DRILLBLAST task history for comparison:")
cur.execute("""
    SELECT name, state, scheduled_time, return_value
    FROM TABLE(DEV_API_REF.INFORMATION_SCHEMA.TASK_HISTORY(
        SCHEDULED_TIME_RANGE_START => DATEADD(hour, -24, CURRENT_TIMESTAMP())
    ))
    WHERE name LIKE '%DRILL%'
    ORDER BY scheduled_time DESC
    LIMIT 5
""")
for r in cur.fetchall():
    print(f"  {r[0]}: {r[1]} @ {r[2]}")
