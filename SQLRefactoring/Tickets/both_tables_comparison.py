"""
Complete comparison for both tables:
- LH_LOADING_CYCLE: OLD vs NEW (LH_LOADING_CYCLE_V)
- LH_BUCKET: OLD vs NEW
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

results = {}

# ============================================================================
# LH_LOADING_CYCLE
# ============================================================================
print("=" * 80)
print("LH_LOADING_CYCLE COMPARISON")
print("=" * 80)
print("OLD: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
print("NEW: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V")
print()

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

avg_old_lc = sum(old_times) / len(old_times)
avg_new_lc = sum(new_times) / len(new_times)

print(f"OLD avg: {avg_old_lc:.2f}s")
print(f"NEW avg: {avg_new_lc:.2f}s")

if abs(avg_new_lc - avg_old_lc) < 0.5:
    print("✅ No significant difference")
    results['LH_LOADING_CYCLE'] = {'status': 'OK', 'old': avg_old_lc, 'new': avg_new_lc}
elif avg_new_lc > avg_old_lc:
    print(f"⚠️ NEW is {avg_new_lc/avg_old_lc:.1f}x slower")
    results['LH_LOADING_CYCLE'] = {'status': 'SLOWER', 'old': avg_old_lc, 'new': avg_new_lc}
else:
    print(f"✅ NEW is {avg_old_lc/avg_new_lc:.1f}x faster")
    results['LH_LOADING_CYCLE'] = {'status': 'FASTER', 'old': avg_old_lc, 'new': avg_new_lc}

# ============================================================================
# LH_BUCKET
# ============================================================================
print("\n" + "=" * 80)
print("LH_BUCKET COMPARISON")
print("=" * 80)
print("OLD: PROD_TARGET.COLLECTIONS.LH_BUCKET_C")
print("NEW: PROD_WG.LOAD_HAUL.LH_BUCKET")
print()

old_times = []
new_times = []

for i in range(5):
    # OLD (_C table)
    start = time.time()
    cur.execute("""
        SELECT COUNT(*) 
        FROM PROD_TARGET.COLLECTIONS.LH_BUCKET_C
        WHERE dig_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
        AND dw_logical_delete_flag = 'N'
    """)
    cur.fetchone()
    old_times.append(time.time() - start)
    
    # NEW (VIEW with UNION ALL)
    start = time.time()
    cur.execute("""
        SELECT COUNT(*) 
        FROM PROD_WG.LOAD_HAUL.LH_BUCKET
        WHERE dig_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
    """)
    cur.fetchone()
    new_times.append(time.time() - start)

avg_old_lb = sum(old_times) / len(old_times)
avg_new_lb = sum(new_times) / len(new_times)

print(f"OLD avg: {avg_old_lb:.2f}s")
print(f"NEW avg: {avg_new_lb:.2f}s")

if abs(avg_new_lb - avg_old_lb) < 0.5:
    print("✅ No significant difference")
    results['LH_BUCKET'] = {'status': 'OK', 'old': avg_old_lb, 'new': avg_new_lb}
elif avg_new_lb > avg_old_lb:
    print(f"⚠️ NEW is {avg_new_lb/avg_old_lb:.1f}x slower")
    results['LH_BUCKET'] = {'status': 'SLOWER', 'old': avg_old_lb, 'new': avg_new_lb}
else:
    print(f"✅ NEW is {avg_old_lb/avg_new_lb:.1f}x faster")
    results['LH_BUCKET'] = {'status': 'FASTER', 'old': avg_old_lb, 'new': avg_new_lb}

# ============================================================================
# ROW COUNT CHECK
# ============================================================================
print("\n" + "=" * 80)
print("ROW COUNT VERIFICATION (3-day window)")
print("=" * 80)

# LH_LOADING_CYCLE
cur.execute("""
    SELECT COUNT(*) FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
    WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
""")
old_count_lc = cur.fetchone()[0]

cur.execute("""
    SELECT COUNT(*) FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V
    WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
""")
new_count_lc = cur.fetchone()[0]

print(f"LH_LOADING_CYCLE: OLD={old_count_lc:,} | NEW={new_count_lc:,} | Match: {'✅' if old_count_lc == new_count_lc else '❌'}")

# LH_BUCKET
cur.execute("""
    SELECT COUNT(*) FROM PROD_TARGET.COLLECTIONS.LH_BUCKET_C
    WHERE dig_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
    AND dw_logical_delete_flag = 'N'
""")
old_count_lb = cur.fetchone()[0]

cur.execute("""
    SELECT COUNT(*) FROM PROD_WG.LOAD_HAUL.LH_BUCKET
    WHERE dig_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
""")
new_count_lb = cur.fetchone()[0]

print(f"LH_BUCKET:        OLD={old_count_lb:,} | NEW={new_count_lb:,} | Match: {'✅' if old_count_lb == new_count_lb else '⚠️ Different (expected - UNION adds Fleet data)'}")

# ============================================================================
# SUMMARY
# ============================================================================
print("\n" + "=" * 80)
print("FINAL SUMMARY")
print("=" * 80)
print(f"""
| Table             | OLD Source                          | NEW Source                              | OLD Time | NEW Time | Status |
|-------------------|-------------------------------------|----------------------------------------|----------|----------|--------|
| LH_LOADING_CYCLE  | PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE  | PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V | {avg_old_lc:.2f}s    | {avg_new_lc:.2f}s    | {results['LH_LOADING_CYCLE']['status']} |
| LH_BUCKET         | PROD_TARGET.COLLECTIONS.LH_BUCKET_C | PROD_WG.LOAD_HAUL.LH_BUCKET            | {avg_old_lb:.2f}s    | {avg_new_lb:.2f}s    | {results['LH_BUCKET']['status']} |
""")

cur.close()
conn.close()
print("Done!")
