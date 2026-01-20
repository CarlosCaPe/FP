"""
Quick stress test for both pipelines (1, 3, 7 days only)
"""
import snowflake.connector
from dotenv import load_dotenv
import os
import time
import re

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

# Test LH_LOADING_CYCLE_INCR
print("=" * 60)
print("STRESS TEST: LH_LOADING_CYCLE_INCR_P")
print("=" * 60)
print(f"{'Days':>6} | {'Time (s)':>10} | {'Rows':>12}")
print("-" * 40)

lc_results = []
for days in [1, 3, 7]:
    cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
    start = time.time()
    cur.execute(f"CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('{days}')")
    elapsed = time.time() - start
    cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
    count = cur.fetchone()[0]
    print(f"{days:>6} | {elapsed:>10.2f} | {count:>12,}")
    lc_results.append((days, elapsed, count))

# Test LH_BUCKET_INCR
print("\n" + "=" * 60)
print("STRESS TEST: LH_BUCKET_INCR_P")
print("=" * 60)
print(f"{'Days':>6} | {'Time (s)':>10} | {'Rows':>12}")
print("-" * 40)

bucket_results = []
for days in [1, 3, 7]:
    cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_BUCKET_INCR")
    start = time.time()
    cur.execute(f"CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('{days}')")
    elapsed = time.time() - start
    cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_INCR")
    count = cur.fetchone()[0]
    print(f"{days:>6} | {elapsed:>10.2f} | {count:>12,}")
    bucket_results.append((days, elapsed, count))

# Reset to 3 days
print("\n" + "=" * 60)
print("FINAL STATUS (3-day window)")
print("=" * 60)

cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')")
cur.execute("SELECT COUNT(*), MAX(DW_MODIFY_TS) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
lc = cur.fetchone()
print(f"LH_LOADING_CYCLE_INCR: {lc[0]:,} rows, last modified: {lc[1]}")

cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_BUCKET_INCR")
cur.execute("CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('3')")
cur.execute("SELECT COUNT(*), MAX(DW_MODIFY_TS) FROM DEV_API_REF.FUSE.LH_BUCKET_INCR")
bucket = cur.fetchone()
print(f"LH_BUCKET_INCR: {bucket[0]:,} rows, last modified: {bucket[1]}")

cur.close()
conn.close()
print("\nDone!")
