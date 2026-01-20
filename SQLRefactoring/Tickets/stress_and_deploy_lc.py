"""
Stress test and deploy task for LH_LOADING_CYCLE_INCR
"""
import snowflake.connector
from dotenv import load_dotenv
import os
import time

load_dotenv('../tools/.env')

conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)

cur = conn.cursor()

# First truncate and reload properly
print("Resetting table...")
cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")

# Stress test with different day ranges
print("\n=== STRESS TEST LH_LOADING_CYCLE_INCR_P ===")
print(f"{'Days':>6} | {'Time (s)':>10} | {'Merged':>12} | Result")
print("-" * 60)

for days in [1, 3, 7, 14, 30, 60, 90]:
    # First truncate
    cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
    
    start = time.time()
    cur.execute(f"CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('{days}')")
    elapsed = time.time() - start
    result = cur.fetchone()[0]
    
    # Extract merged count
    import re
    match = re.search(r'merged records into INCR table: (\d+)', result)
    merged = match.group(1) if match else "?"
    
    print(f"{days:>6} | {elapsed:>10.2f} | {merged:>12} | OK")

# Final row count
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
print(f"\nFinal row count: {cur.fetchone()[0]:,}")

# Reset to 3 days for normal operation
print("\n=== RESETTING TO 3-DAY WINDOW ===")
cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')")
result = cur.fetchone()[0]
print(f"Result: {result}")

cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
print(f"Row count: {cur.fetchone()[0]:,}")

# Create task
print("\n=== CREATING TASK ===")
cur.execute("""
CREATE OR REPLACE TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_T
    WAREHOUSE = 'WH_BATCH_DE_NONPROD'
    SCHEDULE = 'USING CRON */15 * * * * UTC'
    COMMENT = 'Refresh LH_LOADING_CYCLE_INCR every 15 minutes with 3-day lookback'
AS
    CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')
""")
print("Task created!")

# Enable task
print("Enabling task...")
cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_T RESUME")
print("Task enabled!")

# Show task status
cur.execute("SHOW TASKS LIKE 'LH_LOADING_CYCLE_INCR_T' IN DEV_API_REF.FUSE")
task = cur.fetchone()
print(f"\nTask state: {task[9]}")  # state column

cur.close()
conn.close()
print("\nDone!")
