"""Fix and test BLAST_PLAN_EXECUTION_INCR - dedicated script"""
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
print("STEP 1: Check current table definition")
print("=" * 70)
cur.execute("""
SELECT COLUMN_NAME, IS_NULLABLE 
FROM DEV_API_REF.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'FUSE' 
AND TABLE_NAME = 'BLAST_PLAN_EXECUTION_INCR'
AND COLUMN_NAME IN ('ORIG_SRC_ID', 'SITE_CODE', 'BENCH', 'PUSHBACK', 'PATTERN_NAME', 'BLAST_NAME', 'DRILLED_HOLE_ID')
ORDER BY ORDINAL_POSITION
""")
print("Current nullability (before fix):")
for row in cur.fetchall():
    print(f"  {row[0]}: {'nullable' if row[1] == 'YES' else 'NOT NULL'}")

print("\n" + "=" * 70)
print("STEP 2: Drop and recreate table with nullable columns")
print("=" * 70)
table_path = deploy_dev / "TABLES" / "R__BLAST_PLAN_EXECUTION_INCR.sql"
sql = table_path.read_text(encoding="utf-8")
try:
    cur.execute(sql)
    print("✅ Table recreated successfully")
except Exception as e:
    print(f"❌ Error recreating table: {e}")

print("\n" + "=" * 70)
print("STEP 3: Verify new table definition")
print("=" * 70)
cur.execute("""
SELECT COLUMN_NAME, IS_NULLABLE 
FROM DEV_API_REF.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'FUSE' 
AND TABLE_NAME = 'BLAST_PLAN_EXECUTION_INCR'
AND COLUMN_NAME IN ('ORIG_SRC_ID', 'SITE_CODE', 'BENCH', 'PUSHBACK', 'PATTERN_NAME', 'BLAST_NAME', 'DRILLED_HOLE_ID')
ORDER BY ORDINAL_POSITION
""")
print("New nullability (after fix):")
for row in cur.fetchall():
    print(f"  {row[0]}: {'nullable' if row[1] == 'YES' else 'NOT NULL'}")

print("\n" + "=" * 70)
print("STEP 4: Check source for NULL values")
print("=" * 70)
cur.execute("""
SELECT 
    SUM(CASE WHEN BENCH IS NULL THEN 1 ELSE 0 END) AS null_bench,
    SUM(CASE WHEN PUSHBACK IS NULL THEN 1 ELSE 0 END) AS null_pushback,
    SUM(CASE WHEN PATTERN_NAME IS NULL THEN 1 ELSE 0 END) AS null_pattern,
    SUM(CASE WHEN BLAST_NAME IS NULL THEN 1 ELSE 0 END) AS null_blast,
    COUNT(*) AS total
FROM PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION
WHERE DW_MODIFY_TS >= DATEADD(day, -7, CURRENT_TIMESTAMP())
""")
row = cur.fetchone()
print(f"  In last 7 days ({row[4]} total rows):")
print(f"    NULL BENCH:        {row[0]}")
print(f"    NULL PUSHBACK:     {row[1]}")
print(f"    NULL PATTERN_NAME: {row[2]}")
print(f"    NULL BLAST_NAME:   {row[3]}")

print("\n" + "=" * 70)
print("STEP 5: Test procedure")
print("=" * 70)
try:
    cur.execute("CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P(7)")
    result = cur.fetchone()[0]
    print(f"✅ SUCCESS: {result}")
except Exception as e:
    print(f"❌ ERROR: {e}")

cur.close()
conn.close()
