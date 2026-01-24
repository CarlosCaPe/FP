"""
Final fixes for the 2 remaining procedures
"""

import snowflake.connector

SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "DEV_API_REF",
    "schema": "FUSE",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
}

# Fixed procedures with proper casts and column mappings
FIXES = {
    "DRILLBLAST_SHIFT_INCR_P": '''
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_merge = `MERGE INTO dev_api_ref.fuse.drillblast_shift_incr tgt
USING (
    SELECT orig_src_id, site_code, shift_id, shift_date, shift_name,
           shift_date_name, attributed_crew_id, crew_name, shift_no,
           shift_start_ts_utc::TIMESTAMP_NTZ AS shift_start_ts_utc,
           shift_end_ts_utc::TIMESTAMP_NTZ AS shift_end_ts_utc,
           shift_start_ts_local::TIMESTAMP_NTZ AS shift_start_ts_local,
           shift_end_ts_local::TIMESTAMP_NTZ AS shift_end_ts_local,
           system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts::TIMESTAMP_NTZ AS dw_modify_ts
    FROM prod_wg.drill_blast.drillblast_shift
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.site_code = src.site_code AND tgt.shift_id = src.shift_id
WHEN MATCHED THEN UPDATE SET
    tgt.orig_src_id = src.orig_src_id, tgt.shift_date = src.shift_date,
    tgt.shift_name = src.shift_name, tgt.shift_date_name = src.shift_date_name,
    tgt.attributed_crew_id = src.attributed_crew_id, tgt.crew_name = src.crew_name,
    tgt.shift_no = src.shift_no, tgt.shift_start_ts_utc = src.shift_start_ts_utc,
    tgt.shift_end_ts_utc = src.shift_end_ts_utc, tgt.shift_start_ts_local = src.shift_start_ts_local,
    tgt.shift_end_ts_local = src.shift_end_ts_local, tgt.system_version = src.system_version,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, shift_id, shift_date, shift_name, shift_date_name,
    attributed_crew_id, crew_name, shift_no, shift_start_ts_utc, shift_end_ts_utc,
    shift_start_ts_local, shift_end_ts_local, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.shift_id, src.shift_date, src.shift_name,
    src.shift_date_name, src.attributed_crew_id, src.crew_name, src.shift_no,
    src.shift_start_ts_utc, src.shift_end_ts_utc, src.shift_start_ts_local, src.shift_end_ts_local,
    src.system_version, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

try {
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    sp_result = "Deleted: 0, Merged: " + rs_merged_records + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';
''',

    # LH_HAUL_CYCLE_INCR_P - map source columns correctly 
    # Source has: EMPTY_TRAVEL_DURATION_READY_MINS, LOADING_DURATION_READY_MINS, etc.
    # Target wants: EMPTY_TRAVEL_DURATION_MINS, LOADING_DURATION_MINS, etc.
    "LH_HAUL_CYCLE_INCR_P": '''
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_merge = `MERGE INTO dev_api_ref.fuse.lh_haul_cycle_incr tgt
USING (
    SELECT haul_cycle_id, site_code, orig_src_id, 
           shift_id_at_loading_end, shift_id_at_dump_end,
           material_id, routing_shape_id,
           loading_loc_id, loading_loc_name, loading_loc_coord_x, loading_loc_coord_y, loading_loc_elev, loading_method,
           dump_loc_id, dump_loc_name, dump_loc_coord_x, dump_loc_coord_y, dump_loc_elev,
           category_material, category_source_destination,
           excav_id, excav_operator_id, truck_id, truck_loading_operator_id, truck_dumping_operator_id,
           report_payload_short_tons, nominal_payload_short_tons, measured_payload_metric_tons,
           autonomous_flag, overload_flag,
           cycle_start_ts_utc::TIMESTAMP_NTZ AS cycle_start_ts_utc, 
           cycle_end_ts_utc::TIMESTAMP_NTZ AS cycle_end_ts_utc, 
           cycle_start_ts_local::TIMESTAMP_NTZ AS cycle_start_ts_local, 
           cycle_end_ts_local::TIMESTAMP_NTZ AS cycle_end_ts_local,
           empty_travel_start_ts_utc::TIMESTAMP_NTZ AS empty_travel_start_ts_utc, 
           empty_travel_end_ts_utc::TIMESTAMP_NTZ AS empty_travel_end_ts_utc, 
           empty_travel_start_ts_local::TIMESTAMP_NTZ AS empty_travel_start_ts_local, 
           empty_travel_end_ts_local::TIMESTAMP_NTZ AS empty_travel_end_ts_local,
           empty_travel_duration_ready_mins AS empty_travel_duration_mins,
           empty_travel_surface_dist_feet AS empty_travel_distance_feet,
           empty_travel_surface_dist_meters AS empty_travel_distance_meters,
           loading_start_ts_utc::TIMESTAMP_NTZ AS loading_start_ts_utc, 
           loading_end_ts_utc::TIMESTAMP_NTZ AS loading_end_ts_utc, 
           loading_start_ts_local::TIMESTAMP_NTZ AS loading_start_ts_local, 
           loading_end_ts_local::TIMESTAMP_NTZ AS loading_end_ts_local, 
           loading_duration_ready_mins AS loading_duration_mins,
           full_travel_start_ts_utc::TIMESTAMP_NTZ AS full_travel_start_ts_utc, 
           full_travel_end_ts_utc::TIMESTAMP_NTZ AS full_travel_end_ts_utc, 
           full_travel_start_ts_local::TIMESTAMP_NTZ AS full_travel_start_ts_local, 
           full_travel_end_ts_local::TIMESTAMP_NTZ AS full_travel_end_ts_local,
           full_travel_duration_ready_mins AS full_travel_duration_mins,
           full_travel_surface_dist_feet AS full_travel_distance_feet,
           full_travel_surface_dist_meters AS full_travel_distance_meters,
           dumping_start_ts_utc::TIMESTAMP_NTZ AS dumping_start_ts_utc, 
           dumping_end_ts_utc::TIMESTAMP_NTZ AS dumping_end_ts_utc, 
           dumping_start_ts_local::TIMESTAMP_NTZ AS dumping_start_ts_local, 
           dumping_end_ts_local::TIMESTAMP_NTZ AS dumping_end_ts_local, 
           dumping_duration_ready_mins AS dumping_duration_mins,
           total_cycle_duration_ready_mins AS cycle_duration_mins,
           delta_c_mins, fuel_used_in_cycle_gallons,
           tcu_pct, xcu_pct, 
           NULL AS insol_pct,
           system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts::TIMESTAMP_NTZ AS dw_modify_ts
    FROM prod_wg.load_haul.lh_haul_cycle
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.haul_cycle_id = src.haul_cycle_id
WHEN MATCHED THEN UPDATE SET
    tgt.site_code = src.site_code, tgt.material_id = src.material_id,
    tgt.report_payload_short_tons = src.report_payload_short_tons,
    tgt.cycle_end_ts_local = src.cycle_end_ts_local,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    haul_cycle_id, site_code, orig_src_id, shift_id_at_loading_end, shift_id_at_dump_end,
    material_id, routing_shape_id, loading_loc_id, loading_loc_name, loading_loc_coord_x, loading_loc_coord_y, loading_loc_elev, loading_method,
    dump_loc_id, dump_loc_name, dump_loc_coord_x, dump_loc_coord_y, dump_loc_elev,
    category_material, category_source_destination, excav_id, excav_operator_id, truck_id, truck_loading_operator_id, truck_dumping_operator_id,
    report_payload_short_tons, nominal_payload_short_tons, measured_payload_metric_tons, autonomous_flag, overload_flag,
    cycle_start_ts_utc, cycle_end_ts_utc, cycle_start_ts_local, cycle_end_ts_local,
    empty_travel_start_ts_utc, empty_travel_end_ts_utc, empty_travel_start_ts_local, empty_travel_end_ts_local,
    empty_travel_duration_mins, empty_travel_distance_feet, empty_travel_distance_meters,
    loading_start_ts_utc, loading_end_ts_utc, loading_start_ts_local, loading_end_ts_local, loading_duration_mins,
    full_travel_start_ts_utc, full_travel_end_ts_utc, full_travel_start_ts_local, full_travel_end_ts_local,
    full_travel_duration_mins, full_travel_distance_feet, full_travel_distance_meters,
    dumping_start_ts_utc, dumping_end_ts_utc, dumping_start_ts_local, dumping_end_ts_local, dumping_duration_mins,
    cycle_duration_mins, delta_c_mins, fuel_used_in_cycle_gallons, tcu_pct, xcu_pct, insol_pct, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.haul_cycle_id, src.site_code, src.orig_src_id, src.shift_id_at_loading_end, src.shift_id_at_dump_end,
    src.material_id, src.routing_shape_id, src.loading_loc_id, src.loading_loc_name, src.loading_loc_coord_x, src.loading_loc_coord_y, src.loading_loc_elev, src.loading_method,
    src.dump_loc_id, src.dump_loc_name, src.dump_loc_coord_x, src.dump_loc_coord_y, src.dump_loc_elev,
    src.category_material, src.category_source_destination, src.excav_id, src.excav_operator_id, src.truck_id, src.truck_loading_operator_id, src.truck_dumping_operator_id,
    src.report_payload_short_tons, src.nominal_payload_short_tons, src.measured_payload_metric_tons, src.autonomous_flag, src.overload_flag,
    src.cycle_start_ts_utc, src.cycle_end_ts_utc, src.cycle_start_ts_local, src.cycle_end_ts_local,
    src.empty_travel_start_ts_utc, src.empty_travel_end_ts_utc, src.empty_travel_start_ts_local, src.empty_travel_end_ts_local,
    src.empty_travel_duration_mins, src.empty_travel_distance_feet, src.empty_travel_distance_meters,
    src.loading_start_ts_utc, src.loading_end_ts_utc, src.loading_start_ts_local, src.loading_end_ts_local, src.loading_duration_mins,
    src.full_travel_start_ts_utc, src.full_travel_end_ts_utc, src.full_travel_start_ts_local, src.full_travel_end_ts_local,
    src.full_travel_duration_mins, src.full_travel_distance_feet, src.full_travel_distance_meters,
    src.dumping_start_ts_utc, src.dumping_end_ts_utc, src.dumping_start_ts_local, src.dumping_end_ts_local, src.dumping_duration_mins,
    src.cycle_duration_mins, src.delta_c_mins, src.fuel_used_in_cycle_gallons, src.tcu_pct, src.xcu_pct, src.insol_pct, src.system_version,
    src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

try {
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    sp_result = "Deleted: 0, Merged: " + rs_merged_records + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';
'''
}

print("Connecting to Snowflake...")
conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
cursor = conn.cursor()
print("Connected!\n")

cursor.execute("USE DATABASE DEV_API_REF;")
cursor.execute("USE SCHEMA FUSE;")

for proc_name, proc_sql in FIXES.items():
    print(f"Fixing {proc_name}...")
    try:
        cursor.execute(proc_sql)
        print(f"  ✅ Created!")
        
        # Test it
        cursor.execute(f"CALL DEV_API_REF.FUSE.{proc_name}('3')")
        result = cursor.fetchone()
        print(f"  ✅ Test result: {result}")
    except Exception as e:
        print(f"  ❌ Error: {str(e)[:300]}")

cursor.close()
conn.close()
print("\n🎉 Done!")
