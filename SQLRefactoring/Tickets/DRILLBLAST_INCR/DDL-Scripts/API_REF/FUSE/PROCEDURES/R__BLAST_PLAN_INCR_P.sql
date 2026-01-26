CREATE OR REPLACE PROCEDURE "BLAST_PLAN_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";
var daysBack = NUMBER_OF_DAYS || 3;

var sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.blast_plan_incr tgt
USING (
    SELECT BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           DW_MODIFY_TS,
           ''N'' AS dw_logical_delete_flag,
           HASH(BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE) AS dw_row_hash
    FROM {{ RO_PROD }}_WG.DRILL_BLAST.BLAST_PLAN
    WHERE DW_MODIFY_TS >= DATEADD(day, -` + daysBack + `, CURRENT_TIMESTAMP())
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

try {
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    sp_result = "Deleted: 0, Merged: " + rs_merged_records + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';
