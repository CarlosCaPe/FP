"""Check BLAST_PLAN columns"""
import snowflake.connector

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='PROD_WG',
    schema='DRILL_BLAST',
    role='SG-AZW-SFLK-ENG-GENERAL'
)
cursor = conn.cursor()

cursor.execute("""
    SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'DRILL_BLAST' 
    AND TABLE_NAME = 'BLAST_PLAN'
    ORDER BY ORDINAL_POSITION
""")
cols = [r[0] for r in cursor.fetchall()]
print("BLAST_PLAN columns:")
for c in cols:
    print(f"  {c}")

conn.close()
