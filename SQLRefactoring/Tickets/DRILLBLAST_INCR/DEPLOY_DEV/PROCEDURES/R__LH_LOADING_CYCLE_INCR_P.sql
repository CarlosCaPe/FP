CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from LH_LOADING_CYCLE into LH_LOADING_CYCLE_INCR
* SOURCE    : PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
* TARGET    : DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR
* BUSINESS KEY: LOADING_CYCLE_ID
* INCREMENTAL COLUMN: CYCLE_START_TS_LOCAL
* DATE: 2026-01-27 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM DEV_API_REF.fuse.lh_loading_cycle_incr 
                  WHERE cycle_start_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM DEV_API_REF.fuse.lh_loading_cycle_incr 
                   WHERE cycle_start_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO DEV_API_REF.fuse.lh_loading_cycle_incr tgt
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
        loading_cycle_dig_elev_avg_feet,
        loading_cycle_dig_elev_avg_meters,
        interrupted_loading_flag,
        associated_haul_cycle_flag,
        over_trucked_flag,
        under_trucked_flag,
        haul_cycle_id,
        system_version,
        ''N'' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_modify_ts
    FROM PROD_WG.load_haul.lh_loading_cycle
    WHERE cycle_start_ts_local::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src
ON tgt.loading_cycle_id = src.loading_cycle_id
WHEN MATCHED AND HASH(
    src.site_code, src.orig_src_id, src.shift_id, src.loading_cycle_of_shift,
    src.excav_cycle_of_shift, src.cycle_start_ts_utc, src.cycle_start_ts_local,
    src.cycle_end_ts_utc, src.cycle_end_ts_local, src.measured_payload_short_tons,
    src.measured_payload_metric_tons, src.avg_swing_duration_mins, src.avg_dig_duration_mins,
    src.hang_duration_mins, src.idle_duration_mins, src.bucket_count,
    src.excav_id, src.truck_id, src.excav_operator_id, src.material_id,
    src.loading_loc_id, src.loading_cycle_dig_elev_avg_feet, src.loading_cycle_dig_elev_avg_meters,
    src.interrupted_loading_flag, src.associated_haul_cycle_flag,
    src.over_trucked_flag, src.under_trucked_flag, src.haul_cycle_id, src.system_version
) <> HASH(
    tgt.site_code, tgt.orig_src_id, tgt.shift_id, tgt.loading_cycle_of_shift,
    tgt.excav_cycle_of_shift, tgt.cycle_start_ts_utc, tgt.cycle_start_ts_local,
    tgt.cycle_end_ts_utc, tgt.cycle_end_ts_local, tgt.measured_payload_short_tons,
    tgt.measured_payload_metric_tons, tgt.avg_swing_duration_mins, tgt.avg_dig_duration_mins,
    tgt.hang_duration_mins, tgt.idle_duration_mins, tgt.bucket_count,
    tgt.excav_id, tgt.truck_id, tgt.excav_operator_id, tgt.material_id,
    tgt.loading_loc_id, tgt.loading_cycle_dig_elev_avg_feet, tgt.loading_cycle_dig_elev_avg_meters,
    tgt.interrupted_loading_flag, tgt.associated_haul_cycle_flag,
    tgt.over_trucked_flag, tgt.under_trucked_flag, tgt.haul_cycle_id, tgt.system_version
) THEN UPDATE SET
    tgt.site_code = src.site_code,
    tgt.orig_src_id = src.orig_src_id,
    tgt.shift_id = src.shift_id,
    tgt.loading_cycle_of_shift = src.loading_cycle_of_shift,
    tgt.excav_cycle_of_shift = src.excav_cycle_of_shift,
    tgt.cycle_start_ts_utc = src.cycle_start_ts_utc,
    tgt.cycle_start_ts_local = src.cycle_start_ts_local,
    tgt.cycle_end_ts_utc = src.cycle_end_ts_utc,
    tgt.cycle_end_ts_local = src.cycle_end_ts_local,
    tgt.measured_payload_short_tons = src.measured_payload_short_tons,
    tgt.measured_payload_metric_tons = src.measured_payload_metric_tons,
    tgt.avg_swing_duration_mins = src.avg_swing_duration_mins,
    tgt.avg_dig_duration_mins = src.avg_dig_duration_mins,
    tgt.hang_duration_mins = src.hang_duration_mins,
    tgt.idle_duration_mins = src.idle_duration_mins,
    tgt.bucket_count = src.bucket_count,
    tgt.excav_id = src.excav_id,
    tgt.truck_id = src.truck_id,
    tgt.excav_operator_id = src.excav_operator_id,
    tgt.material_id = src.material_id,
    tgt.loading_loc_id = src.loading_loc_id,
    tgt.loading_cycle_dig_elev_avg_feet = src.loading_cycle_dig_elev_avg_feet,
    tgt.loading_cycle_dig_elev_avg_meters = src.loading_cycle_dig_elev_avg_meters,
    tgt.interrupted_loading_flag = src.interrupted_loading_flag,
    tgt.associated_haul_cycle_flag = src.associated_haul_cycle_flag,
    tgt.over_trucked_flag = src.over_trucked_flag,
    tgt.under_trucked_flag = src.under_trucked_flag,
    tgt.haul_cycle_id = src.haul_cycle_id,
    tgt.system_version = src.system_version,
    tgt.dw_modify_ts = src.dw_modify_ts
WHEN NOT MATCHED THEN INSERT (
    loading_cycle_id, site_code, orig_src_id, shift_id,
    loading_cycle_of_shift, excav_cycle_of_shift,
    cycle_start_ts_utc, cycle_start_ts_local, cycle_end_ts_utc, cycle_end_ts_local,
    measured_payload_short_tons, measured_payload_metric_tons,
    avg_swing_duration_mins, avg_dig_duration_mins, hang_duration_mins, idle_duration_mins,
    bucket_count, excav_id, truck_id, excav_operator_id, material_id, loading_loc_id,
    loading_cycle_dig_elev_avg_feet, loading_cycle_dig_elev_avg_meters,
    interrupted_loading_flag, associated_haul_cycle_flag, over_trucked_flag, under_trucked_flag,
    haul_cycle_id, system_version, dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.loading_cycle_id, src.site_code, src.orig_src_id, src.shift_id,
    src.loading_cycle_of_shift, src.excav_cycle_of_shift,
    src.cycle_start_ts_utc, src.cycle_start_ts_local, src.cycle_end_ts_utc, src.cycle_end_ts_local,
    src.measured_payload_short_tons, src.measured_payload_metric_tons,
    src.avg_swing_duration_mins, src.avg_dig_duration_mins, src.hang_duration_mins, src.idle_duration_mins,
    src.bucket_count, src.excav_id, src.truck_id, src.excav_operator_id, src.material_id, src.loading_loc_id,
    src.loading_cycle_dig_elev_avg_feet, src.loading_cycle_dig_elev_avg_meters,
    src.interrupted_loading_flag, src.associated_haul_cycle_flag, src.over_trucked_flag, src.under_trucked_flag,
    src.haul_cycle_id, src.system_version, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

sql_delete = `UPDATE DEV_API_REF.fuse.lh_loading_cycle_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM PROD_WG.load_haul.lh_loading_cycle src
                  WHERE src.loading_cycle_id = tgt.loading_cycle_id);`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');
    rs_deleted_records_incr = rs_records_incr > 0 ? snowflake.execute({sqlText: sql_delete_incr}).getNumRowsAffected() : 0;
    rs_merge = snowflake.execute({sqlText: sql_merge});
    rs_merged_records = rs_merge.getNumRowsAffected();
    rs_delete = snowflake.execute({sqlText: sql_delete});
    rs_delete_records = rs_delete.getNumRowsAffected();
    sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
} catch (err) { snowflake.execute({sqlText: "ROLLBACK WORK;"}); throw err; }
';

