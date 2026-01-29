CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.DRILL_CYCLE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from DRILL_CYCLE into DRILL_CYCLE_INCR
* SOURCE    : {{ RO_PROD }}_WG.DRILL_BLAST.DRILL_CYCLE
* TARGET    : {{ envi }}_API_REF.FUSE.DRILL_CYCLE_INCR
* BUSINESS KEY: DRILL_CYCLE_SK
* INCREMENTAL COLUMN: CYCLE_START_TS_LOCAL (per Vikas - matches dynamic table logic)
* HASH CHECK: TRUE DELTA DETECTION
* DATE: 2026-01-28 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.drill_cycle_incr 
                  WHERE CYCLE_START_TS_LOCAL::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.drill_cycle_incr 
                   WHERE CYCLE_START_TS_LOCAL::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.drill_cycle_incr tgt
USING (
    SELECT *,
           ''N'' AS dw_logical_delete_flag_new,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts_new
    FROM {{ RO_PROD }}_WG.DRILL_BLAST.DRILL_CYCLE
    WHERE CYCLE_START_TS_LOCAL >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.DRILL_CYCLE_SK = src.DRILL_CYCLE_SK

WHEN MATCHED AND HASH(src.DRILL_HOLE_STATUS, src.ACTUAL_DRILL_HOLE_DEPTH_FEET, src.DRILL_DURATION, 
                      src.END_HOLE_TS_LOCAL, src.DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR)
              <> HASH(tgt.DRILL_HOLE_STATUS, tgt.ACTUAL_DRILL_HOLE_DEPTH_FEET, tgt.DRILL_DURATION, 
                      tgt.END_HOLE_TS_LOCAL, tgt.DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR)
THEN UPDATE SET
    tgt.ORIG_SRC_ID = src.ORIG_SRC_ID, tgt.SITE_CODE = src.SITE_CODE,
    tgt.BENCH = src.BENCH, tgt.PUSHBACK = src.PUSHBACK, tgt.PATTERN_NAME = src.PATTERN_NAME,
    tgt.DRILL_HOLE_STATUS = src.DRILL_HOLE_STATUS, tgt.DRILL_DURATION = src.DRILL_DURATION,
    tgt.ACTUAL_DRILL_HOLE_DEPTH_FEET = src.ACTUAL_DRILL_HOLE_DEPTH_FEET,
    tgt.END_HOLE_TS_LOCAL = src.END_HOLE_TS_LOCAL,
    tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ

WHEN NOT MATCHED THEN INSERT (
    DRILL_CYCLE_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, ORIGINAL_PATTERN_NAME,
    DRILL_HOLE_SHIFT_ID, DRILL_ID, DRILL_BIT_ID, SYSTEM_OPERATOR_ID, DRILL_HOLE_ID, DRILL_HOLE_NAME,
    DRILL_PLAN_SK, DRILL_HOLE_STATUS, IS_HOLE_PLANNED_FLAG,
    START_HOLE_TS_UTC, END_HOLE_TS_UTC, START_HOLE_TS_LOCAL, END_HOLE_TS_LOCAL,
    DRILL_HOLE_DURATION_SECONDS, DRILL_DURATION, ACTUAL_DRILL_HOLE_DEPTH_FEET, ACTUAL_DRILL_HOLE_DEPTH_METERS,
    DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR, SYSTEM_VERSION,
    DW_LOGICAL_DELETE_FLAG, DW_LOAD_TS, DW_MODIFY_TS
) VALUES (
    src.DRILL_CYCLE_SK, src.ORIG_SRC_ID, src.SITE_CODE, src.BENCH, src.PUSHBACK, src.PATTERN_NAME, src.ORIGINAL_PATTERN_NAME,
    src.DRILL_HOLE_SHIFT_ID, src.DRILL_ID, src.DRILL_BIT_ID, src.SYSTEM_OPERATOR_ID, src.DRILL_HOLE_ID, src.DRILL_HOLE_NAME,
    src.DRILL_PLAN_SK, src.DRILL_HOLE_STATUS, src.IS_HOLE_PLANNED_FLAG,
    src.START_HOLE_TS_UTC, src.END_HOLE_TS_UTC, src.START_HOLE_TS_LOCAL, src.END_HOLE_TS_LOCAL,
    src.DRILL_HOLE_DURATION_SECONDS, src.DRILL_DURATION, src.ACTUAL_DRILL_HOLE_DEPTH_FEET, src.ACTUAL_DRILL_HOLE_DEPTH_METERS,
    src.DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR, src.SYSTEM_VERSION,
    src.dw_logical_delete_flag_new, src.dw_load_ts_new, CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
);`;

sql_delete = `UPDATE {{ envi }}_API_REF.fuse.drill_cycle_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.DRILL_BLAST.DRILL_CYCLE src
                  WHERE src.DRILL_CYCLE_SK = tgt.DRILL_CYCLE_SK);`;

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
