"""
Benchmark: Compare performance between VIEW source vs TABLE (_C) source
Hypothesis: Views may have overhead compared to pre-computed _C tables
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

# ============================================================================
# TEST 1: Simple SELECT COUNT with date filter - compare sources
# ============================================================================
print("=" * 70)
print("TEST 1: Simple SELECT COUNT(*) with 3-day filter")
print("=" * 70)

queries = [
    # LH_LOADING_CYCLE - VIEW vs TABLE
    ("PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE (VIEW)", 
     "SELECT COUNT(*) FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)"),
    
    ("PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C (TABLE)", 
     "SELECT COUNT(*) FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE) AND dw_logical_delete_flag = 'N'"),
    
    # LH_BUCKET - VIEW vs TABLE
    ("PROD_WG.LOAD_HAUL.LH_BUCKET (VIEW)", 
     "SELECT COUNT(*) FROM PROD_WG.LOAD_HAUL.LH_BUCKET WHERE trip_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)"),
    
    ("PROD_TARGET.COLLECTIONS.LH_BUCKET_C (TABLE)", 
     "SELECT COUNT(*) FROM PROD_TARGET.COLLECTIONS.LH_BUCKET_C WHERE trip_ts_local::date >= DATEADD(day, -3, CURRENT_DATE) AND dw_logical_delete_flag = 'N'"),
]

print(f"\n{'Source':<55} | {'Time (s)':>10} | {'Rows':>12}")
print("-" * 85)

for name, query in queries:
    start = time.time()
    cur.execute(query)
    elapsed = time.time() - start
    count = cur.fetchone()[0]
    print(f"{name:<55} | {elapsed:>10.2f} | {count:>12,}")

# ============================================================================
# TEST 2: Full SELECT with all columns (simulating MERGE source)
# ============================================================================
print("\n" + "=" * 70)
print("TEST 2: Full SELECT with all columns (3-day filter)")
print("=" * 70)

queries2 = [
    # LH_LOADING_CYCLE
    ("LH_LOADING_CYCLE VIEW (all cols)", 
     """SELECT * FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE 
        WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)"""),
    
    ("LH_LOADING_CYCLE_C TABLE (all cols)", 
     """SELECT * FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C 
        WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE) 
        AND dw_logical_delete_flag = 'N'"""),
    
    # LH_BUCKET
    ("LH_BUCKET VIEW (all cols)", 
     """SELECT * FROM PROD_WG.LOAD_HAUL.LH_BUCKET 
        WHERE trip_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)"""),
    
    ("LH_BUCKET_C TABLE (all cols)", 
     """SELECT * FROM PROD_TARGET.COLLECTIONS.LH_BUCKET_C 
        WHERE trip_ts_local::date >= DATEADD(day, -3, CURRENT_DATE) 
        AND dw_logical_delete_flag = 'N'"""),
]

print(f"\n{'Source':<45} | {'Time (s)':>10} | {'Rows':>12}")
print("-" * 75)

for name, query in queries2:
    start = time.time()
    cur.execute(query)
    rows = cur.fetchall()
    elapsed = time.time() - start
    print(f"{name:<45} | {elapsed:>10.2f} | {len(rows):>12,}")

# ============================================================================
# TEST 3: Check what the VIEW actually does (view definition)
# ============================================================================
print("\n" + "=" * 70)
print("TEST 3: View Definitions - What's behind the views?")
print("=" * 70)

for view in ['PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE', 'PROD_WG.LOAD_HAUL.LH_BUCKET']:
    print(f"\n--- {view} ---")
    try:
        cur.execute(f"SELECT GET_DDL('VIEW', '{view}')")
        ddl = cur.fetchone()[0]
        # Show first 500 chars to understand structure
        print(ddl[:1000] + "..." if len(ddl) > 1000 else ddl)
    except Exception as e:
        print(f"Error: {e}")

cur.close()
conn.close()
print("\n\nDone!")
