-- =============================================
-- Procedure: DRILL_CYCLE_INCR_P
-- Purpose: Incremental load with purging logic (Vikas fix - 2026-01-26)
-- Pattern: COUNT old → DELETE old (purge) → MERGE new
-- =============================================
CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.DRILL_CYCLE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3', "MAX_DAYS_TO_KEEP" VARCHAR(16777216) DEFAULT '90')
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
var sql_count_incr = `SELECT COUNT(*) AS cnt FROM {{ envi }}_API_REF.fuse.drill_cycle_incr 
                      WHERE DW_MODIFY_TS < DATEADD(day, -` + maxDays + `, CURRENT_TIMESTAMP())`;

// STEP 2: DELETE old records (purge) - prevents unbounded table growth
var sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.drill_cycle_incr 
                       WHERE DW_MODIFY_TS < DATEADD(day, -` + maxDays + `, CURRENT_TIMESTAMP())`;

// STEP 3: MERGE new/updated records from source
var sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.drill_cycle_incr tgt
USING (
    SELECT DRILL_CYCLE_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           DW_MODIFY_TS,
           ''N'' AS dw_logical_delete_flag,
           HASH(DRILL_CYCLE_SK, ORIG_SRC_ID, SITE_CODE) AS dw_row_hash
    FROM {{ RO_PROD }}_WG.DRILL_BLAST.DRILL_CYCLE
    WHERE DW_MODIFY_TS >= DATEADD(day, -` + daysBack + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.DRILL_CYCLE_SK = src.DRILL_CYCLE_SK
WHEN MATCHED THEN UPDATE SET
    tgt.ORIG_SRC_ID = src.ORIG_SRC_ID, tgt.SITE_CODE = src.SITE_CODE,
    tgt.BENCH = src.BENCH, tgt.PUSHBACK = src.PUSHBACK, tgt.PATTERN_NAME = src.PATTERN_NAME,
    tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, tgt.DW_ROW_HASH = src.dw_row_hash
WHEN NOT MATCHED THEN INSERT (DRILL_CYCLE_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME,
    DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG, DW_ROW_HASH)
VALUES (src.DRILL_CYCLE_SK, src.ORIG_SRC_ID, src.SITE_CODE, src.BENCH, src.PUSHBACK, src.PATTERN_NAME,
    src.dw_load_ts, CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, src.dw_logical_delete_flag, src.dw_row_hash);`;

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
