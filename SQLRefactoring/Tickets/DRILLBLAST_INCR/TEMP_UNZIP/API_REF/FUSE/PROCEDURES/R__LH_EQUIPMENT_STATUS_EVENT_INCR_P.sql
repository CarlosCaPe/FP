CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.LH_EQUIPMENT_STATUS_EVENT_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from LH_EQUIPMENT_STATUS_EVENT into LH_EQUIPMENT_STATUS_EVENT_INCR
* SOURCE    : {{ RO_PROD }}_WG.LOAD_HAUL.LH_EQUIPMENT_STATUS_EVENT
* TARGET    : {{ envi }}_API_REF.FUSE.LH_EQUIPMENT_STATUS_EVENT_INCR
* BUSINESS KEY: EQUIP_STATUS_EVENT_SK
* INCREMENTAL COLUMN: START_TS_LOCAL
* DATE: 2026-01-27 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.lh_equipment_status_event_incr 
                  WHERE start_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.lh_equipment_status_event_incr 
                   WHERE start_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.lh_equipment_status_event_incr tgt
USING (
    SELECT
        site_code,
        equip_id,
        equip_category,
        orig_src_id,
        equip_status_event_sk,
        shift_id,
        cycle_id,
        status_event_reason_id,
        start_ts_utc,
        end_ts_utc,
        start_ts_local,
        end_ts_local,
        duration_mins,
        event_comments,
        distinct_status_event_flag,
        prev_status_event_id,
        next_status_event_id,
        system_version,
        ''N'' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_modify_ts
    FROM {{ RO_PROD }}_WG.load_haul.lh_equipment_status_event
    WHERE start_ts_local::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY equip_status_event_sk ORDER BY dw_modify_ts DESC) = 1
) AS src
ON tgt.equip_status_event_sk = src.equip_status_event_sk
WHEN MATCHED AND HASH(
    src.site_code, src.equip_id, src.equip_category, src.orig_src_id,
    src.shift_id, src.cycle_id, src.status_event_reason_id,
    src.start_ts_utc, src.end_ts_utc, src.start_ts_local, src.end_ts_local,
    src.duration_mins, src.event_comments, src.distinct_status_event_flag,
    src.prev_status_event_id, src.next_status_event_id, src.system_version
) <> HASH(
    tgt.site_code, tgt.equip_id, tgt.equip_category, tgt.orig_src_id,
    tgt.shift_id, tgt.cycle_id, tgt.status_event_reason_id,
    tgt.start_ts_utc, tgt.end_ts_utc, tgt.start_ts_local, tgt.end_ts_local,
    tgt.duration_mins, tgt.event_comments, tgt.distinct_status_event_flag,
    tgt.prev_status_event_id, tgt.next_status_event_id, tgt.system_version
) THEN UPDATE SET
    tgt.site_code = src.site_code,
    tgt.equip_id = src.equip_id,
    tgt.equip_category = src.equip_category,
    tgt.orig_src_id = src.orig_src_id,
    tgt.shift_id = src.shift_id,
    tgt.cycle_id = src.cycle_id,
    tgt.status_event_reason_id = src.status_event_reason_id,
    tgt.start_ts_utc = src.start_ts_utc,
    tgt.end_ts_utc = src.end_ts_utc,
    tgt.start_ts_local = src.start_ts_local,
    tgt.end_ts_local = src.end_ts_local,
    tgt.duration_mins = src.duration_mins,
    tgt.event_comments = src.event_comments,
    tgt.distinct_status_event_flag = src.distinct_status_event_flag,
    tgt.prev_status_event_id = src.prev_status_event_id,
    tgt.next_status_event_id = src.next_status_event_id,
    tgt.system_version = src.system_version,
    tgt.dw_modify_ts = src.dw_modify_ts
WHEN NOT MATCHED THEN INSERT (
    site_code, equip_id, equip_category, orig_src_id, equip_status_event_sk,
    shift_id, cycle_id, status_event_reason_id,
    start_ts_utc, end_ts_utc, start_ts_local, end_ts_local,
    duration_mins, event_comments, distinct_status_event_flag,
    prev_status_event_id, next_status_event_id, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.site_code, src.equip_id, src.equip_category, src.orig_src_id, src.equip_status_event_sk,
    src.shift_id, src.cycle_id, src.status_event_reason_id,
    src.start_ts_utc, src.end_ts_utc, src.start_ts_local, src.end_ts_local,
    src.duration_mins, src.event_comments, src.distinct_status_event_flag,
    src.prev_status_event_id, src.next_status_event_id, src.system_version,
    src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

sql_delete = `UPDATE {{ envi }}_API_REF.fuse.lh_equipment_status_event_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.load_haul.lh_equipment_status_event src
                  WHERE src.equip_status_event_sk = tgt.equip_status_event_sk);`;

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
