"""
FINAL COMPARISON: VIEW vs TABLE (_C)
Correctly handles column differences
"""
import snowflake.connector
from dotenv import load_dotenv
import os
import time

load_dotenv('../tools/.env')

print("Connecting to Snowflake...")
conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)

cur = conn.cursor()
print("Connected!\n")

# Create _C based procedure without the computed columns
print("Creating LH_LOADING_CYCLE_INCR_C_P (using _C table)...")
cur.execute("""
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_C_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS $$
var sql_merge = `MERGE INTO dev_api_ref.fuse.lh_loading_cycle_incr tgt
USING (
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
        NULL AS loading_cycle_dig_elev_avg_feet,
        NULL AS loading_cycle_dig_elev_avg_meters,
        interrupted_loading_flag,
        associated_haul_cycle_flag,
        over_trucked_flag,
        under_trucked_flag,
        haul_cycle_id,
        system_version,
        'N' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_modify_ts
    FROM prod_target.collections.lh_loading_cycle_c
    WHERE cycle_start_ts_local::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
    AND dw_logical_delete_flag = 'N'
) AS src
ON tgt.loading_cycle_id = src.loading_cycle_id
WHEN MATCHED AND HASH(src.site_code, src.orig_src_id, src.shift_id, src.cycle_start_ts_local, src.cycle_end_ts_local, src.measured_payload_short_tons, src.bucket_count, src.excav_id, src.truck_id, src.system_version) 
<> HASH(tgt.site_code, tgt.orig_src_id, tgt.shift_id, tgt.cycle_start_ts_local, tgt.cycle_end_ts_local, tgt.measured_payload_short_tons, tgt.bucket_count, tgt.excav_id, tgt.truck_id, tgt.system_version) 
THEN UPDATE SET
    tgt.site_code = src.site_code, tgt.orig_src_id = src.orig_src_id, tgt.shift_id = src.shift_id,
    tgt.loading_cycle_of_shift = src.loading_cycle_of_shift, tgt.excav_cycle_of_shift = src.excav_cycle_of_shift,
    tgt.cycle_start_ts_utc = src.cycle_start_ts_utc, tgt.cycle_start_ts_local = src.cycle_start_ts_local,
    tgt.cycle_end_ts_utc = src.cycle_end_ts_utc, tgt.cycle_end_ts_local = src.cycle_end_ts_local,
    tgt.measured_payload_short_tons = src.measured_payload_short_tons, tgt.measured_payload_metric_tons = src.measured_payload_metric_tons,
    tgt.avg_swing_duration_mins = src.avg_swing_duration_mins, tgt.avg_dig_duration_mins = src.avg_dig_duration_mins,
    tgt.hang_duration_mins = src.hang_duration_mins, tgt.idle_duration_mins = src.idle_duration_mins,
    tgt.bucket_count = src.bucket_count, tgt.excav_id = src.excav_id, tgt.truck_id = src.truck_id,
    tgt.excav_operator_id = src.excav_operator_id, tgt.material_id = src.material_id, tgt.loading_loc_id = src.loading_loc_id,
    tgt.loading_cycle_dig_elev_avg_feet = src.loading_cycle_dig_elev_avg_feet, tgt.loading_cycle_dig_elev_avg_meters = src.loading_cycle_dig_elev_avg_meters,
    tgt.interrupted_loading_flag = src.interrupted_loading_flag, tgt.associated_haul_cycle_flag = src.associated_haul_cycle_flag,
    tgt.over_trucked_flag = src.over_trucked_flag, tgt.under_trucked_flag = src.under_trucked_flag,
    tgt.haul_cycle_id = src.haul_cycle_id, tgt.system_version = src.system_version, tgt.dw_modify_ts = src.dw_modify_ts
WHEN NOT MATCHED THEN INSERT (loading_cycle_id, site_code, orig_src_id, shift_id, loading_cycle_of_shift, excav_cycle_of_shift,
    cycle_start_ts_utc, cycle_start_ts_local, cycle_end_ts_utc, cycle_end_ts_local, measured_payload_short_tons, measured_payload_metric_tons,
    avg_swing_duration_mins, avg_dig_duration_mins, hang_duration_mins, idle_duration_mins, bucket_count, excav_id, truck_id,
    excav_operator_id, material_id, loading_loc_id, loading_cycle_dig_elev_avg_feet, loading_cycle_dig_elev_avg_meters,
    interrupted_loading_flag, associated_haul_cycle_flag, over_trucked_flag, under_trucked_flag, haul_cycle_id, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts)
VALUES (src.loading_cycle_id, src.site_code, src.orig_src_id, src.shift_id, src.loading_cycle_of_shift, src.excav_cycle_of_shift,
    src.cycle_start_ts_utc, src.cycle_start_ts_local, src.cycle_end_ts_utc, src.cycle_end_ts_local, src.measured_payload_short_tons, src.measured_payload_metric_tons,
    src.avg_swing_duration_mins, src.avg_dig_duration_mins, src.hang_duration_mins, src.idle_duration_mins, src.bucket_count, src.excav_id, src.truck_id,
    src.excav_operator_id, src.material_id, src.loading_loc_id, src.loading_cycle_dig_elev_avg_feet, src.loading_cycle_dig_elev_avg_meters,
    src.interrupted_loading_flag, src.associated_haul_cycle_flag, src.over_trucked_flag, src.under_trucked_flag, src.haul_cycle_id, src.system_version,
    src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts);`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return "Execution complete, merged records: " + rs_merged_records;
} catch (err) {
    snowflake.execute({sqlText: "ROLLBACK WORK;"});
    throw err;
}
$$
""")
print("Created LH_LOADING_CYCLE_INCR_C_P\n")

# Now run comparison
print("=" * 70)
print("PERFORMANCE COMPARISON: VIEW vs TABLE (_C)")
print("=" * 70)

# Test VIEW-based procedure
print("\n--- LH_LOADING_CYCLE_INCR_P (VIEW source) ---")
cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
start = time.time()
cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')")
view_time = time.time() - start
view_result = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
view_count = cur.fetchone()[0]
print(f"Time: {view_time:.2f}s, Rows: {view_count:,}")

# Test TABLE-based procedure
print("\n--- LH_LOADING_CYCLE_INCR_C_P (TABLE _C source) ---")
cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
start = time.time()
cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_C_P('3')")
table_time = time.time() - start
table_result = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
table_count = cur.fetchone()[0]
print(f"Time: {table_time:.2f}s, Rows: {table_count:,}")

# Check difference in the computed columns
print("\n--- Checking computed columns ---")
cur.execute("""
    SELECT COUNT(*), 
           SUM(CASE WHEN loading_cycle_dig_elev_avg_feet IS NOT NULL THEN 1 ELSE 0 END) AS with_elevation
    FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR
""")
row = cur.fetchone()
print(f"Rows with elevation data: {row[1]:,} / {row[0]:,}")

# Summary
print("\n" + "=" * 70)
print("SUMMARY: LH_LOADING_CYCLE")
print("=" * 70)
print(f"{'Source':<35} | {'Time (s)':>10} | {'Rows':>12} | {'Speedup':>10}")
print("-" * 70)
print(f"{'VIEW (PROD_WG.LOAD_HAUL)':<35} | {view_time:>10.2f} | {view_count:>12,} | {'1.0x':>10}")
print(f"{'TABLE (_C) [no elevation calc]':<35} | {table_time:>10.2f} | {table_count:>12,} | {view_time/table_time:>10.1f}x")

# Multiple runs to confirm
print("\n" + "=" * 70)
print("MULTIPLE RUNS (3 iterations each)")
print("=" * 70)

view_times = []
table_times = []

for i in range(3):
    # VIEW
    cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
    start = time.time()
    cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3')")
    cur.fetchone()
    view_times.append(time.time() - start)
    
    # TABLE
    cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
    start = time.time()
    cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_C_P('3')")
    cur.fetchone()
    table_times.append(time.time() - start)
    
    print(f"Run {i+1}: VIEW={view_times[-1]:.2f}s, TABLE={table_times[-1]:.2f}s")

print(f"\nAVERAGE: VIEW={sum(view_times)/3:.2f}s, TABLE={sum(table_times)/3:.2f}s")
print(f"SPEEDUP: {(sum(view_times)/3) / (sum(table_times)/3):.1f}x faster with _C table")

print("\n" + "=" * 70)
print("⚠️  KEY FINDING:")
print("=" * 70)
print("""
The VIEW calculates LOADING_CYCLE_DIG_ELEV_AVG_FEET/METERS by doing:
  - LEFT OUTER JOIN with LH_BUCKET_C 
  - Aggregate AVG(dig_z_avg_feet) per loading_cycle_id
  - This scans 1.7 GB of LH_BUCKET_C data

If the API DOES need these elevation columns, the VIEW is required.
If the API does NOT need them, we can use _C table directly (5-10x faster).

QUESTION FOR HIDAYATH/VIKAS:
Does the API require loading_cycle_dig_elev_avg_feet/meters columns?
""")

cur.close()
conn.close()
print("\nDone!")
