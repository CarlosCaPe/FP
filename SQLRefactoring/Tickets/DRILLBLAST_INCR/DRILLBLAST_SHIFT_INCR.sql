-- =============================================================================
-- DRILLBLAST_SHIFT_INCR - Incremental Table and Procedure
-- Target: DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR
-- =============================================================================
-- Source: PROD_WG.DRILL_BLAST.DRILLBLAST_SHIFT
-- Business Key: SITE_CODE, SHIFT_ID
-- Timestamp: DW_MODIFY_TS | Date: 2026-01-23 | Author: Carlos Carrillo
-- =============================================================================

CREATE OR REPLACE TABLE DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR (
    ORIG_SRC_ID                         NUMBER(10,0),
    SITE_CODE                           VARCHAR(5) COLLATE 'en-ci' NOT NULL,
    SHIFT_ID                            VARCHAR(500) COLLATE 'en-ci' NOT NULL,
    SHIFT_DATE                          DATE,
    SHIFT_NAME                          VARCHAR(255) COLLATE 'en-ci',
    SHIFT_DATE_NAME                     VARCHAR(255) COLLATE 'en-ci',
    ATTRIBUTED_CREW_ID                  NUMBER(19,0),
    CREW_NAME                           VARCHAR(255) COLLATE 'en-ci',
    SHIFT_NO                            NUMBER(10,0),
    SHIFT_START_TS_UTC                  TIMESTAMP_NTZ(9),
    SHIFT_END_TS_UTC                    TIMESTAMP_NTZ(9),
    SHIFT_START_TS_LOCAL                TIMESTAMP_NTZ(9),
    SHIFT_END_TS_LOCAL                  TIMESTAMP_NTZ(9),
    SYSTEM_VERSION                      VARCHAR(50) COLLATE 'en-ci',
    DW_LOGICAL_DELETE_FLAG              VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
    DW_LOAD_TS                          TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                        TIMESTAMP_NTZ(0)
)
COMMENT = 'Incremental table for DRILLBLAST_SHIFT';

CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                      FROM dev_api_ref.fuse.drillblast_shift_incr 
                      WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_delete_incr = `DELETE FROM dev_api_ref.fuse.drillblast_shift_incr 
                       WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_merge = `MERGE INTO dev_api_ref.fuse.drillblast_shift_incr tgt
USING (
    SELECT orig_src_id, site_code, shift_id, shift_date, shift_name,
           shift_date_name, attributed_crew_id, crew_name, shift_no,
           shift_start_ts_utc, shift_end_ts_utc, shift_start_ts_local, shift_end_ts_local,
           system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts
    FROM prod_wg.drill_blast.drillblast_shift
    WHERE dw_modify_ts::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src
ON tgt.site_code = src.site_code AND tgt.shift_id = src.shift_id
WHEN MATCHED AND HASH(src.shift_date, src.shift_name, src.crew_name, src.shift_no, src.shift_start_ts_utc, src.shift_end_ts_utc)
              <> HASH(tgt.shift_date, tgt.shift_name, tgt.crew_name, tgt.shift_no, tgt.shift_start_ts_utc, tgt.shift_end_ts_utc)
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

var sql_delete = `UPDATE dev_api_ref.fuse.drillblast_shift_incr tgt
                  SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
                  WHERE tgt.dw_logical_delete_flag = ''N''
                  AND NOT EXISTS (SELECT 1 FROM prod_wg.drill_blast.drillblast_shift src
                      WHERE src.site_code = tgt.site_code AND src.shift_id = tgt.shift_id);`;

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

-- CALL DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P('30');
