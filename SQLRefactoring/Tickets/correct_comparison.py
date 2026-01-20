"""
CORRECT COMPARISON:
- OLD (current): PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE 
- NEW (proposed): PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V
"""
import snowflake.connector
from dotenv import load_dotenv
import os
import time

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

print("=" * 80)
print("COMPARISON: OLD vs NEW SOURCE")
print("=" * 80)
print("\nOLD (current):  PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
print("NEW (proposed): PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V")
print()

# Test 1: COUNT with 3-day filter
print("-" * 80)
print("TEST 1: SELECT COUNT(*) with 3-day filter")
print("-" * 80)

# OLD source
start = time.time()
cur.execute("""
    SELECT COUNT(*) 
    FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
    WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
""")
old_time = time.time() - start
old_count = cur.fetchone()[0]
print(f"OLD (LH_LOADING_CYCLE):   {old_time:.2f}s | {old_count:,} rows")

# NEW source
start = time.time()
cur.execute("""
    SELECT COUNT(*) 
    FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V
    WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
""")
new_time = time.time() - start
new_count = cur.fetchone()[0]
print(f"NEW (LH_LOADING_CYCLE_V): {new_time:.2f}s | {new_count:,} rows")

if new_time > old_time:
    print(f"\n⚠️  NEW is {new_time/old_time:.1f}x SLOWER than OLD")
else:
    print(f"\n✅ NEW is {old_time/new_time:.1f}x FASTER than OLD")

# Test 2: Full SELECT
print("\n" + "-" * 80)
print("TEST 2: SELECT * with 3-day filter (first 10k rows)")
print("-" * 80)

# OLD source
start = time.time()
cur.execute("""
    SELECT * 
    FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
    WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
    LIMIT 10000
""")
_ = cur.fetchall()
old_time2 = time.time() - start
print(f"OLD (LH_LOADING_CYCLE):   {old_time2:.2f}s")

# NEW source
start = time.time()
cur.execute("""
    SELECT * 
    FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V
    WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
    LIMIT 10000
""")
_ = cur.fetchall()
new_time2 = time.time() - start
print(f"NEW (LH_LOADING_CYCLE_V): {new_time2:.2f}s")

if new_time2 > old_time2:
    print(f"\n⚠️  NEW is {new_time2/old_time2:.1f}x SLOWER than OLD")
else:
    print(f"\n✅ NEW is {old_time2/new_time2:.1f}x FASTER than OLD")

# Test 3: Multiple runs for average
print("\n" + "-" * 80)
print("TEST 3: Multiple runs (5 iterations) - COUNT(*)")
print("-" * 80)

old_times = []
new_times = []

for i in range(5):
    # OLD
    start = time.time()
    cur.execute("""
        SELECT COUNT(*) 
        FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
        WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
    """)
    cur.fetchone()
    old_times.append(time.time() - start)
    
    # NEW
    start = time.time()
    cur.execute("""
        SELECT COUNT(*) 
        FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V
        WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
    """)
    cur.fetchone()
    new_times.append(time.time() - start)
    
    print(f"Run {i+1}: OLD={old_times[-1]:.2f}s, NEW={new_times[-1]:.2f}s")

avg_old = sum(old_times) / len(old_times)
avg_new = sum(new_times) / len(new_times)

print(f"\nAVERAGE: OLD={avg_old:.2f}s, NEW={avg_new:.2f}s")

# Check column differences
print("\n" + "=" * 80)
print("COLUMN DIFFERENCES")
print("=" * 80)

cur.execute("DESCRIBE VIEW PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
old_cols = set(row[0] for row in cur.fetchall())

cur.execute("DESCRIBE VIEW PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V")
new_cols = set(row[0] for row in cur.fetchall())

print("\nColumns ONLY in NEW (LH_LOADING_CYCLE_V):")
for col in sorted(new_cols - old_cols):
    print(f"  + {col}")

print("\nColumns ONLY in OLD (LH_LOADING_CYCLE):")
for col in sorted(old_cols - new_cols):
    print(f"  - {col}")

# Summary
print("\n" + "=" * 80)
print("SUMMARY")
print("=" * 80)
print(f"""
{'Source':<40} | {'Avg Time':>10} | {'Difference':>15}
{'-'*70}
{'OLD: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE':<40} | {avg_old:>10.2f}s | {'baseline':>15}
{'NEW: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V':<40} | {avg_new:>10.2f}s | {f'{avg_new/avg_old:.1f}x slower' if avg_new > avg_old else f'{avg_old/avg_new:.1f}x faster':>15}
""")

print("""
KEY FINDING:
The NEW view (LH_LOADING_CYCLE_V) performs a LEFT JOIN with LH_BUCKET_C 
to calculate loading_cycle_dig_elev_avg_feet/meters on the fly.

This JOIN causes the performance overhead.
""")

cur.close()
conn.close()
print("Done!")
