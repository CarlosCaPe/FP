-- =============================================================================
-- LH_HAUL_CYCLE_INCR - Incremental Table and Procedure
-- Target: DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR
-- =============================================================================
-- Author: Carlos Carrillo (based on DRILLBLAST pattern by Hidayath)
-- Date: 2026-01-23
-- Pattern: MERGE-driven upserts with hash-based conditional updates
-- Incremental window: 3 days (default)
-- Description: Haulage cycle data - truck movements from load to dump
-- =============================================================================
-- Source: PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
-- Business Key: HAUL_CYCLE_ID
-- Timestamp for incremental: CYCLE_END_TS_LOCAL
-- =============================================================================
-- NOTE: This table has 340+ columns. For brevity, key columns are shown.
--       The full column list should be extracted from the source view.
-- =============================================================================


-- ============================================================================
-- STEP 1: CREATE INCR TABLE (Key columns shown - full DDL in production)
-- ============================================================================
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR (
    -- Primary/Business Keys
    HAUL_CYCLE_ID                       NUMBER(19,0) NOT NULL,    -- Business Key
    SITE_CODE                           VARCHAR(4) COLLATE 'en-ci',
    ORIG_SRC_ID                         NUMBER(38,0),
    
    -- Shift Information
    SHIFT_ID_AT_LOADING_END             VARCHAR(12) COLLATE 'en-ci',
    SHIFT_ID_AT_DUMP_END                VARCHAR(12) COLLATE 'en-ci',
    
    -- Material & Routing
    MATERIAL_ID                         NUMBER(19,0),
    ROUTING_SHAPE_ID                    NUMBER(19,0),
    
    -- Loading Location
    LOADING_LOC_ID                      NUMBER(19,0),
    LOADING_LOC_NAME                    VARCHAR(255) COLLATE 'en-ci',
    LOADING_LOC_COORD_X                 FLOAT,
    LOADING_LOC_COORD_Y                 FLOAT,
    LOADING_LOC_ELEV                    FLOAT,
    LOADING_METHOD                      VARCHAR(50) COLLATE 'en-ci',
    
    -- Dump Location
    DUMP_LOC_ID                         NUMBER(19,0),
    DUMP_LOC_NAME                       VARCHAR(255) COLLATE 'en-ci',
    DUMP_LOC_COORD_X                    FLOAT,
    DUMP_LOC_COORD_Y                    FLOAT,
    DUMP_LOC_ELEV                       FLOAT,
    
    -- Categories
    CATEGORY_MATERIAL                   VARCHAR(50) COLLATE 'en-ci',
    CATEGORY_SOURCE_DESTINATION         VARCHAR(100) COLLATE 'en-ci',
    
    -- Equipment IDs
    EXCAV_ID                            NUMBER(19,0),
    EXCAV_OPERATOR_ID                   NUMBER(19,0),
    TRUCK_ID                            NUMBER(19,0),
    TRUCK_LOADING_OPERATOR_ID           NUMBER(19,0),
    TRUCK_DUMPING_OPERATOR_ID           NUMBER(19,0),
    
    -- Payload Metrics
    REPORT_PAYLOAD_SHORT_TONS           NUMBER(38,6),
    NOMINAL_PAYLOAD_SHORT_TONS          NUMBER(38,6),
    MEASURED_PAYLOAD_METRIC_TONS        NUMBER(38,6),
    
    -- Flags
    AUTONOMOUS_FLAG                     NUMBER(1,0),
    OVERLOAD_FLAG                       NUMBER(1,0),
    
    -- Cycle Timestamps
    CYCLE_START_TS_UTC                  TIMESTAMP_NTZ(3),
    CYCLE_END_TS_UTC                    TIMESTAMP_NTZ(3),
    CYCLE_START_TS_LOCAL                TIMESTAMP_NTZ(3),
    CYCLE_END_TS_LOCAL                  TIMESTAMP_NTZ(3),       -- Incremental timestamp
    
    -- Empty Travel Phase
    EMPTY_TRAVEL_START_TS_UTC           TIMESTAMP_NTZ(3),
    EMPTY_TRAVEL_END_TS_UTC             TIMESTAMP_NTZ(3),
    EMPTY_TRAVEL_START_TS_LOCAL         TIMESTAMP_NTZ(3),
    EMPTY_TRAVEL_END_TS_LOCAL           TIMESTAMP_NTZ(3),
    EMPTY_TRAVEL_DURATION_MINS          NUMBER(38,6),
    EMPTY_TRAVEL_DISTANCE_FEET          NUMBER(38,6),
    EMPTY_TRAVEL_DISTANCE_METERS        NUMBER(38,6),
    
    -- Loading Phase
    LOADING_START_TS_UTC                TIMESTAMP_NTZ(3),
    LOADING_END_TS_UTC                  TIMESTAMP_NTZ(3),
    LOADING_START_TS_LOCAL              TIMESTAMP_NTZ(3),
    LOADING_END_TS_LOCAL                TIMESTAMP_NTZ(3),
    LOADING_DURATION_MINS               NUMBER(38,6),
    
    -- Full Travel Phase
    FULL_TRAVEL_START_TS_UTC            TIMESTAMP_NTZ(3),
    FULL_TRAVEL_END_TS_UTC              TIMESTAMP_NTZ(3),
    FULL_TRAVEL_START_TS_LOCAL          TIMESTAMP_NTZ(3),
    FULL_TRAVEL_END_TS_LOCAL            TIMESTAMP_NTZ(3),
    FULL_TRAVEL_DURATION_MINS           NUMBER(38,6),
    FULL_TRAVEL_DISTANCE_FEET           NUMBER(38,6),
    FULL_TRAVEL_DISTANCE_METERS         NUMBER(38,6),
    
    -- Dumping Phase
    DUMPING_START_TS_UTC                TIMESTAMP_NTZ(3),
    DUMPING_END_TS_UTC                  TIMESTAMP_NTZ(3),
    DUMPING_START_TS_LOCAL              TIMESTAMP_NTZ(3),
    DUMPING_END_TS_LOCAL                TIMESTAMP_NTZ(3),
    DUMPING_DURATION_MINS               NUMBER(38,6),
    
    -- Cycle Metrics
    CYCLE_DURATION_MINS                 NUMBER(38,6),
    DELTA_C_MINS                        NUMBER(38,6),
    
    -- Fuel
    FUEL_USED_IN_CYCLE_GALLONS          NUMBER(38,6),
    
    -- Grade Metrics (sample - there are many more)
    TCU_PCT                             NUMBER(38,6),
    XCU_PCT                             NUMBER(38,6),
    INSOL_PCT                           NUMBER(38,6),
    
    -- System
    SYSTEM_VERSION                      VARCHAR(50) COLLATE 'en-ci',
    
    -- Audit Columns
    DW_LOGICAL_DELETE_FLAG              VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
    DW_LOAD_TS                          TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                        TIMESTAMP_NTZ(0)
)
COMMENT = 'Incremental table for LH_HAUL_CYCLE - MERGE-driven upserts with 3-day incremental window';


-- ============================================================================
-- STEP 2: CREATE INCR PROCEDURE
-- ============================================================================
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : The LH_HAUL_CYCLE_INCR_P procedure merges data from LH_HAUL_CYCLE
*             into the LH_HAUL_CYCLE_INCR incremental table.
*             Processes data from last 3 days (default), max 30 days.
*
* NOTES     : IROC project - Incremental table for Snowflake to SQL sync
*             using high watermark strategy.
*
* USAGE     : CALL DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P(''3'');
*
* SOURCE    : PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
* TARGET    : DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR
* BUSINESS KEY: HAUL_CYCLE_ID
* INCREMENTAL COLUMN: CYCLE_END_TS_LOCAL
*
* CREATE/CHANGE LOG :
* DATE                     MOD BY                GCC                         DESC
*------------------------------------------------------------------------------------------
* 2026-01-23:             CARLOS CARRILLO       IROC Incremental            Initial Version
******************************************************************************************/

var sp_result="";
var sql_count_incr="";
var rs_count_incr="";
var rs_records_incr="";
var sql_delete_incr="";
var rs_delete_incr="";
var rs_deleted_records_incr="";
var sql_merge="";
var rs_merge="";
var rs_merged_records=""
var sql_delete="";
var rs_delete="";
var rs_delete_records="";

// Count records outside the lookback window
sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM dev_api_ref.fuse.lh_haul_cycle_incr 
                  WHERE cycle_end_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// Delete records outside the lookback window
sql_delete_incr = `DELETE FROM dev_api_ref.fuse.lh_haul_cycle_incr 
                   WHERE cycle_end_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// MERGE: Upsert new/changed records
sql_merge = `MERGE INTO dev_api_ref.fuse.lh_haul_cycle_incr tgt
USING (
    SELECT
        haul_cycle_id,
        site_code,
        orig_src_id,
        shift_id_at_loading_end,
        shift_id_at_dump_end,
        material_id,
        routing_shape_id,
        loading_loc_id,
        loading_loc_name,
        loading_loc_coord_x,
        loading_loc_coord_y,
        loading_loc_elev,
        loading_method,
        dump_loc_id,
        dump_loc_name,
        dump_loc_coord_x,
        dump_loc_coord_y,
        dump_loc_elev,
        category_material,
        category_source_destination,
        excav_id,
        excav_operator_id,
        truck_id,
        truck_loading_operator_id,
        truck_dumping_operator_id,
        report_payload_short_tons,
        nominal_payload_short_tons,
        measured_payload_metric_tons,
        autonomous_flag,
        overload_flag,
        cycle_start_ts_utc,
        cycle_end_ts_utc,
        cycle_start_ts_local,
        cycle_end_ts_local,
        empty_travel_start_ts_utc,
        empty_travel_end_ts_utc,
        empty_travel_start_ts_local,
        empty_travel_end_ts_local,
        empty_travel_duration_mins,
        empty_travel_distance_feet,
        empty_travel_distance_meters,
        loading_start_ts_utc,
        loading_end_ts_utc,
        loading_start_ts_local,
        loading_end_ts_local,
        loading_duration_mins,
        full_travel_start_ts_utc,
        full_travel_end_ts_utc,
        full_travel_start_ts_local,
        full_travel_end_ts_local,
        full_travel_duration_mins,
        full_travel_distance_feet,
        full_travel_distance_meters,
        dumping_start_ts_utc,
        dumping_end_ts_utc,
        dumping_start_ts_local,
        dumping_end_ts_local,
        dumping_duration_mins,
        cycle_duration_mins,
        delta_c_mins,
        fuel_used_in_cycle_gallons,
        tcu_pct,
        xcu_pct,
        insol_pct,
        system_version,
        ''N'' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_modify_ts
    FROM prod_wg.load_haul.lh_haul_cycle
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src

ON tgt.haul_cycle_id = src.haul_cycle_id

WHEN MATCHED AND HASH(
    src.site_code,
    src.orig_src_id,
    src.shift_id_at_loading_end,
    src.shift_id_at_dump_end,
    src.material_id,
    src.routing_shape_id,
    src.loading_loc_id,
    src.loading_loc_name,
    src.dump_loc_id,
    src.dump_loc_name,
    src.excav_id,
    src.truck_id,
    src.report_payload_short_tons,
    src.nominal_payload_short_tons,
    src.measured_payload_metric_tons,
    src.cycle_start_ts_utc,
    src.cycle_end_ts_utc,
    src.cycle_duration_mins,
    src.system_version
) <> HASH(
    tgt.site_code,
    tgt.orig_src_id,
    tgt.shift_id_at_loading_end,
    tgt.shift_id_at_dump_end,
    tgt.material_id,
    tgt.routing_shape_id,
    tgt.loading_loc_id,
    tgt.loading_loc_name,
    tgt.dump_loc_id,
    tgt.dump_loc_name,
    tgt.excav_id,
    tgt.truck_id,
    tgt.report_payload_short_tons,
    tgt.nominal_payload_short_tons,
    tgt.measured_payload_metric_tons,
    tgt.cycle_start_ts_utc,
    tgt.cycle_end_ts_utc,
    tgt.cycle_duration_mins,
    tgt.system_version
) THEN UPDATE SET
    tgt.site_code = src.site_code,
    tgt.orig_src_id = src.orig_src_id,
    tgt.shift_id_at_loading_end = src.shift_id_at_loading_end,
    tgt.shift_id_at_dump_end = src.shift_id_at_dump_end,
    tgt.material_id = src.material_id,
    tgt.routing_shape_id = src.routing_shape_id,
    tgt.loading_loc_id = src.loading_loc_id,
    tgt.loading_loc_name = src.loading_loc_name,
    tgt.loading_loc_coord_x = src.loading_loc_coord_x,
    tgt.loading_loc_coord_y = src.loading_loc_coord_y,
    tgt.loading_loc_elev = src.loading_loc_elev,
    tgt.loading_method = src.loading_method,
    tgt.dump_loc_id = src.dump_loc_id,
    tgt.dump_loc_name = src.dump_loc_name,
    tgt.dump_loc_coord_x = src.dump_loc_coord_x,
    tgt.dump_loc_coord_y = src.dump_loc_coord_y,
    tgt.dump_loc_elev = src.dump_loc_elev,
    tgt.category_material = src.category_material,
    tgt.category_source_destination = src.category_source_destination,
    tgt.excav_id = src.excav_id,
    tgt.excav_operator_id = src.excav_operator_id,
    tgt.truck_id = src.truck_id,
    tgt.truck_loading_operator_id = src.truck_loading_operator_id,
    tgt.truck_dumping_operator_id = src.truck_dumping_operator_id,
    tgt.report_payload_short_tons = src.report_payload_short_tons,
    tgt.nominal_payload_short_tons = src.nominal_payload_short_tons,
    tgt.measured_payload_metric_tons = src.measured_payload_metric_tons,
    tgt.autonomous_flag = src.autonomous_flag,
    tgt.overload_flag = src.overload_flag,
    tgt.cycle_start_ts_utc = src.cycle_start_ts_utc,
    tgt.cycle_end_ts_utc = src.cycle_end_ts_utc,
    tgt.cycle_start_ts_local = src.cycle_start_ts_local,
    tgt.cycle_end_ts_local = src.cycle_end_ts_local,
    tgt.empty_travel_start_ts_utc = src.empty_travel_start_ts_utc,
    tgt.empty_travel_end_ts_utc = src.empty_travel_end_ts_utc,
    tgt.empty_travel_start_ts_local = src.empty_travel_start_ts_local,
    tgt.empty_travel_end_ts_local = src.empty_travel_end_ts_local,
    tgt.empty_travel_duration_mins = src.empty_travel_duration_mins,
    tgt.empty_travel_distance_feet = src.empty_travel_distance_feet,
    tgt.empty_travel_distance_meters = src.empty_travel_distance_meters,
    tgt.loading_start_ts_utc = src.loading_start_ts_utc,
    tgt.loading_end_ts_utc = src.loading_end_ts_utc,
    tgt.loading_start_ts_local = src.loading_start_ts_local,
    tgt.loading_end_ts_local = src.loading_end_ts_local,
    tgt.loading_duration_mins = src.loading_duration_mins,
    tgt.full_travel_start_ts_utc = src.full_travel_start_ts_utc,
    tgt.full_travel_end_ts_utc = src.full_travel_end_ts_utc,
    tgt.full_travel_start_ts_local = src.full_travel_start_ts_local,
    tgt.full_travel_end_ts_local = src.full_travel_end_ts_local,
    tgt.full_travel_duration_mins = src.full_travel_duration_mins,
    tgt.full_travel_distance_feet = src.full_travel_distance_feet,
    tgt.full_travel_distance_meters = src.full_travel_distance_meters,
    tgt.dumping_start_ts_utc = src.dumping_start_ts_utc,
    tgt.dumping_end_ts_utc = src.dumping_end_ts_utc,
    tgt.dumping_start_ts_local = src.dumping_start_ts_local,
    tgt.dumping_end_ts_local = src.dumping_end_ts_local,
    tgt.dumping_duration_mins = src.dumping_duration_mins,
    tgt.cycle_duration_mins = src.cycle_duration_mins,
    tgt.delta_c_mins = src.delta_c_mins,
    tgt.fuel_used_in_cycle_gallons = src.fuel_used_in_cycle_gallons,
    tgt.tcu_pct = src.tcu_pct,
    tgt.xcu_pct = src.xcu_pct,
    tgt.insol_pct = src.insol_pct,
    tgt.system_version = src.system_version,
    tgt.dw_modify_ts = src.dw_modify_ts

WHEN NOT MATCHED THEN INSERT (
    haul_cycle_id,
    site_code,
    orig_src_id,
    shift_id_at_loading_end,
    shift_id_at_dump_end,
    material_id,
    routing_shape_id,
    loading_loc_id,
    loading_loc_name,
    loading_loc_coord_x,
    loading_loc_coord_y,
    loading_loc_elev,
    loading_method,
    dump_loc_id,
    dump_loc_name,
    dump_loc_coord_x,
    dump_loc_coord_y,
    dump_loc_elev,
    category_material,
    category_source_destination,
    excav_id,
    excav_operator_id,
    truck_id,
    truck_loading_operator_id,
    truck_dumping_operator_id,
    report_payload_short_tons,
    nominal_payload_short_tons,
    measured_payload_metric_tons,
    autonomous_flag,
    overload_flag,
    cycle_start_ts_utc,
    cycle_end_ts_utc,
    cycle_start_ts_local,
    cycle_end_ts_local,
    empty_travel_start_ts_utc,
    empty_travel_end_ts_utc,
    empty_travel_start_ts_local,
    empty_travel_end_ts_local,
    empty_travel_duration_mins,
    empty_travel_distance_feet,
    empty_travel_distance_meters,
    loading_start_ts_utc,
    loading_end_ts_utc,
    loading_start_ts_local,
    loading_end_ts_local,
    loading_duration_mins,
    full_travel_start_ts_utc,
    full_travel_end_ts_utc,
    full_travel_start_ts_local,
    full_travel_end_ts_local,
    full_travel_duration_mins,
    full_travel_distance_feet,
    full_travel_distance_meters,
    dumping_start_ts_utc,
    dumping_end_ts_utc,
    dumping_start_ts_local,
    dumping_end_ts_local,
    dumping_duration_mins,
    cycle_duration_mins,
    delta_c_mins,
    fuel_used_in_cycle_gallons,
    tcu_pct,
    xcu_pct,
    insol_pct,
    system_version,
    dw_logical_delete_flag,
    dw_load_ts,
    dw_modify_ts
) VALUES (
    src.haul_cycle_id,
    src.site_code,
    src.orig_src_id,
    src.shift_id_at_loading_end,
    src.shift_id_at_dump_end,
    src.material_id,
    src.routing_shape_id,
    src.loading_loc_id,
    src.loading_loc_name,
    src.loading_loc_coord_x,
    src.loading_loc_coord_y,
    src.loading_loc_elev,
    src.loading_method,
    src.dump_loc_id,
    src.dump_loc_name,
    src.dump_loc_coord_x,
    src.dump_loc_coord_y,
    src.dump_loc_elev,
    src.category_material,
    src.category_source_destination,
    src.excav_id,
    src.excav_operator_id,
    src.truck_id,
    src.truck_loading_operator_id,
    src.truck_dumping_operator_id,
    src.report_payload_short_tons,
    src.nominal_payload_short_tons,
    src.measured_payload_metric_tons,
    src.autonomous_flag,
    src.overload_flag,
    src.cycle_start_ts_utc,
    src.cycle_end_ts_utc,
    src.cycle_start_ts_local,
    src.cycle_end_ts_local,
    src.empty_travel_start_ts_utc,
    src.empty_travel_end_ts_utc,
    src.empty_travel_start_ts_local,
    src.empty_travel_end_ts_local,
    src.empty_travel_duration_mins,
    src.empty_travel_distance_feet,
    src.empty_travel_distance_meters,
    src.loading_start_ts_utc,
    src.loading_end_ts_utc,
    src.loading_start_ts_local,
    src.loading_end_ts_local,
    src.loading_duration_mins,
    src.full_travel_start_ts_utc,
    src.full_travel_end_ts_utc,
    src.full_travel_start_ts_local,
    src.full_travel_end_ts_local,
    src.full_travel_duration_mins,
    src.full_travel_distance_feet,
    src.full_travel_distance_meters,
    src.dumping_start_ts_utc,
    src.dumping_end_ts_utc,
    src.dumping_start_ts_local,
    src.dumping_end_ts_local,
    src.dumping_duration_mins,
    src.cycle_duration_mins,
    src.delta_c_mins,
    src.fuel_used_in_cycle_gallons,
    src.tcu_pct,
    src.xcu_pct,
    src.insol_pct,
    src.system_version,
    src.dw_logical_delete_flag,
    src.dw_load_ts,
    src.dw_modify_ts
);`;

// Soft delete: Mark records no longer in source
sql_delete = `UPDATE dev_api_ref.fuse.lh_haul_cycle_incr tgt
              SET dw_logical_delete_flag = ''Y'',
                  dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (
                  SELECT 1
                  FROM prod_wg.load_haul.lh_haul_cycle src
                  WHERE src.haul_cycle_id = tgt.haul_cycle_id
              );`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});

    rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    var rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');

    if (rs_records_incr > 0) {
        rs_delete_incr = snowflake.execute({sqlText: sql_delete_incr});
        rs_deleted_records_incr = rs_delete_incr.getNumRowsAffected();
        
        rs_merge = snowflake.execute({sqlText: sql_merge});
        rs_merged_records = rs_merge.getNumRowsAffected();
        
        rs_delete = snowflake.execute({sqlText: sql_delete});
        rs_delete_records = rs_delete.getNumRowsAffected();
        
        sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    } else {
        rs_merge = snowflake.execute({sqlText: sql_merge});
        rs_merged_records = rs_merge.getNumRowsAffected();
        
        rs_delete = snowflake.execute({sqlText: sql_delete});
        rs_delete_records = rs_delete.getNumRowsAffected();
        
        sp_result = "Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    }

    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
}
catch (err) {
    snowflake.execute({sqlText: "ROLLBACK WORK;"});
    throw err;
}
return sp_result;
';


-- ============================================================================
-- TESTING QUERIES
-- ============================================================================
-- Initial load (30 days):
-- CALL DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P('30');

-- Regular refresh (3 days):
-- CALL DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P('3');

-- Verify row counts:
-- SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR;

-- Compare with source:
-- SELECT COUNT(*) FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE_V
-- WHERE cycle_end_ts_local::date >= DATEADD(day, -3, CURRENT_DATE());

-- Check logical deletes:
-- SELECT dw_logical_delete_flag, COUNT(*) 
-- FROM DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR 
-- GROUP BY dw_logical_delete_flag;


-- ============================================================================
-- NOTE: This is a simplified version with ~70 key columns.
-- The actual LH_HAUL_CYCLE_V has 340+ columns.
-- 
-- To get the full column list, run:
-- SELECT COLUMN_NAME, DATA_TYPE, NUMERIC_PRECISION, NUMERIC_SCALE
-- FROM PROD_WG.INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_SCHEMA = 'LOAD_HAUL' AND TABLE_NAME = 'LH_HAUL_CYCLE_V'
-- ORDER BY ORDINAL_POSITION;
--
-- Then update this DDL with all columns before production deployment.
-- ============================================================================
