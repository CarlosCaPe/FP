"""
Check:
1. Are tasks running?
2. Were old _CT objects deleted?
"""
import snowflake.connector
from dotenv import load_dotenv
import os

load_dotenv('../tools/.env')

print("Connecting to Snowflake...")
conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)

cur = conn.cursor()
print("Connected!\n")

# Check all LH_BUCKET and LH_LOADING_CYCLE objects
print("=" * 80)
print("ALL OBJECTS IN DEV_API_REF.FUSE (LH_BUCKET% and LH_LOADING_CYCLE%)")
print("=" * 80)
cur.execute("""
    SHOW OBJECTS IN SCHEMA DEV_API_REF.FUSE
""")
objects = cur.fetchall()
for obj in objects:
    name = obj[1]
    kind = obj[3]
    if 'LH_BUCKET' in name or 'LH_LOADING_CYCLE' in name:
        print(f"  {kind:<12} | {name}")

# Check task status
print("\n" + "=" * 80)
print("TASK STATUS")
print("=" * 80)
cur.execute("""
    SHOW TASKS IN SCHEMA DEV_API_REF.FUSE
""")
tasks = cur.fetchall()
for task in tasks:
    name = task[1]
    state = task[9]  # state column
    schedule = task[6]  # schedule column
    if 'LH_BUCKET' in name or 'LH_LOADING_CYCLE' in name:
        status = "✅ Running" if state == 'started' else f"❌ {state}"
        print(f"  {name:<35} | State: {status:<15} | Schedule: {schedule}")

# Check last execution via DW_MODIFY_TS
print("\n" + "=" * 80)
print("LAST DATA UPDATE (via DW_MODIFY_TS)")
print("=" * 80)

# INCR tables
try:
    cur.execute("SELECT MAX(dw_modify_ts), COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_INCR")
    row = cur.fetchone()
    print(f"  LH_BUCKET_INCR:        Last update: {row[0]} | Rows: {row[1]:,}")
except Exception as e:
    print(f"  LH_BUCKET_INCR:        Not found or error: {e}")

try:
    cur.execute("SELECT MAX(dw_modify_ts), COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
    row = cur.fetchone()
    print(f"  LH_LOADING_CYCLE_INCR: Last update: {row[0]} | Rows: {row[1]:,}")
except Exception as e:
    print(f"  LH_LOADING_CYCLE_INCR: Not found or error: {e}")

# CT tables (old)
try:
    cur.execute("SELECT MAX(dw_modify_ts), COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_CT")
    row = cur.fetchone()
    print(f"  LH_BUCKET_CT (OLD):    Last update: {row[0]} | Rows: {row[1]:,}")
except Exception as e:
    print(f"  LH_BUCKET_CT (OLD):    ✅ Does not exist (dropped)")

try:
    cur.execute("SELECT MAX(dw_modify_ts), COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT")
    row = cur.fetchone()
    print(f"  LH_LOADING_CYCLE_CT (OLD): Last update: {row[0]} | Rows: {row[1]:,}")
except Exception as e:
    print(f"  LH_LOADING_CYCLE_CT (OLD): ✅ Does not exist (dropped)")

# Check task history
print("\n" + "=" * 80)
print("RECENT TASK EXECUTIONS (last 24 hours)")
print("=" * 80)
cur.execute("""
    SELECT 
        name,
        state,
        scheduled_time,
        completed_time,
        error_message
    FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
        SCHEDULED_TIME_RANGE_START => DATEADD('hour', -24, CURRENT_TIMESTAMP()),
        RESULT_LIMIT => 20
    ))
    WHERE name LIKE '%LH_BUCKET%' OR name LIKE '%LH_LOADING_CYCLE%'
    ORDER BY scheduled_time DESC
""")
history = cur.fetchall()
if history:
    for h in history:
        name, state, scheduled, completed, error = h
        status = "✅" if state == 'SUCCEEDED' else f"❌ {state}"
        print(f"  {name:<35} | {status} | {scheduled}")
        if error:
            print(f"    Error: {error}")
else:
    print("  No task executions found in last 24 hours")

cur.close()
conn.close()
print("\nDone!")
