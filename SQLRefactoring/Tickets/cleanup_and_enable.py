"""
1. Enable INCR tasks
2. Suspend CT tasks
3. Drop old CT objects
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

# 1. Suspend old CT tasks
print("=" * 80)
print("STEP 1: Suspending old CT tasks...")
print("=" * 80)
try:
    cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_BUCKET_CT_T SUSPEND")
    print("  ✅ LH_BUCKET_CT_T suspended")
except Exception as e:
    print(f"  ⚠️ LH_BUCKET_CT_T: {e}")

try:
    cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_T SUSPEND")
    print("  ✅ LH_LOADING_CYCLE_CT_T suspended")
except Exception as e:
    print(f"  ⚠️ LH_LOADING_CYCLE_CT_T: {e}")

# 2. Enable INCR tasks
print("\n" + "=" * 80)
print("STEP 2: Enabling INCR tasks...")
print("=" * 80)
try:
    cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_BUCKET_INCR_T RESUME")
    print("  ✅ LH_BUCKET_INCR_T resumed")
except Exception as e:
    print(f"  ⚠️ LH_BUCKET_INCR_T: {e}")

try:
    cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_T RESUME")
    print("  ✅ LH_LOADING_CYCLE_INCR_T resumed")
except Exception as e:
    print(f"  ⚠️ LH_LOADING_CYCLE_INCR_T: {e}")

# 3. Drop old CT objects
print("\n" + "=" * 80)
print("STEP 3: Dropping old CT objects...")
print("=" * 80)

# First drop tasks
try:
    cur.execute("DROP TASK IF EXISTS DEV_API_REF.FUSE.LH_BUCKET_CT_T")
    print("  ✅ Dropped LH_BUCKET_CT_T")
except Exception as e:
    print(f"  ⚠️ LH_BUCKET_CT_T: {e}")

try:
    cur.execute("DROP TASK IF EXISTS DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_T")
    print("  ✅ Dropped LH_LOADING_CYCLE_CT_T")
except Exception as e:
    print(f"  ⚠️ LH_LOADING_CYCLE_CT_T: {e}")

# Then drop procedures
try:
    cur.execute("DROP PROCEDURE IF EXISTS DEV_API_REF.FUSE.LH_BUCKET_CT_P(VARCHAR)")
    print("  ✅ Dropped LH_BUCKET_CT_P")
except Exception as e:
    print(f"  ⚠️ LH_BUCKET_CT_P: {e}")

try:
    cur.execute("DROP PROCEDURE IF EXISTS DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_P(VARCHAR)")
    print("  ✅ Dropped LH_LOADING_CYCLE_CT_P")
except Exception as e:
    print(f"  ⚠️ LH_LOADING_CYCLE_CT_P: {e}")

# Finally drop tables
try:
    cur.execute("DROP TABLE IF EXISTS DEV_API_REF.FUSE.LH_BUCKET_CT")
    print("  ✅ Dropped LH_BUCKET_CT")
except Exception as e:
    print(f"  ⚠️ LH_BUCKET_CT: {e}")

try:
    cur.execute("DROP TABLE IF EXISTS DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT")
    print("  ✅ Dropped LH_LOADING_CYCLE_CT")
except Exception as e:
    print(f"  ⚠️ LH_LOADING_CYCLE_CT: {e}")

# Verify final state
print("\n" + "=" * 80)
print("FINAL VERIFICATION")
print("=" * 80)

# Check remaining objects
cur.execute("SHOW OBJECTS IN SCHEMA DEV_API_REF.FUSE")
objects = cur.fetchall()
print("\nRemaining LH objects:")
for obj in objects:
    name = obj[1]
    kind = obj[3]
    if 'LH_BUCKET' in name or 'LH_LOADING_CYCLE' in name:
        print(f"  {kind:<12} | {name}")

# Check task status
cur.execute("SHOW TASKS IN SCHEMA DEV_API_REF.FUSE")
tasks = cur.fetchall()
print("\nTask Status:")
for task in tasks:
    name = task[1]
    state = task[9]
    if 'LH_BUCKET' in name or 'LH_LOADING_CYCLE' in name:
        status = "✅ Running" if state == 'started' else f"❌ {state}"
        print(f"  {name:<35} | {status}")

cur.close()
conn.close()
print("\nDone!")
