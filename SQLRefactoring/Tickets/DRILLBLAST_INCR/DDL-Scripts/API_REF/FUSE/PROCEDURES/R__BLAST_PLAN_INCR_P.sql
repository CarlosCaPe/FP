CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.BLAST_PLAN_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                      FROM {{ envi }}_API_REF.fuse.blast_plan_incr 
                      WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.blast_plan_incr 
                       WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.blast_plan_incr tgt
USING (
    SELECT BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           DW_MODIFY_TS,
           ''N'' AS dw_logical_delete_flag,
           HASH(BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE) AS dw_row_hash
    FROM {{ RO_PROD }}_WG.DRILL_BLAST.BLAST_PLAN
    WHERE DW_MODIFY_TS >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.BLAST_PLAN_SK = src.BLAST_PLAN_SK
WHEN MATCHED THEN UPDATE SET
    tgt.ORIG_SRC_ID = src.ORIG_SRC_ID, tgt.SITE_CODE = src.SITE_CODE, tgt.BENCH = src.BENCH,
    tgt.PUSHBACK = src.PUSHBACK, tgt.PATTERN_NAME = src.PATTERN_NAME, tgt.BLAST_NAME = src.BLAST_NAME,
    tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, tgt.DW_ROW_HASH = src.dw_row_hash
WHEN NOT MATCHED THEN INSERT (BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, 
    DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG, DW_ROW_HASH)
VALUES (src.BLAST_PLAN_SK, src.ORIG_SRC_ID, src.SITE_CODE, src.BENCH, src.PUSHBACK, src.PATTERN_NAME, src.BLAST_NAME,
    src.dw_load_ts, CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, src.dw_logical_delete_flag, src.dw_row_hash);`;

var sql_delete = `UPDATE {{ envi }}_API_REF.fuse.blast_plan_incr tgt
                  SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
                  WHERE tgt.dw_logical_delete_flag = ''N''
                  AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.DRILL_BLAST.BLAST_PLAN src
                      WHERE src.BLAST_PLAN_SK = tgt.BLAST_PLAN_SK);`;

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
