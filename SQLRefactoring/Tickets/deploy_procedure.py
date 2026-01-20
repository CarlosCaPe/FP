"""
Deploy LH_LOADING_CYCLE_INCR_P procedure
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

# Read DDL file and find procedure
with open('LH_LOADING_CYCLE/refactor_ddl_v2.sql', 'r') as f:
    content = f.read()

# Extract procedure creation (between CREATE OR REPLACE PROCEDURE and final ';')
import re
proc_match = re.search(r"(CREATE OR REPLACE PROCEDURE DEV_API_REF\.FUSE\.LH_LOADING_CYCLE_INCR_P.*?';)", content, re.DOTALL)

if proc_match:
    proc_sql = proc_match.group(1)
    print("Creating LH_LOADING_CYCLE_INCR_P procedure...")
    cur.execute(proc_sql)
    print("Procedure created!")
    
    # Clear table and test procedure
    print("\nTruncating table and testing procedure...")
    cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
    
    cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')")
    result = cur.fetchone()
    print(f"Result: {result[0]}")
    
    # Verify
    cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
    print(f"\nLH_LOADING_CYCLE_INCR total: {cur.fetchone()[0]:,} rows")
else:
    print("Could not find procedure in DDL file!")

cur.close()
conn.close()
print("\nDone!")
