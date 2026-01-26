CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                      FROM {{ envi }}_API_REF.fuse.lh_haul_cycle_incr 
                      WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.lh_haul_cycle_incr 
                       WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.lh_haul_cycle_incr tgt
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
    FROM {{ RO_PROD }}_WG.load_haul.lh_haul_cycle
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

var sql_delete = `UPDATE {{ envi }}_API_REF.fuse.lh_haul_cycle_incr tgt
                  SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
                  WHERE tgt.dw_logical_delete_flag = ''N''
                  AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.load_haul.lh_haul_cycle src
                      WHERE src.haul_cycle_id = tgt.haul_cycle_id);`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    var rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    var rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');
    var rs_deleted_records_incr = rs_records_incr > 0 ? snowflake.execute({sqlText: sql_delete_incr}).getNumRowsAffected() : 0;
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    var rs_delete = snowflake.execute({sqlText: sql_delete});
    var rs_delete_records = rs_delete.getNumRowsAffected();
    sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
} catch (err) { snowflake.execute({sqlText: "ROLLBACK WORK;"}); throw err; }
';
