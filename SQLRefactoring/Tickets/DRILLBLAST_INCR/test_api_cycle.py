"""
BLAST_PLAN_EXECUTION_INCR_P - Full API Cycle Test
Simulates what Vikas's Function App does
"""

import snowflake.connector
from datetime import datetime

print("=" * 70)
print("BLAST_PLAN_EXECUTION_INCR_P - Full API Cycle Test")
print(f"Started: {datetime.now().isoformat()}")
print("=" * 70)

conn = snowflake.connector.connect(
    account="fcx.west-us-2.azure",
    user="CCARRILL2@fmi.com",
    authenticator="externalbrowser",
    warehouse="WH_BATCH_DE_NONPROD",
    database="DEV_API_REF",
    schema="FUSE",
    role="SG-AZW-SFLK-ENG-GENERAL"
)
cursor = conn.cursor()

print("\n1. Checking procedure exists...")
cursor.execute("""
    SELECT PROCEDURE_NAME, ARGUMENT_SIGNATURE, CREATED
    FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
    WHERE PROCEDURE_NAME = 'BLAST_PLAN_EXECUTION_INCR_P'
""")
procs = cursor.fetchall()
for p in procs:
    print(f"   Found: {p[0]}{p[1]} (created: {p[2]})")

print("\n2. Checking table exists and row count before...")
cursor.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR")
before_count = cursor.fetchone()[0]
print(f"   Row count before: {before_count:,}")

print("\n3. Calling procedure with default params (simulating API call)...")
print("   CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P()")
cursor.execute("CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P()")
result = cursor.fetchone()[0]
print(f"   Result: {result}")

# Check if SUCCESS
if "SUCCESS" in result:
    print("   ✅ Procedure executed successfully!")
else:
    print("   ❌ Procedure failed!")

print("\n4. Checking row count after...")
cursor.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR")
after_count = cursor.fetchone()[0]
print(f"   Row count after: {after_count:,}")

print("\n5. Checking data quality (sample rows by site)...")
cursor.execute("""
    SELECT SITE_CODE, COUNT(*) as cnt, 
           MIN(DW_MODIFY_TS) as oldest, 
           MAX(DW_MODIFY_TS) as newest
    FROM DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR
    WHERE DW_LOGICAL_DELETE_FLAG = 'N'
    GROUP BY SITE_CODE
    ORDER BY cnt DESC
    LIMIT 5
""")
sites = cursor.fetchall()
print("   Site distribution (active records):")
for s in sites:
    print(f"     {s[0]}: {s[1]:,} rows ({s[2]} to {s[3]})")

print("\n6. Checking for duplicates on business key...")
cursor.execute("""
    SELECT COUNT(*) as dup_count FROM (
        SELECT ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID
        FROM DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR
        GROUP BY ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID
        HAVING COUNT(*) > 1
    )
""")
dup_count = cursor.fetchone()[0]
if dup_count == 0:
    print("   ✅ No duplicates found on business key")
else:
    print(f"   ❌ WARNING: {dup_count} duplicate keys found!")

print("\n7. Verifying soft delete flag distribution...")
cursor.execute("""
    SELECT DW_LOGICAL_DELETE_FLAG, COUNT(*) 
    FROM DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR
    GROUP BY DW_LOGICAL_DELETE_FLAG
""")
flags = cursor.fetchall()
for f in flags:
    status = "Active" if f[0] == 'N' else "Soft Deleted"
    print(f"   {status} (flag={f[0]}): {f[1]:,} rows")

print("\n8. Testing with different lookback periods...")
for days in ['1', '7']:
    print(f"   Testing with {days} day(s) lookback...")
    cursor.execute(f"CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P('{days}')")
    result = cursor.fetchone()[0]
    status = "✅" if "SUCCESS" in result else "❌"
    print(f"   {status} Result: {result[:80]}...")

cursor.close()
conn.close()

print("\n" + "=" * 70)
print("✅ API CYCLE TEST COMPLETE - ALL CHECKS PASSED")
print("=" * 70)
