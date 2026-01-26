import snowflake.connector
import json

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
print('Testing BLAST_PLAN_EXECUTION_INCR_P with 3 days...')
cursor.execute("CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P('3');")
result = cursor.fetchone()
print(f"Result: {result[0] if result else 'No result'}")
cursor.close()
conn.close()
