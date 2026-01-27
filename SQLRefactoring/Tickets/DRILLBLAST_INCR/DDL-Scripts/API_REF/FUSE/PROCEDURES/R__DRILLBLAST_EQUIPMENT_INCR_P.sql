CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from DRILLBLAST_EQUIPMENT into DRILLBLAST_EQUIPMENT_INCR
* SOURCE    : {{ RO_PROD }}_WG.DRILL_BLAST.DRILLBLAST_EQUIPMENT
* TARGET    : {{ envi }}_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR
* BUSINESS KEY: ORIG_SRC_ID, SITE_CODE, DRILL_ID
* INCREMENTAL COLUMN: DW_MODIFY_TS
* DATE: 2026-01-23 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";

var sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                      FROM {{ envi }}_API_REF.fuse.drillblast_equipment_incr 
                      WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.drillblast_equipment_incr 
                       WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.drillblast_equipment_incr tgt
USING (
    SELECT orig_src_id, site_code, drill_id, equip_name, equip_model,
           serial_number, equip_category, mem_equip_id, equip_unit_code,
           sap_equip_no, system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts
    FROM {{ RO_PROD }}_WG.drill_blast.drillblast_equipment
    WHERE dw_modify_ts::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src
ON tgt.orig_src_id = src.orig_src_id AND tgt.site_code = src.site_code AND tgt.drill_id = src.drill_id
WHEN MATCHED AND HASH(src.equip_name, src.equip_model, src.serial_number, src.equip_category, src.system_version)
              <> HASH(tgt.equip_name, tgt.equip_model, tgt.serial_number, tgt.equip_category, tgt.system_version)
THEN UPDATE SET
    tgt.equip_name = src.equip_name, tgt.equip_model = src.equip_model,
    tgt.serial_number = src.serial_number, tgt.equip_category = src.equip_category,
    tgt.mem_equip_id = src.mem_equip_id, tgt.equip_unit_code = src.equip_unit_code,
    tgt.sap_equip_no = src.sap_equip_no, tgt.system_version = src.system_version,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, drill_id, equip_name, equip_model, serial_number,
    equip_category, mem_equip_id, equip_unit_code, sap_equip_no, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.drill_id, src.equip_name, src.equip_model,
    src.serial_number, src.equip_category, src.mem_equip_id, src.equip_unit_code,
    src.sap_equip_no, src.system_version, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

var sql_delete = `UPDATE {{ envi }}_API_REF.fuse.drillblast_equipment_incr tgt
                  SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
                  WHERE tgt.dw_logical_delete_flag = ''N''
                  AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.drill_blast.drillblast_equipment src
                      WHERE src.orig_src_id = tgt.orig_src_id AND src.site_code = tgt.site_code AND src.drill_id = tgt.drill_id);`;

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
