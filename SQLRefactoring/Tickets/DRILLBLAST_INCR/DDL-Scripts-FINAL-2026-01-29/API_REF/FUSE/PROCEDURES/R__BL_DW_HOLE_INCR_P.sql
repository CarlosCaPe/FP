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
* INCREMENTAL COLUMN: FIREDTIME (Business timestamp - hole firing time)
* COLUMNS: 73 (ALL columns - COMPLETE COVERAGE)
* DATE: 2026-01-29 | AUTHOR: CARLOS CARRILLO
* FIX: Complete 73-column coverage - NO columns omitted
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.bl_dw_hole_incr 
                  WHERE NVL(FIREDTIME, DW_MODIFY_TS)::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.bl_dw_hole_incr 
                   WHERE NVL(FIREDTIME, DW_MODIFY_TS)::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.bl_dw_hole_incr tgt
USING (
    SELECT *,
           ''N'' AS dw_logical_delete_flag_new,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts_new
    FROM {{ RO_PROD }}_WG.drill_blast.bl_dw_hole
    WHERE NVL(FIREDTIME, DW_MODIFY_TS) >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.orig_src_id = src.orig_src_id AND tgt.site_code = src.site_code AND tgt.id = src.id

WHEN MATCHED AND HASH(src.name, src.status, src.blastid, src.lastknowndepth, src.designdepth, 
                      src.deleted, src.firedtime, src.dw_modify_ts)
              <> HASH(tgt.name, tgt.status, tgt.blastid, tgt.lastknowndepth, tgt.designdepth, 
                      tgt.deleted, tgt.firedtime, tgt.dw_modify_ts)
THEN UPDATE SET
    tgt.name = src.name, tgt.modified_name = src.modified_name,
    tgt.blastname = src.blastname, tgt.modified_blastname = src.modified_blastname,
    tgt.blastid = src.blastid, tgt."ROW" = src."ROW", tgt.echelon = src.echelon, tgt.status = src.status,
    tgt.lastknowndepth = src.lastknowndepth, tgt.lastknownwater = src.lastknownwater,
    tgt.lastknownwetsides = src.lastknownwetsides, tgt.lastknowntemperature = src.lastknowntemperature,
    tgt.lastknowntemperaturetime = src.lastknowntemperaturetime, tgt.previoustemperature = src.previoustemperature,
    tgt.previoustemperaturetime = src.previoustemperaturetime, tgt.temperaturerateofchange = src.temperaturerateofchange,
    tgt.designtime = src.designtime, tgt.drilledtime = src.drilledtime,
    tgt.lastdipdepth = src.lastdipdepth, tgt.lastdippedtime = src.lastdippedtime,
    tgt.lastbackfillingdipdepth = src.lastbackfillingdipdepth, tgt.lastbackfillingdiptime = src.lastbackfillingdiptime,
    tgt.lastchargingdipdepth = src.lastchargingdipdepth, tgt.lastchargingdiptime = src.lastchargingdiptime,
    tgt.chargedtime = src.chargedtime, tgt.firedtime = src.firedtime,
    tgt.abandonedtime = src.abandonedtime, tgt.abandonedcomment = src.abandonedcomment,
    tgt.misfire = src.misfire, tgt.misfirecomment = src.misfirecomment,
    tgt.redrillofholeid = src.redrillofholeid, tgt.redrillofholename = src.redrillofholename,
    tgt.isadhoc = src.isadhoc,
    tgt.designcollarx = src.designcollarx, tgt.designcollary = src.designcollary, tgt.designcollarz = src.designcollarz,
    tgt.designangle = src.designangle, tgt.designbearing = src.designbearing, tgt.designdepth = src.designdepth,
    tgt.designdiameter = src.designdiameter, tgt.designburden = src.designburden, tgt.designspacing = src.designspacing,
    tgt.actualcollarx = src.actualcollarx, tgt.actualcollary = src.actualcollary, tgt.actualcollarz = src.actualcollarz,
    tgt.targetchargedepth = src.targetchargedepth, tgt.plannedprimercount = src.plannedprimercount,
    tgt.loadedprimercount = src.loadedprimercount, tgt.loadedexplosivedeckcount = src.loadedexplosivedeckcount,
    tgt.dippedoutsidechargedepthtolerance = src.dippedoutsidechargedepthtolerance,
    tgt.chargedoutsidemasstolerance = src.chargedoutsidemasstolerance,
    tgt.drilledoutsidecollartolerance = src.drilledoutsidecollartolerance,
    tgt.topmoststemmingdeckloaded = src.topmoststemmingdeckloaded,
    tgt.stemmedoutsidelengthtolerance = src.stemmedoutsidelengthtolerance,
    tgt.explosivemassdesigned = src.explosivemassdesigned, tgt.explosivemassloaded = src.explosivemassloaded,
    tgt.explosivemassreconciled = src.explosivemassreconciled,
    tgt.stemminglengthdesigned = src.stemminglengthdesigned, tgt.stemminglengthloaded = src.stemminglengthloaded,
    tgt.stemminglengthreconciled = src.stemminglengthreconciled,
    tgt.designtieupcount = src.designtieupcount, tgt.actualtieupcount = src.actualtieupcount,
    tgt.designdrillcost = src.designdrillcost, tgt.chargestandoff = src.chargestandoff,
    tgt.chargestandoffdirection = src.chargestandoffdirection, tgt.refreshedtime = src.refreshedtime,
    tgt.deleted = src.deleted, tgt.dw_file_ts_utc = src.dw_file_ts_utc,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ

WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, id, name, modified_name, blastname, modified_blastname, blastid, "ROW", echelon, status,
    lastknowndepth, lastknownwater, lastknownwetsides, lastknowntemperature, lastknowntemperaturetime,
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
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.id, src.name, src.modified_name, src.blastname, src.modified_blastname,
    src.blastid, src."ROW", src.echelon, src.status,
    src.lastknowndepth, src.lastknownwater, src.lastknownwetsides, src.lastknowntemperature, src.lastknowntemperaturetime,
    src.previoustemperature, src.previoustemperaturetime, src.temperaturerateofchange,
    src.designtime, src.drilledtime, src.lastdipdepth, src.lastdippedtime,
    src.lastbackfillingdipdepth, src.lastbackfillingdiptime, src.lastchargingdipdepth, src.lastchargingdiptime,
    src.chargedtime, src.firedtime, src.abandonedtime, src.abandonedcomment, src.misfire, src.misfirecomment,
    src.redrillofholeid, src.redrillofholename, src.isadhoc,
    src.designcollarx, src.designcollary, src.designcollarz, src.designangle, src.designbearing, src.designdepth,
    src.designdiameter, src.designburden, src.designspacing, src.actualcollarx, src.actualcollary, src.actualcollarz,
    src.targetchargedepth, src.plannedprimercount, src.loadedprimercount, src.loadedexplosivedeckcount,
    src.dippedoutsidechargedepthtolerance, src.chargedoutsidemasstolerance, src.drilledoutsidecollartolerance,
    src.topmoststemmingdeckloaded, src.stemmedoutsidelengthtolerance,
    src.explosivemassdesigned, src.explosivemassloaded, src.explosivemassreconciled,
    src.stemminglengthdesigned, src.stemminglengthloaded, src.stemminglengthreconciled,
    src.designtieupcount, src.actualtieupcount, src.designdrillcost, src.chargestandoff, src.chargestandoffdirection,
    src.refreshedtime, src.deleted, src.dw_file_ts_utc,
    src.dw_logical_delete_flag_new, src.dw_load_ts_new, CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
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

