"""Deploy and test BLAST_PLAN_EXECUTION_INCR_P fix"""
import snowflake.connector
from pathlib import Path

deploy_dev = Path(__file__).parent / "DEPLOY_DEV"

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='DEV_API_REF',
    schema='FUSE',
    role='SG-AZW-SFLK-ENG-GENERAL'
)
cur = conn.cursor()

print("=" * 70)
print("Deploying fixed BLAST_PLAN_EXECUTION_INCR_P procedure")
print("=" * 70)
proc_path = deploy_dev / "PROCEDURES" / "R__BLAST_PLAN_EXECUTION_INCR_P.sql"
sql = proc_path.read_text(encoding="utf-8")
try:
    cur.execute(sql)
    print("✅ Procedure deployed successfully")
except Exception as e:
    print(f"❌ Error deploying: {e}")

print("\n" + "=" * 70)
print("Testing procedure")
print("=" * 70)
try:
    cur.execute("CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P(7)")
    result = cur.fetchone()[0]
    print(f"Result: {result}")
    if "ERROR" in result.upper():
        print("❌ Procedure returned an error")
    else:
        print("✅ SUCCESS!")
except Exception as e:
    print(f"❌ ERROR: {e}")

print("\n" + "=" * 70)
print("Checking row count")
print("=" * 70)
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR")
count = cur.fetchone()[0]
print(f"BLAST_PLAN_EXECUTION_INCR rows: {count:,}")

cur.close()
conn.close()
