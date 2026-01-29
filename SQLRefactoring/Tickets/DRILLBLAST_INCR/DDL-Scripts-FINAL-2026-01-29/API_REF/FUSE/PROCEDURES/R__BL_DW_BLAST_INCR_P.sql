CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.BL_DW_BLAST_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from BL_DW_BLAST into BL_DW_BLAST_INCR
* SOURCE    : {{ RO_PROD }}_WG.DRILL_BLAST.BL_DW_BLAST
* TARGET    : {{ envi }}_API_REF.FUSE.BL_DW_BLAST_INCR
* BUSINESS KEY: ORIG_SRC_ID, SITE_CODE, ID
* INCREMENTAL COLUMN: FIREDTIME (Business timestamp - blast execution time)
* DATE: 2026-01-29 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.bl_dw_blast_incr 
                  WHERE firedtime::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.bl_dw_blast_incr 
                   WHERE firedtime::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.bl_dw_blast_incr tgt
USING (
    SELECT
        orig_src_id, site_code, id, name, status,
        firedtime, abandonedtime, abandonedcomment,
        suspendedtime, suspendedcomment, volume,
        holecount, shotfirername, refreshedtime, deleted,
        dw_file_ts_utc,
        ''N'' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        dw_modify_ts
    FROM {{ RO_PROD }}_WG.drill_blast.bl_dw_blast
    WHERE firedtime >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src

ON tgt.orig_src_id = src.orig_src_id 
   AND tgt.site_code = src.site_code 
   AND tgt.id = src.id

WHEN MATCHED AND HASH(src.name, src.status, src.firedtime, src.volume, src.holecount, src.deleted)
              <> HASH(tgt.name, tgt.status, tgt.firedtime, tgt.volume, tgt.holecount, tgt.deleted)
THEN UPDATE SET
    tgt.name = src.name, tgt.status = src.status,
    tgt.firedtime = src.firedtime, tgt.abandonedtime = src.abandonedtime,
    tgt.abandonedcomment = src.abandonedcomment, tgt.suspendedtime = src.suspendedtime,
    tgt.suspendedcomment = src.suspendedcomment, tgt.volume = src.volume,
    tgt.holecount = src.holecount, tgt.shotfirername = src.shotfirername,
    tgt.refreshedtime = src.refreshedtime, tgt.deleted = src.deleted,
    tgt.dw_file_ts_utc = src.dw_file_ts_utc, tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ

WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, id, name, status, firedtime, abandonedtime,
    abandonedcomment, suspendedtime, suspendedcomment, volume, holecount,
    shotfirername, refreshedtime, deleted, dw_file_ts_utc,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.id, src.name, src.status, src.firedtime,
    src.abandonedtime, src.abandonedcomment, src.suspendedtime, src.suspendedcomment,
    src.volume, src.holecount, src.shotfirername, src.refreshedtime, src.deleted,
    src.dw_file_ts_utc, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

sql_delete = `UPDATE {{ envi }}_API_REF.fuse.bl_dw_blast_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (
                  SELECT 1 FROM {{ RO_PROD }}_WG.drill_blast.bl_dw_blast src
                  WHERE src.orig_src_id = tgt.orig_src_id 
                    AND src.site_code = tgt.site_code 
                    AND src.id = tgt.id
              );`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');

    if (rs_records_incr > 0) {
        rs_delete_incr = snowflake.execute({sqlText: sql_delete_incr});
        rs_deleted_records_incr = rs_delete_incr.getNumRowsAffected();
    } else {
        rs_deleted_records_incr = 0;
    }
    
    rs_merge = snowflake.execute({sqlText: sql_merge});
    rs_merged_records = rs_merge.getNumRowsAffected();
    
    rs_delete = snowflake.execute({sqlText: sql_delete});
    rs_delete_records = rs_delete.getNumRowsAffected();
    
    sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
}
catch (err) {
    snowflake.execute({sqlText: "ROLLBACK WORK;"});
    throw err;
}
';
