"""Check BLAST_PLAN_EXECUTION_INCR_P result"""
import snowflake.connector
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
print("Calling BLAST_PLAN_EXECUTION_INCR_P...")
cursor.execute("CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P('3');")
result = cursor.fetchone()[0]
print(f"Result: {result}")
cursor.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR")
count = cursor.fetchone()[0]
print(f"Row count: {count}")
cursor.close()
conn.close()
