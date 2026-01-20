"""
Deploy LH_LOADING_CYCLE_INCR table, procedure, and task to DEV_API_REF.FUSE
Source: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE (VIEW)
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

# Read the DDL file
with open('LH_LOADING_CYCLE/refactor_ddl_v2.sql', 'r') as f:
    ddl_content = f.read()

# Split into statements and execute
statements = ddl_content.split(';')

for stmt in statements:
    stmt = stmt.strip()
    # Skip empty statements and comments-only
    if not stmt or stmt.startswith('--'):
        continue
    # Skip commented out statements
    if stmt.startswith('-- '):
        continue
    # Only execute CREATE statements (table, procedure, task)
    if any(keyword in stmt.upper() for keyword in ['CREATE OR REPLACE TABLE', 'CREATE OR REPLACE PROCEDURE', 'CREATE OR REPLACE TASK']):
        print(f"\n{'='*60}")
        print(f"Executing: {stmt[:80]}...")
        try:
            cur.execute(stmt)
            print("SUCCESS")
        except Exception as e:
            print(f"ERROR: {e}")

# Test the procedure with 3 days
print(f"\n{'='*60}")
print("Testing LH_LOADING_CYCLE_INCR_P('3')...")
try:
    cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')")
    result = cur.fetchone()
    print(f"Result: {result[0]}")
except Exception as e:
    print(f"ERROR: {e}")

# Verify row count
print(f"\n{'='*60}")
print("Verifying row counts...")
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
print(f"LH_LOADING_CYCLE_INCR: {cur.fetchone()[0]:,} rows")

cur.execute("""
    SELECT COUNT(*) FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE 
    WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE())
""")
print(f"Source (last 3 days): {cur.fetchone()[0]:,} rows")

cur.close()
conn.close()
print("\nDone!")
