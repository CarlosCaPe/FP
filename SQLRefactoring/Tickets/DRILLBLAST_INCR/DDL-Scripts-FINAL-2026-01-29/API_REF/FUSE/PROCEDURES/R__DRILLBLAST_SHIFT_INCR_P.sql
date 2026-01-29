CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from DRILLBLAST_SHIFT into DRILLBLAST_SHIFT_INCR
* SOURCE    : {{ RO_PROD }}_WG.DRILL_BLAST.DRILLBLAST_SHIFT
* TARGET    : {{ envi }}_API_REF.FUSE.DRILLBLAST_SHIFT_INCR
* BUSINESS KEY: SITE_CODE, SHIFT_ID
* INCREMENTAL COLUMN: SHIFT_START_TS_LOCAL (per Vikas - matches dynamic table logic)
* HASH CHECK: TRUE DELTA DETECTION
* DATE: 2026-01-28 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.drillblast_shift_incr 
                  WHERE shift_start_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.drillblast_shift_incr 
                   WHERE shift_start_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.drillblast_shift_incr tgt
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
    WHERE shift_start_ts_local >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.site_code = src.site_code AND tgt.shift_id = src.shift_id

WHEN MATCHED AND HASH(src.shift_date, src.shift_name, src.shift_date_name, 
                      src.crew_name, src.shift_end_ts_local)
              <> HASH(tgt.shift_date, tgt.shift_name, tgt.shift_date_name, 
                      tgt.crew_name, tgt.shift_end_ts_local)
THEN UPDATE SET
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

sql_delete = `UPDATE {{ envi }}_API_REF.fuse.drillblast_shift_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.drill_blast.drillblast_shift src
                  WHERE src.site_code = tgt.site_code AND src.shift_id = tgt.shift_id);`;

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
