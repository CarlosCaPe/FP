"""Check BENCH nullability in BLAST_PLAN_EXECUTION_INCR table"""
import snowflake.connector

conn = snowflake.connector.connect(
    user='ccarrill2@fmi.com',
    account='freeportproduction.east-us-2.azure',
    authenticator='externalbrowser',
    warehouse='COMPUTE_WH'
)
cur = conn.cursor()

print("=" * 60)
print("BLAST_PLAN_EXECUTION_INCR column nullability")
print("=" * 60)
cur.execute("""
SELECT COLUMN_NAME, IS_NULLABLE, DATA_TYPE 
FROM DEV_API_REF.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'FUSE' 
AND TABLE_NAME = 'BLAST_PLAN_EXECUTION_INCR'
ORDER BY ORDINAL_POSITION
""")
for row in cur.fetchall():
    nn = '' if row[1] == 'YES' else ' NOT NULL'
    print(f'{row[0]}: {row[2]}{nn}')

print("\n" + "=" * 60)
print("Source table - rows with NULL BENCH")
print("=" * 60)
cur.execute("""
SELECT COUNT(*) 
FROM PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION
WHERE BENCH IS NULL
AND DW_MODIFY_TS >= DATEADD(day, -7, CURRENT_TIMESTAMP())
""")
result = cur.fetchone()
print(f"Rows with NULL BENCH in last 7 days: {result[0]}")

cur.close()
conn.close()
