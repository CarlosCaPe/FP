"""
Test LH_LOADING_CYCLE_INCR_P procedure
"""
import snowflake.connector
from dotenv import load_dotenv
import os

load_dotenv('../tools/.env')

conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)

cur = conn.cursor()

print("Calling LH_LOADING_CYCLE_INCR_P('3')...")
try:
    cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')")
    result = cur.fetchone()
    print(f"Result: {result[0]}")
except Exception as e:
    print(f"Error: {e}")

# Verify
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
print(f"\nLH_LOADING_CYCLE_INCR total: {cur.fetchone()[0]:,} rows")

cur.close()
conn.close()
