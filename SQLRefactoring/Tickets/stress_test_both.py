"""
Stress test for both LH_LOADING_CYCLE_INCR and LH_BUCKET_INCR pipelines
"""
import snowflake.connector
from dotenv import load_dotenv
import os
import time
import re

load_dotenv('../tools/.env')

conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)

cur = conn.cursor()

def run_stress_test(table_name, proc_name, days_list=[1, 3, 7, 14, 30, 60, 90]):
    """Run stress test for a given procedure"""
    print(f"\n{'='*70}")
    print(f"STRESS TEST: {proc_name}")
    print(f"{'='*70}")
    print(f"{'Days':>6} | {'Time (s)':>10} | {'Merged':>12} | {'Total Rows':>12}")
    print("-" * 70)
    
    results = []
    for days in days_list:
        # Truncate table first
        cur.execute(f"TRUNCATE TABLE {table_name}")
        
        # Run procedure
        start = time.time()
        cur.execute(f"CALL {proc_name}('{days}')")
        elapsed = time.time() - start
        result = cur.fetchone()[0]
        
        # Extract merged count
        match = re.search(r'merged records into INCR table: (\d+)', result)
        merged = int(match.group(1)) if match else 0
        
        # Get total row count
        cur.execute(f"SELECT COUNT(*) FROM {table_name}")
        total = cur.fetchone()[0]
        
        print(f"{days:>6} | {elapsed:>10.2f} | {merged:>12,} | {total:>12,}")
        results.append({'days': days, 'time': elapsed, 'merged': merged, 'total': total})
    
    return results

# Run stress tests
print("\n" + "="*70)
print("RUNNING STRESS TESTS FOR BOTH PIPELINES")
print("="*70)

# Test LH_LOADING_CYCLE_INCR
lc_results = run_stress_test(
    'DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR',
    'DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P'
)

# Test LH_BUCKET_INCR
bucket_results = run_stress_test(
    'DEV_API_REF.FUSE.LH_BUCKET_INCR',
    'DEV_API_REF.FUSE.LH_BUCKET_INCR_P'
)

# Reset both to 3 days for normal operation
print("\n" + "="*70)
print("RESETTING BOTH TABLES TO 3-DAY WINDOW")
print("="*70)

cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')")
lc_result = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
lc_count = cur.fetchone()[0]
print(f"LH_LOADING_CYCLE_INCR: {lc_count:,} rows")

cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_BUCKET_INCR")
cur.execute("CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('3')")
bucket_result = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_INCR")
bucket_count = cur.fetchone()[0]
print(f"LH_BUCKET_INCR: {bucket_count:,} rows")

# Summary
print("\n" + "="*70)
print("SUMMARY")
print("="*70)
print("\nLH_LOADING_CYCLE_INCR_P:")
print(f"{'Days':>6} | {'Time (s)':>10} | {'Rows':>12}")
print("-" * 35)
for r in lc_results:
    print(f"{r['days']:>6} | {r['time']:>10.2f} | {r['total']:>12,}")

print("\nLH_BUCKET_INCR_P:")
print(f"{'Days':>6} | {'Time (s)':>10} | {'Rows':>12}")
print("-" * 35)
for r in bucket_results:
    print(f"{r['days']:>6} | {r['time']:>10.2f} | {r['total']:>12,}")

cur.close()
conn.close()
print("\nDone!")
