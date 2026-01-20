"""
Create task for LH_BUCKET_INCR and show final status
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

# Create task
print("=== CREATING LH_BUCKET_INCR_T TASK ===")
cur.execute("""
CREATE OR REPLACE TASK DEV_API_REF.FUSE.LH_BUCKET_INCR_T
    WAREHOUSE = 'WH_BATCH_DE_NONPROD'
    SCHEDULE = 'USING CRON */15 * * * * UTC'
    COMMENT = 'Refresh LH_BUCKET_INCR every 15 minutes with 3-day lookback'
AS
    CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('3')
""")
print("Task created!")

# Enable task
cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_BUCKET_INCR_T RESUME")
print("Task enabled!")

# Show all INCR objects
print("\n=== FINAL STATUS ===")
print("\nTABLES:")
for table in ['LH_LOADING_CYCLE_INCR', 'LH_BUCKET_INCR']:
    try:
        cur.execute(f"SELECT COUNT(*), MAX(DW_MODIFY_TS) FROM DEV_API_REF.FUSE.{table}")
        row = cur.fetchone()
        print(f"  {table}: {row[0]:,} rows, last modified: {row[1]}")
    except Exception as e:
        print(f"  {table}: ERROR - {e}")

print("\nPROCEDURES:")
for proc in ['LH_LOADING_CYCLE_INCR_P', 'LH_BUCKET_INCR_P']:
    try:
        cur.execute(f"DESC PROCEDURE DEV_API_REF.FUSE.{proc}(VARCHAR)")
        print(f"  {proc}: OK")
    except Exception as e:
        print(f"  {proc}: ERROR - {e}")

print("\nTASKS:")
cur.execute("SHOW TASKS LIKE '%INCR_T' IN DEV_API_REF.FUSE")
for row in cur.fetchall():
    print(f"  {row[1]}: state={row[9]}, schedule={row[5]}")

cur.close()
conn.close()
print("\nDone!")
