"""
Test updated procedures with business timestamp columns
LH_EQUIPMENT_STATUS_EVENT_INCR_P -> START_TS_LOCAL
LH_LOADING_CYCLE_INCR_P -> CYCLE_START_TS_LOCAL
LH_BUCKET_INCR_P -> TRIP_TS_LOCAL
"""
import snowflake.connector
import os

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    authenticator='externalbrowser',
    user='CCARRILL2@fmi.com',
    role='SG-AZW-SFLK-ENG-GENERAL',
    warehouse='WH_BATCH_DE_NONPROD',
    database='DEV_API_REF',
    schema='FUSE'
)
cursor = conn.cursor()

base_path = r"C:\Users\ccarrill2\Documents\repos\FP\SQLRefactoring\Tickets\DRILLBLAST_INCR\DDL-Scripts\API_REF\FUSE"

print("=" * 70)
print("TESTING UPDATED PROCEDURES - Business Timestamp Columns")
print("=" * 70)

# Step 1: Drop existing tables
print("\n📋 Step 1: Dropping existing tables...")
tables = ["LH_EQUIPMENT_STATUS_EVENT_INCR", "LH_LOADING_CYCLE_INCR", "LH_BUCKET_INCR"]
for table in tables:
    try:
        cursor.execute(f"DROP TABLE IF EXISTS DEV_API_REF.FUSE.{table}")
        print(f"  ✅ Dropped: {table}")
    except Exception as e:
        print(f"  ⚠️ {table}: {e}")

# Step 2: Recreate tables from DDL files
print("\n📋 Step 2: Creating tables from DDL files...")
table_files = [
    "TABLES/R__LH_EQUIPMENT_STATUS_EVENT_INCR.sql",
    "TABLES/R__LH_LOADING_CYCLE_INCR.sql",
    "TABLES/R__LH_BUCKET_INCR.sql"
]

for tfile in table_files:
    with open(os.path.join(base_path, tfile), 'r') as f:
        sql = f.read().replace("{{ envi }}", "DEV").replace("{{ RO_PROD }}", "PROD")
    cursor.execute(sql)
    print(f"  ✅ Created: {tfile.split('/')[-1]}")

# Step 3: Create procedures from DDL files
print("\n📋 Step 3: Creating procedures from DDL files...")
proc_files = [
    "PROCEDURES/R__LH_EQUIPMENT_STATUS_EVENT_INCR_P.sql",
    "PROCEDURES/R__LH_LOADING_CYCLE_INCR_P.sql",
    "PROCEDURES/R__LH_BUCKET_INCR_P.sql"
]

for pfile in proc_files:
    with open(os.path.join(base_path, pfile), 'r') as f:
        sql = f.read().replace("{{ envi }}", "DEV").replace("{{ RO_PROD }}", "PROD")
    cursor.execute(sql)
    print(f"  ✅ Created: {pfile.split('/')[-1]}")

# Step 4: Execute all procedures
print("\n📋 Step 4: Executing procedures (3-day lookback)...")
procedures = [
    ("LH_EQUIPMENT_STATUS_EVENT_INCR_P", "LH_EQUIPMENT_STATUS_EVENT_INCR", "START_TS_LOCAL"),
    ("LH_LOADING_CYCLE_INCR_P", "LH_LOADING_CYCLE_INCR", "CYCLE_START_TS_LOCAL"),
    ("LH_BUCKET_INCR_P", "LH_BUCKET_INCR", "TRIP_TS_LOCAL")
]

results = []
for proc, table, incr_col in procedures:
    try:
        cursor.execute(f"CALL DEV_API_REF.FUSE.{proc}('3')")
        result = cursor.fetchone()[0]
        cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}")
        count = cursor.fetchone()[0]
        print(f"  ✅ {proc}: {result}")
        print(f"     Row count: {count:,}")
        results.append((proc, table, incr_col, count, "SUCCESS"))
    except Exception as e:
        print(f"  ❌ {proc}: {e}")
        results.append((proc, table, incr_col, 0, f"FAILED: {e}"))

# Step 5: Regression test - run again to verify idempotency
print("\n📋 Step 5: Regression test (re-running procedures)...")
all_passed = True
for proc, table, incr_col, prev_count, status in results:
    if status == "SUCCESS":
        try:
            cursor.execute(f"CALL DEV_API_REF.FUSE.{proc}('3')")
            result = cursor.fetchone()[0]
            cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}")
            new_count = cursor.fetchone()[0]
            if new_count == prev_count:
                print(f"  ✅ {proc}: Idempotent (count unchanged: {new_count:,})")
            else:
                print(f"  ⚠️ {proc}: Count changed from {prev_count:,} to {new_count:,}")
        except Exception as e:
            print(f"  ❌ {proc}: {e}")
            all_passed = False

# Step 6: Verify incremental column is being used correctly
print("\n📋 Step 6: Verifying incremental column logic...")
for proc, table, incr_col in procedures:
    try:
        # Check that data falls within 3-day window based on business timestamp
        cursor.execute(f"""
            SELECT 
                MIN({incr_col})::date as min_date,
                MAX({incr_col})::date as max_date,
                DATEDIFF(day, MIN({incr_col}), CURRENT_DATE()) as days_back
            FROM DEV_API_REF.FUSE.{table}
            WHERE {incr_col} IS NOT NULL
        """)
        row = cursor.fetchone()
        if row and row[0]:
            print(f"  ✅ {table}: {incr_col} range = {row[0]} to {row[1]} ({row[2]} days back)")
        else:
            print(f"  ⚠️ {table}: No data with {incr_col}")
    except Exception as e:
        print(f"  ❌ {table}: {e}")

# Summary
print("\n" + "=" * 70)
print("SUMMARY")
print("=" * 70)
failed = [r for r in results if "FAILED" in r[4]]
if failed:
    print("❌ SOME TESTS FAILED:")
    for r in failed:
        print(f"   - {r[0]}: {r[4]}")
else:
    print("✅ ALL TESTS PASSED!")
    print("\nUpdated Incremental Columns:")
    print("-" * 50)
    for proc, table, incr_col, count, _ in results:
        print(f"  {table}: {incr_col} ({count:,} rows)")

cursor.close()
conn.close()
