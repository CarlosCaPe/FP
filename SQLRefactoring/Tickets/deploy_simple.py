"""
Deploy LH_LOADING_CYCLE_INCR - Simplified version
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

# Step 1: Create table
print("Creating LH_LOADING_CYCLE_INCR table...")
cur.execute("""
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR (
    LOADING_CYCLE_ID                    NUMBER(19,0),
    SITE_CODE                           VARCHAR(4) COLLATE 'en-ci',
    ORIG_SRC_ID                         NUMBER(38,0),
    SHIFT_ID                            VARCHAR(12) COLLATE 'en-ci',
    LOADING_CYCLE_OF_SHIFT              NUMBER(38,0),
    EXCAV_CYCLE_OF_SHIFT                NUMBER(38,0),
    CYCLE_START_TS_UTC                  TIMESTAMP_NTZ(3),
    CYCLE_START_TS_LOCAL                TIMESTAMP_NTZ(3),
    CYCLE_END_TS_UTC                    TIMESTAMP_NTZ(3),
    CYCLE_END_TS_LOCAL                  TIMESTAMP_NTZ(3),
    MEASURED_PAYLOAD_SHORT_TONS         NUMBER(38,6),
    MEASURED_PAYLOAD_METRIC_TONS        NUMBER(38,6),
    AVG_SWING_DURATION_MINS             NUMBER(38,6),
    AVG_DIG_DURATION_MINS               NUMBER(38,6),
    HANG_DURATION_MINS                  NUMBER(38,6),
    IDLE_DURATION_MINS                  NUMBER(38,6),
    BUCKET_COUNT                        NUMBER(38,0),
    EXCAV_ID                            NUMBER(19,0),
    TRUCK_ID                            NUMBER(19,0),
    EXCAV_OPERATOR_ID                   NUMBER(19,0),
    MATERIAL_ID                         NUMBER(19,0),
    LOADING_LOC_ID                      NUMBER(19,0),
    LOADING_CYCLE_DIG_ELEV_AVG_FEET     FLOAT,
    LOADING_CYCLE_DIG_ELEV_AVG_METERS   FLOAT,
    INTERRUPTED_LOADING_FLAG            NUMBER(1,0),
    ASSOCIATED_HAUL_CYCLE_FLAG          NUMBER(1,0),
    OVER_TRUCKED_FLAG                   NUMBER(1,0),
    UNDER_TRUCKED_FLAG                  NUMBER(1,0),
    HAUL_CYCLE_ID                       NUMBER(19,0),
    SYSTEM_VERSION                      VARCHAR(50) COLLATE 'en-ci',
    DW_LOGICAL_DELETE_FLAG              VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
    DW_LOAD_TS                          TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                        TIMESTAMP_NTZ(0)
)
COMMENT = 'Incremental table for LH_LOADING_CYCLE - MERGE-driven upserts with 3-day window'
""")
print("Table created!")

# Step 2: Test insert from source view
print("\nTesting INSERT from PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE (3 days)...")
cur.execute("""
INSERT INTO DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR
SELECT
    loading_cycle_id,
    site_code,
    orig_src_id,
    shift_id,
    loading_cycle_of_shift,
    excav_cycle_of_shift,
    cycle_start_ts_utc,
    cycle_start_ts_local,
    cycle_end_ts_utc,
    cycle_end_ts_local,
    measured_payload_short_tons,
    measured_payload_metric_tons,
    avg_swing_duration_mins,
    avg_dig_duration_mins,
    hang_duration_mins,
    idle_duration_mins,
    bucket_count,
    excav_id,
    truck_id,
    excav_operator_id,
    material_id,
    loading_loc_id,
    loading_cycle_dig_elev_avg_feet,
    loading_cycle_dig_elev_avg_meters,
    interrupted_loading_flag,
    associated_haul_cycle_flag,
    over_trucked_flag,
    under_trucked_flag,
    haul_cycle_id,
    system_version,
    'N' AS dw_logical_delete_flag,
    dw_load_ts,
    dw_modify_ts
FROM prod_wg.load_haul.lh_loading_cycle
WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE())
""")
print(f"Inserted {cur.rowcount:,} rows")

# Step 3: Verify
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
print(f"\nLH_LOADING_CYCLE_INCR total: {cur.fetchone()[0]:,} rows")

cur.close()
conn.close()
print("\nDone!")
