-- =============================================================================
-- BL_DW_BLASTPROPERTYVALUE_INCR - Incremental Table and Procedure
-- Target: DEV_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR
-- =============================================================================
-- Source: PROD_WG.DRILL_BLAST.BL_DW_BLASTPROPERTYVALUE
-- Business Key: ORIG_SRC_ID, SITE_CODE, BLASTID
-- Timestamp: DW_MODIFY_TS | Date: 2026-01-23 | Author: Carlos Carrillo
-- =============================================================================

CREATE OR REPLACE TABLE DEV_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR (
    ORIG_SRC_ID                         NUMBER(19,0) NOT NULL,
    SITE_CODE                           VARCHAR(50) COLLATE 'en-ci' NOT NULL,
    BLASTID                             NUMBER(10,0) NOT NULL,
    REFRESHEDTIME                       TIMESTAMP_NTZ(9),
    DELETED                             BOOLEAN,
    PARAMETER                           VARCHAR(400) COLLATE 'en-ci',
    PLANNEDDATE                         VARCHAR(400) COLLATE 'en-ci',
    SHOTTYPE                            VARCHAR(400) COLLATE 'en-ci',
    SHOTGOAL                            VARCHAR(400) COLLATE 'en-ci',
    DW_FILE_TS_UTC                      TIMESTAMP_NTZ(9),
    DW_LOGICAL_DELETE_FLAG              VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
    DW_LOAD_TS                          TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                        TIMESTAMP_NTZ(0)
)
COMMENT = 'Incremental table for BL_DW_BLASTPROPERTYVALUE';

CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM dev_api_ref.fuse.bl_dw_blastpropertyvalue_incr 
                  WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM dev_api_ref.fuse.bl_dw_blastpropertyvalue_incr 
                   WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO dev_api_ref.fuse.bl_dw_blastpropertyvalue_incr tgt
USING (
    SELECT orig_src_id, site_code, blastid, refreshedtime, deleted,
           parameter, planneddate, shottype, shotgoal, dw_file_ts_utc,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts, dw_modify_ts
    FROM prod_wg.drill_blast.bl_dw_blastpropertyvalue
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.orig_src_id = src.orig_src_id AND tgt.site_code = src.site_code AND tgt.blastid = src.blastid
WHEN MATCHED AND HASH(src.parameter, src.planneddate, src.shottype, src.shotgoal, src.deleted)
              <> HASH(tgt.parameter, tgt.planneddate, tgt.shottype, tgt.shotgoal, tgt.deleted)
THEN UPDATE SET
    tgt.refreshedtime = src.refreshedtime, tgt.deleted = src.deleted,
    tgt.parameter = src.parameter, tgt.planneddate = src.planneddate,
    tgt.shottype = src.shottype, tgt.shotgoal = src.shotgoal,
    tgt.dw_file_ts_utc = src.dw_file_ts_utc, tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, blastid, refreshedtime, deleted, parameter,
    planneddate, shottype, shotgoal, dw_file_ts_utc, dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.blastid, src.refreshedtime, src.deleted, src.parameter,
    src.planneddate, src.shottype, src.shotgoal, src.dw_file_ts_utc, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

sql_delete = `UPDATE dev_api_ref.fuse.bl_dw_blastpropertyvalue_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM prod_wg.drill_blast.bl_dw_blastpropertyvalue src
                  WHERE src.orig_src_id = tgt.orig_src_id AND src.site_code = tgt.site_code AND src.blastid = tgt.blastid);`;

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

-- CALL DEV_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR_P('30');
