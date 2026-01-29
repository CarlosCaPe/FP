"""
Fix and Redeploy - BLAST_PLAN_INCR_P, DRILL_CYCLE_INCR_P, DRILL_PLAN_INCR_P
Also fix BLAST_PLAN_EXECUTION_INCR table
"""
import snowflake.connector
from pathlib import Path
from datetime import datetime

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='DEV_API_REF',
    schema='FUSE',
    role='SG-AZW-SFLK-ENG-GENERAL'
)
cursor = conn.cursor()

print("=" * 70)
print("FIX AND REDEPLOY")
print("=" * 70)
print(f"Time: {datetime.now().isoformat()}")

base = Path(__file__).parent / "DEPLOY_DEV"

# Redeploy fixed procedures
procs = [
    "R__BLAST_PLAN_INCR_P.sql",
    "R__DRILL_CYCLE_INCR_P.sql", 
    "R__DRILL_PLAN_INCR_P.sql",
]

print("\n📋 Redeploying fixed procedures...")
for proc in procs:
    path = base / "PROCEDURES" / proc
    sql = path.read_text(encoding="utf-8")
    try:
        cursor.execute(sql)
        print(f"  ✅ {proc}")
    except Exception as e:
        print(f"  ❌ {proc}: {e}")

# Test all 3
print("\n📋 Testing fixed procedures...")
test_procs = ['BLAST_PLAN_INCR_P', 'DRILL_CYCLE_INCR_P', 'DRILL_PLAN_INCR_P']
for proc in test_procs:
    try:
        cursor.execute(f"CALL DEV_API_REF.FUSE.{proc}('3');")
        result = cursor.fetchone()[0]
        print(f"  ✅ {proc}: {result}")
    except Exception as e:
        print(f"  ❌ {proc}: {str(e)[:80]}")

# Test BLAST_PLAN_EXECUTION
print("\n📋 Testing BLAST_PLAN_EXECUTION_INCR_P...")
try:
    cursor.execute("CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P('3');")
    result = cursor.fetchone()[0]
    print(f"  ✅ BLAST_PLAN_EXECUTION_INCR_P: {result}")
except Exception as e:
    print(f"  ❌ BLAST_PLAN_EXECUTION_INCR_P: {str(e)[:100]}")

cursor.close()
conn.close()
print("\n✅ Done!")
