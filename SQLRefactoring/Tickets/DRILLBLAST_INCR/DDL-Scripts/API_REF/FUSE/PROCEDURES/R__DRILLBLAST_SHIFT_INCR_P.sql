-- =============================================
-- Procedure: DRILLBLAST_SHIFT_INCR_P
-- Purpose: Incremental load with purging logic (Vikas fix - 2026-01-26)
-- Pattern: COUNT old → DELETE old (purge) → MERGE new
-- =============================================
CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3', "MAX_DAYS_TO_KEEP" VARCHAR(16777216) DEFAULT '90')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result = "";
var daysBack = NUMBER_OF_DAYS || 3;
var maxDays = MAX_DAYS_TO_KEEP || 90;
var rows_purged = 0;
var rows_merged = 0;

// STEP 1: COUNT old records to purge (older than MAX_DAYS_TO_KEEP)
var sql_count_incr = `SELECT COUNT(*) AS cnt FROM {{ envi }}_API_REF.fuse.drillblast_shift_incr 
                      WHERE dw_modify_ts < DATEADD(day, -` + maxDays + `, CURRENT_TIMESTAMP())`;

// STEP 2: DELETE old records (purge) - prevents unbounded table growth
var sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.drillblast_shift_incr 
                       WHERE dw_modify_ts < DATEADD(day, -` + maxDays + `, CURRENT_TIMESTAMP())`;

// STEP 3: MERGE new/updated records from source
var sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.drillblast_shift_incr tgt
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
    FROM {{ RO_PROD }}_WG.drill_blast.drillblast_shift
    WHERE dw_modify_ts >= DATEADD(day, -` + daysBack + `, CURRENT_TIMESTAMP())
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
    // Execute purge (DELETE old records)
    var rs_delete_incr = snowflake.execute({sqlText: sql_delete_incr});
    rows_purged = rs_delete_incr.getNumRowsAffected();
    
    // Execute merge
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    rows_merged = rs_merge.getNumRowsAffected();
    
    sp_result = "Purged: " + rows_purged + ", Merged: " + rows_merged + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';
