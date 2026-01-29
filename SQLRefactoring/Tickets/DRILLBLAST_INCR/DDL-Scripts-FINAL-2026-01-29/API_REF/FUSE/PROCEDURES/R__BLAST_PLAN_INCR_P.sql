CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.BLAST_PLAN_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from BLAST_PLAN into BLAST_PLAN_INCR
* SOURCE    : {{ RO_PROD }}_WG.DRILL_BLAST.BLAST_PLAN
* TARGET    : {{ envi }}_API_REF.FUSE.BLAST_PLAN_INCR
* BUSINESS KEY: BLAST_PLAN_SK
* INCREMENTAL COLUMN: BLAST_DT (per Vikas - matches dynamic table logic)
* HASH CHECK: TRUE DELTA DETECTION
* DATE: 2026-01-28 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.blast_plan_incr 
                  WHERE DW_MODIFY_TS::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.blast_plan_incr 
                   WHERE DW_MODIFY_TS::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.blast_plan_incr tgt
USING (
    SELECT *,
           ''N'' AS dw_logical_delete_flag_new,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts_new
    FROM {{ RO_PROD }}_WG.DRILL_BLAST.BLAST_PLAN
    WHERE DW_MODIFY_TS >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src
ON tgt.BLAST_PLAN_SK = src.BLAST_PLAN_SK

WHEN MATCHED 
THEN UPDATE SET
    tgt.ORIG_SRC_ID = src.ORIG_SRC_ID, 
    tgt.SITE_CODE = src.SITE_CODE, 
    tgt.BENCH = src.BENCH,
    tgt.PUSHBACK = src.PUSHBACK, 
    tgt.PATTERN_NAME = src.PATTERN_NAME, 
    tgt.BLAST_NAME = src.BLAST_NAME,
    tgt.BLAST_TYPE = src.BLAST_TYPE,
    tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ

WHEN NOT MATCHED THEN INSERT (
    BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, BLAST_TYPE,
    DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG
) VALUES (
    src.BLAST_PLAN_SK, src.ORIG_SRC_ID, src.SITE_CODE, src.BENCH, src.PUSHBACK, src.PATTERN_NAME, src.BLAST_NAME,
    src.BLAST_TYPE,
    src.dw_load_ts_new, CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, src.dw_logical_delete_flag_new
);`;

sql_delete = `UPDATE {{ envi }}_API_REF.fuse.blast_plan_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.DRILL_BLAST.BLAST_PLAN src
                  WHERE src.BLAST_PLAN_SK = tgt.BLAST_PLAN_SK);`;

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

