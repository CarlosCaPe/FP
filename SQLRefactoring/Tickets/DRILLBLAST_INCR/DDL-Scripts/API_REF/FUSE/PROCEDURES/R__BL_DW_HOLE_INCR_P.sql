CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.BL_DW_HOLE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from BL_DW_HOLE into BL_DW_HOLE_INCR
* SOURCE    : {{ RO_PROD }}_WG.DRILL_BLAST.BL_DW_HOLE
* TARGET    : {{ envi }}_API_REF.FUSE.BL_DW_HOLE_INCR
* BUSINESS KEY: ORIG_SRC_ID, SITE_CODE, ID
* INCREMENTAL COLUMN: DW_MODIFY_TS
* DATE: 2026-01-23 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.bl_dw_hole_incr 
                  WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.bl_dw_hole_incr 
                   WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.bl_dw_hole_incr tgt
USING (
    SELECT orig_src_id, site_code, id, name, modified_name, blastname, modified_blastname, 
           blastid, "ROW" AS hole_row, echelon, status, lastknowndepth, lastknownwater, 
           lastknownwetsides, lastknowntemperature, lastknowntemperaturetime,
           previoustemperature, previoustemperaturetime, temperaturerateofchange,
           designtime, drilledtime, lastdipdepth, lastdippedtime,
           lastbackfillingdipdepth, lastbackfillingdiptime, lastchargingdipdepth, lastchargingdiptime,
           chargedtime, firedtime, abandonedtime, abandonedcomment, misfire, misfirecomment,
           redrillofholeid, redrillofholename, isadhoc,
           designcollarx, designcollary, designcollarz, designangle, designbearing, designdepth,
           designdiameter, designburden, designspacing, actualcollarx, actualcollary, actualcollarz,
           targetchargedepth, plannedprimercount, loadedprimercount, loadedexplosivedeckcount,
           dippedoutsidechargedepthtolerance, chargedoutsidemasstolerance, drilledoutsidecollartolerance,
           topmoststemmingdeckloaded, stemmedoutsidelengthtolerance,
           explosivemassdesigned, explosivemassloaded, explosivemassreconciled,
           stemminglengthdesigned, stemminglengthloaded, stemminglengthreconciled,
           designtieupcount, actualtieupcount, designdrillcost, chargestandoff, chargestandoffdirection,
           refreshedtime, deleted, dw_file_ts_utc,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts_new,
           dw_modify_ts
    FROM {{ RO_PROD }}_WG.drill_blast.bl_dw_hole
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.orig_src_id = src.orig_src_id AND tgt.site_code = src.site_code AND tgt.id = src.id
WHEN MATCHED AND HASH(src.name, src.status, src.blastid, src.lastknowndepth, src.designdepth, src.deleted)
              <> HASH(tgt.name, tgt.status, tgt.blastid, tgt.lastknowndepth, tgt.designdepth, tgt.deleted)
THEN UPDATE SET
    tgt.name = src.name, tgt.modified_name = src.modified_name,
    tgt.blastname = src.blastname, tgt.modified_blastname = src.modified_blastname,
    tgt.blastid = src.blastid, tgt."ROW" = src.hole_row, tgt.echelon = src.echelon, tgt.status = src.status,
    tgt.lastknowndepth = src.lastknowndepth, tgt.deleted = src.deleted,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, id, name, modified_name, blastname, modified_blastname, blastid, "ROW", echelon, status,
    lastknowndepth, deleted, dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.id, src.name, src.modified_name, src.blastname, src.modified_blastname,
    src.blastid, src.hole_row, src.echelon, src.status, src.lastknowndepth, src.deleted, 
    src.dw_logical_delete_flag, src.dw_load_ts_new, src.dw_modify_ts
);`;

sql_delete = `UPDATE {{ envi }}_API_REF.fuse.bl_dw_hole_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.drill_blast.bl_dw_hole src
                  WHERE src.orig_src_id = tgt.orig_src_id AND src.site_code = tgt.site_code AND src.id = tgt.id);`;

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
