CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.LH_BUCKET_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from LH_BUCKET into LH_BUCKET_INCR
* SOURCE    : {{ RO_PROD }}_WG.LOAD_HAUL.LH_BUCKET
* TARGET    : {{ envi }}_API_REF.FUSE.LH_BUCKET_INCR
* BUSINESS KEY: BUCKET_ID
* INCREMENTAL COLUMN: TRIP_TS_LOCAL
* DATE: 2026-01-27 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.lh_bucket_incr 
                  WHERE trip_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.lh_bucket_incr 
                   WHERE trip_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.lh_bucket_incr tgt
USING (
    SELECT
        bucket_id,
        site_code,
        loading_cycle_id,
        lh_equip_id,
        orig_src_id,
        bucket_of_cycle,
        swing_empty_start_ts_utc,
        swing_empty_start_ts_local,
        swing_empty_end_ts_utc,
        swing_empty_end_ts_local,
        dig_start_ts_utc,
        dig_start_ts_local,
        dig_end_ts_utc,
        dig_end_ts_local,
        swing_full_start_ts_utc,
        swing_full_start_ts_local,
        swing_full_end_ts_utc,
        swing_full_end_ts_local,
        trip_ts_utc,
        trip_ts_local,
        dig_x,
        dig_y,
        dig_z,
        trip_x,
        trip_y,
        trip_z,
        swing_angle_degrees,
        block_centroid_x,
        block_centroid_y,
        block_centroid_z,
        measured_short_tons,
        measured_metric_tons,
        swing_empty_duration_mins,
        dig_duration_mins,
        swing_full_duration_mins,
        system_version,
        ''N'' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_modify_ts
    FROM {{ RO_PROD }}_WG.load_haul.lh_bucket
    WHERE trip_ts_local::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src
ON tgt.bucket_id = src.bucket_id
WHEN MATCHED AND HASH(
    src.site_code, src.loading_cycle_id, src.lh_equip_id, src.orig_src_id,
    src.bucket_of_cycle, src.swing_empty_start_ts_utc, src.swing_empty_start_ts_local,
    src.swing_empty_end_ts_utc, src.swing_empty_end_ts_local,
    src.dig_start_ts_utc, src.dig_start_ts_local, src.dig_end_ts_utc, src.dig_end_ts_local,
    src.swing_full_start_ts_utc, src.swing_full_start_ts_local,
    src.swing_full_end_ts_utc, src.swing_full_end_ts_local,
    src.trip_ts_utc, src.trip_ts_local,
    src.dig_x, src.dig_y, src.dig_z, src.trip_x, src.trip_y, src.trip_z,
    src.swing_angle_degrees, src.block_centroid_x, src.block_centroid_y, src.block_centroid_z,
    src.measured_short_tons, src.measured_metric_tons,
    src.swing_empty_duration_mins, src.dig_duration_mins, src.swing_full_duration_mins,
    src.system_version
) <> HASH(
    tgt.site_code, tgt.loading_cycle_id, tgt.lh_equip_id, tgt.orig_src_id,
    tgt.bucket_of_cycle, tgt.swing_empty_start_ts_utc, tgt.swing_empty_start_ts_local,
    tgt.swing_empty_end_ts_utc, tgt.swing_empty_end_ts_local,
    tgt.dig_start_ts_utc, tgt.dig_start_ts_local, tgt.dig_end_ts_utc, tgt.dig_end_ts_local,
    tgt.swing_full_start_ts_utc, tgt.swing_full_start_ts_local,
    tgt.swing_full_end_ts_utc, tgt.swing_full_end_ts_local,
    tgt.trip_ts_utc, tgt.trip_ts_local,
    tgt.dig_x, tgt.dig_y, tgt.dig_z, tgt.trip_x, tgt.trip_y, tgt.trip_z,
    tgt.swing_angle_degrees, tgt.block_centroid_x, tgt.block_centroid_y, tgt.block_centroid_z,
    tgt.measured_short_tons, tgt.measured_metric_tons,
    tgt.swing_empty_duration_mins, tgt.dig_duration_mins, tgt.swing_full_duration_mins,
    tgt.system_version
) THEN UPDATE SET
    tgt.site_code = src.site_code,
    tgt.loading_cycle_id = src.loading_cycle_id,
    tgt.lh_equip_id = src.lh_equip_id,
    tgt.orig_src_id = src.orig_src_id,
    tgt.bucket_of_cycle = src.bucket_of_cycle,
    tgt.swing_empty_start_ts_utc = src.swing_empty_start_ts_utc,
    tgt.swing_empty_start_ts_local = src.swing_empty_start_ts_local,
    tgt.swing_empty_end_ts_utc = src.swing_empty_end_ts_utc,
    tgt.swing_empty_end_ts_local = src.swing_empty_end_ts_local,
    tgt.dig_start_ts_utc = src.dig_start_ts_utc,
    tgt.dig_start_ts_local = src.dig_start_ts_local,
    tgt.dig_end_ts_utc = src.dig_end_ts_utc,
    tgt.dig_end_ts_local = src.dig_end_ts_local,
    tgt.swing_full_start_ts_utc = src.swing_full_start_ts_utc,
    tgt.swing_full_start_ts_local = src.swing_full_start_ts_local,
    tgt.swing_full_end_ts_utc = src.swing_full_end_ts_utc,
    tgt.swing_full_end_ts_local = src.swing_full_end_ts_local,
    tgt.trip_ts_utc = src.trip_ts_utc,
    tgt.trip_ts_local = src.trip_ts_local,
    tgt.dig_x = src.dig_x,
    tgt.dig_y = src.dig_y,
    tgt.dig_z = src.dig_z,
    tgt.trip_x = src.trip_x,
    tgt.trip_y = src.trip_y,
    tgt.trip_z = src.trip_z,
    tgt.swing_angle_degrees = src.swing_angle_degrees,
    tgt.block_centroid_x = src.block_centroid_x,
    tgt.block_centroid_y = src.block_centroid_y,
    tgt.block_centroid_z = src.block_centroid_z,
    tgt.measured_short_tons = src.measured_short_tons,
    tgt.measured_metric_tons = src.measured_metric_tons,
    tgt.swing_empty_duration_mins = src.swing_empty_duration_mins,
    tgt.dig_duration_mins = src.dig_duration_mins,
    tgt.swing_full_duration_mins = src.swing_full_duration_mins,
    tgt.system_version = src.system_version,
    tgt.dw_modify_ts = src.dw_modify_ts
WHEN NOT MATCHED THEN INSERT (
    bucket_id, site_code, loading_cycle_id, lh_equip_id, orig_src_id, bucket_of_cycle,
    swing_empty_start_ts_utc, swing_empty_start_ts_local, swing_empty_end_ts_utc, swing_empty_end_ts_local,
    dig_start_ts_utc, dig_start_ts_local, dig_end_ts_utc, dig_end_ts_local,
    swing_full_start_ts_utc, swing_full_start_ts_local, swing_full_end_ts_utc, swing_full_end_ts_local,
    trip_ts_utc, trip_ts_local,
    dig_x, dig_y, dig_z, trip_x, trip_y, trip_z,
    swing_angle_degrees, block_centroid_x, block_centroid_y, block_centroid_z,
    measured_short_tons, measured_metric_tons,
    swing_empty_duration_mins, dig_duration_mins, swing_full_duration_mins,
    system_version, dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.bucket_id, src.site_code, src.loading_cycle_id, src.lh_equip_id, src.orig_src_id, src.bucket_of_cycle,
    src.swing_empty_start_ts_utc, src.swing_empty_start_ts_local, src.swing_empty_end_ts_utc, src.swing_empty_end_ts_local,
    src.dig_start_ts_utc, src.dig_start_ts_local, src.dig_end_ts_utc, src.dig_end_ts_local,
    src.swing_full_start_ts_utc, src.swing_full_start_ts_local, src.swing_full_end_ts_utc, src.swing_full_end_ts_local,
    src.trip_ts_utc, src.trip_ts_local,
    src.dig_x, src.dig_y, src.dig_z, src.trip_x, src.trip_y, src.trip_z,
    src.swing_angle_degrees, src.block_centroid_x, src.block_centroid_y, src.block_centroid_z,
    src.measured_short_tons, src.measured_metric_tons,
    src.swing_empty_duration_mins, src.dig_duration_mins, src.swing_full_duration_mins,
    src.system_version, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

sql_delete = `UPDATE {{ envi }}_API_REF.fuse.lh_bucket_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.load_haul.lh_bucket src
                  WHERE src.bucket_id = tgt.bucket_id);`;

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
