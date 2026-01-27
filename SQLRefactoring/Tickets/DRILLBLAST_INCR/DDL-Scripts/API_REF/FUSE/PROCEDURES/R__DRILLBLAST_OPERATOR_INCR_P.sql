CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from DRILLBLAST_OPERATOR into DRILLBLAST_OPERATOR_INCR
* SOURCE    : {{ RO_PROD }}_WG.DRILL_BLAST.DRILLBLAST_OPERATOR
* TARGET    : {{ envi }}_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR
* BUSINESS KEY: SYSTEM_OPERATOR_ID, SITE_CODE
* INCREMENTAL COLUMN: DW_MODIFY_TS
* DATE: 2026-01-23 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";

var sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                      FROM {{ envi }}_API_REF.fuse.drillblast_operator_incr 
                      WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.drillblast_operator_incr 
                       WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.drillblast_operator_incr tgt
USING (
    SELECT system_operator_id, site_code, orig_src_id, application_operator_id,
           operator_name, crew_id, crew_name, sap_operator_id,
           effective_start_date, end_date, system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts
    FROM {{ RO_PROD }}_WG.drill_blast.drillblast_operator
    WHERE dw_modify_ts::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src
ON tgt.system_operator_id = src.system_operator_id AND tgt.site_code = src.site_code
WHEN MATCHED AND HASH(src.operator_name, src.crew_id, src.crew_name, src.sap_operator_id, src.end_date)
              <> HASH(tgt.operator_name, tgt.crew_id, tgt.crew_name, tgt.sap_operator_id, tgt.end_date)
THEN UPDATE SET
    tgt.orig_src_id = src.orig_src_id, tgt.application_operator_id = src.application_operator_id,
    tgt.operator_name = src.operator_name, tgt.crew_id = src.crew_id,
    tgt.crew_name = src.crew_name, tgt.sap_operator_id = src.sap_operator_id,
    tgt.effective_start_date = src.effective_start_date, tgt.end_date = src.end_date,
    tgt.system_version = src.system_version, tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    system_operator_id, site_code, orig_src_id, application_operator_id, operator_name,
    crew_id, crew_name, sap_operator_id, effective_start_date, end_date, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.system_operator_id, src.site_code, src.orig_src_id, src.application_operator_id,
    src.operator_name, src.crew_id, src.crew_name, src.sap_operator_id,
    src.effective_start_date, src.end_date, src.system_version,
    src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

var sql_delete = `UPDATE {{ envi }}_API_REF.fuse.drillblast_operator_incr tgt
                  SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
                  WHERE tgt.dw_logical_delete_flag = ''N''
                  AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.drill_blast.drillblast_operator src
                      WHERE src.system_operator_id = tgt.system_operator_id AND src.site_code = tgt.site_code);`;

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
