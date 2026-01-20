"""
Deploy and stress test LH_BUCKET_INCR
"""
import snowflake.connector
from dotenv import load_dotenv
import os
import time
import re

load_dotenv('../tools/.env')

conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)

cur = conn.cursor()

# Step 1: Create table
print("=== CREATING LH_BUCKET_INCR TABLE ===")
cur.execute("""
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_BUCKET_INCR (
    BUCKET_ID                           NUMBER(19,0),
    SITE_CODE                           VARCHAR(4) COLLATE 'en-ci',
    LOADING_CYCLE_ID                    NUMBER(19,0),
    LH_EQUIP_ID                         NUMBER(38,5),
    ORIG_SRC_ID                         NUMBER(38,0),
    BUCKET_OF_CYCLE                     NUMBER(38,0),
    SWING_EMPTY_START_TS_UTC            TIMESTAMP_NTZ(3),
    SWING_EMPTY_START_TS_LOCAL          TIMESTAMP_NTZ(3),
    SWING_EMPTY_END_TS_UTC              TIMESTAMP_NTZ(3),
    SWING_EMPTY_END_TS_LOCAL            TIMESTAMP_NTZ(3),
    DIG_START_TS_UTC                    TIMESTAMP_NTZ(3),
    DIG_START_TS_LOCAL                  TIMESTAMP_NTZ(3),
    DIG_END_TS_UTC                      TIMESTAMP_NTZ(3),
    DIG_END_TS_LOCAL                    TIMESTAMP_NTZ(3),
    SWING_FULL_START_TS_UTC             TIMESTAMP_NTZ(3),
    SWING_FULL_START_TS_LOCAL           TIMESTAMP_NTZ(3),
    SWING_FULL_END_TS_UTC               TIMESTAMP_NTZ(3),
    SWING_FULL_END_TS_LOCAL             TIMESTAMP_NTZ(3),
    TRIP_TS_UTC                         TIMESTAMP_NTZ(3),
    TRIP_TS_LOCAL                       TIMESTAMP_NTZ(3),
    DIG_X                               FLOAT,
    DIG_Y                               FLOAT,
    DIG_Z                               FLOAT,
    TRIP_X                              FLOAT,
    TRIP_Y                              FLOAT,
    TRIP_Z                              FLOAT,
    SWING_ANGLE_DEGREES                 FLOAT,
    BLOCK_CENTROID_X                    FLOAT,
    BLOCK_CENTROID_Y                    FLOAT,
    BLOCK_CENTROID_Z                    FLOAT,
    MEASURED_SHORT_TONS                 NUMBER(38,6),
    MEASURED_METRIC_TONS                NUMBER(38,6),
    SWING_EMPTY_DURATION_MINS           NUMBER(38,6),
    DIG_DURATION_MINS                   NUMBER(38,6),
    SWING_FULL_DURATION_MINS            NUMBER(38,6),
    SYSTEM_VERSION                      VARCHAR(50) COLLATE 'en-ci',
    DW_LOGICAL_DELETE_FLAG              VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
    DW_LOAD_TS                          TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                        TIMESTAMP_NTZ(0)
)
COMMENT = 'Incremental table for LH_BUCKET - MERGE-driven upserts with 3-day window'
""")
print("Table created!")

# Step 2: Create procedure
print("\n=== CREATING LH_BUCKET_INCR_P PROCEDURE ===")
with open('LH_BUCKET/refactor_ddl_v2.sql', 'r') as f:
    content = f.read()

proc_match = re.search(r"(CREATE OR REPLACE PROCEDURE DEV_API_REF\.FUSE\.LH_BUCKET_INCR_P.*?';)", content, re.DOTALL)
if proc_match:
    cur.execute(proc_match.group(1))
    print("Procedure created!")
else:
    print("ERROR: Could not find procedure!")
    exit(1)

# Step 3: Stress test
print("\n=== STRESS TEST LH_BUCKET_INCR_P ===")
print(f"{'Days':>6} | {'Time (s)':>10} | {'Merged':>12} | Result")
print("-" * 60)

for days in [1, 3, 7, 14, 30, 60, 90]:
    cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_BUCKET_INCR")
    
    start = time.time()
    cur.execute(f"CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('{days}')")
    elapsed = time.time() - start
    result = cur.fetchone()[0]
    
    match = re.search(r'merged records into INCR table: (\d+)', result)
    merged = match.group(1) if match else "?"
    
    print(f"{days:>6} | {elapsed:>10.2f} | {merged:>12} | OK")

# Final count
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_INCR")
print(f"\nFinal row count: {cur.fetchone()[0]:,}")

# Step 4: Reset to 3 days
print("\n=== RESETTING TO 3-DAY WINDOW ===")
cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_BUCKET_INCR")
cur.execute("CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('3')")
print(f"Result: {cur.fetchone()[0]}")

cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_INCR")
print(f"Row count: {cur.fetchone()[0]:,}")

# Step 5: Create and enable task
print("\n=== CREATING TASK ===")
cur.execute("""
CREATE OR REPLACE TASK DEV_API_REF.FUSE.LH_BUCKET_INCR_T
    WAREHOUSE = 'WH_BATCH_DE_NONPROD'
    SCHEDULE = 'USING CRON */15 * * * * UTC'
    COMMENT = 'Refresh LH_BUCKET_INCR every 15 minutes with 3-day lookback'
AS
    CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('3')
""")
print("Task created!")

cur.execute("ALTER TASK DEV_API_REF.FUSE.LH_BUCKET_INCR_T RESUME")
print("Task enabled!")

cur.close()
conn.close()
print("\nDone!")
