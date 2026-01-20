-- =============================================================================
-- LH_LOADING_CYCLE_INCR - Incremental Table and Procedure
-- Target: DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR
-- =============================================================================
-- Author: Carlos Carrillo (based on DRILLBLAST_DRILL_CYCLE_CT_P pattern by Hidayath)
-- Date: 2026-01-20
-- Pattern: MERGE-driven upserts with hash-based conditional updates
-- Incremental window: 3 days (default)
-- Task schedule: Every 15 minutes
-- =============================================================================
-- Source: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE (VIEW)
-- Business Key: LOADING_CYCLE_ID
-- Timestamp for incremental: CYCLE_START_TS_LOCAL
-- =============================================================================


-- ============================================================================
-- STEP 1: CREATE INCR TABLE
-- ============================================================================
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR (
    LOADING_CYCLE_ID                    NUMBER(19,0),           -- Business Key
    SITE_CODE                           VARCHAR(4) COLLATE 'en-ci',
    ORIG_SRC_ID                         NUMBER(38,0),
    SHIFT_ID                            VARCHAR(12) COLLATE 'en-ci',
    LOADING_CYCLE_OF_SHIFT              NUMBER(38,0),
    EXCAV_CYCLE_OF_SHIFT                NUMBER(38,0),
    CYCLE_START_TS_UTC                  TIMESTAMP_NTZ(3),
    CYCLE_START_TS_LOCAL                TIMESTAMP_NTZ(3),       -- Incremental timestamp
    CYCLE_END_TS_UTC                    TIMESTAMP_NTZ(3),
    CYCLE_END_TS_LOCAL                  TIMESTAMP_NTZ(3),
    MEASURED_PAYLOAD_SHORT_TONS         NUMBER(38,6),
    MEASURED_PAYLOAD_METRIC_TONS        NUMBER(38,6),
    AVG_SWING_DURATION_MINS             NUMBER(38,6),
    AVG_DIG_DURATION_MINS               NUMBER(38,6),
    HANG_DURATION_MINS                  NUMBER(38,6),
    IDLE_DURATION_MINS                  NUMBER(38,6),
    BUCKET_COUNT                        NUMBER(38,0),
    EXCAV_ID                            NUMBER(19,0),
    TRUCK_ID                            NUMBER(19,0),
    EXCAV_OPERATOR_ID                   NUMBER(19,0),
    MATERIAL_ID                         NUMBER(19,0),
    LOADING_LOC_ID                      NUMBER(19,0),
    LOADING_CYCLE_DIG_ELEV_AVG_FEET     FLOAT,
    LOADING_CYCLE_DIG_ELEV_AVG_METERS   FLOAT,
    INTERRUPTED_LOADING_FLAG            NUMBER(1,0),
    ASSOCIATED_HAUL_CYCLE_FLAG          NUMBER(1,0),
    OVER_TRUCKED_FLAG                   NUMBER(1,0),
    UNDER_TRUCKED_FLAG                  NUMBER(1,0),
    HAUL_CYCLE_ID                       NUMBER(19,0),
    SYSTEM_VERSION                      VARCHAR(50) COLLATE 'en-ci',
    DW_LOGICAL_DELETE_FLAG              VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
    DW_LOAD_TS                          TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                        TIMESTAMP_NTZ(0)
)
COMMENT = 'Incremental table for LH_LOADING_CYCLE - MERGE-driven upserts with 3-day incremental window';


-- ============================================================================
-- STEP 2: CREATE INCR PROCEDURE
-- ============================================================================
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : The LH_LOADING_CYCLE_INCR_P procedure is designed to merge data from the 
*             LH_LOADING_CYCLE view into the LH_LOADING_CYCLE_INCR incremental table.
*             It processes data from the last 3 days by default, with the option to extend
*             up to a maximum of 30 days.
*
* NOTES     : As part of the IROC project, We are creating this incremental table and
*             it will process the incremental data from Snowflake to SQL
*             using the high watermark strategy. This procedure is helpful for the 
*             incremental and history data load up to 30 days from the source view
*             into the Incremental table.
*
* USAGE     : CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P(3);
*
* SOURCE    : PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
* TARGET    : DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR
* BUSINESS KEY: LOADING_CYCLE_ID
* INCREMENTAL COLUMN: CYCLE_START_TS_LOCAL
*
* CREATE/CHANGE LOG :
* DATE                     MOD BY                GCC                         DESC
*------------------------------------------------------------------------------------------
* 2026-01-20:             CARLOS CARRILLO       IROC Incremental            Initial Version
******************************************************************************************/

var sp_result="";
var number_of_days="";
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

// Count records outside the lookback window (to be deleted from INCR table)
sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM dev_api_ref.fuse.lh_loading_cycle_incr 
                  WHERE cycle_start_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// Delete records outside the lookback window
sql_delete_incr = `DELETE FROM dev_api_ref.fuse.lh_loading_cycle_incr 
                   WHERE cycle_start_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// MERGE: Upsert new/changed records using LOADING_CYCLE_ID as business key
sql_merge = `MERGE INTO dev_api_ref.fuse.lh_loading_cycle_incr tgt
USING (
    SELECT
        loading_cycle_id,
        site_code,
        orig_src_id,
        shift_id,
        loading_cycle_of_shift,
        excav_cycle_of_shift,
        cycle_start_ts_utc,
        cycle_start_ts_local,
        cycle_end_ts_utc,
        cycle_end_ts_local,
        measured_payload_short_tons,
        measured_payload_metric_tons,
        avg_swing_duration_mins,
        avg_dig_duration_mins,
        hang_duration_mins,
        idle_duration_mins,
        bucket_count,
        excav_id,
        truck_id,
        excav_operator_id,
        material_id,
        loading_loc_id,
        loading_cycle_dig_elev_avg_feet,
        loading_cycle_dig_elev_avg_meters,
        interrupted_loading_flag,
        associated_haul_cycle_flag,
        over_trucked_flag,
        under_trucked_flag,
        haul_cycle_id,
        system_version,
        ''N'' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_modify_ts
    FROM prod_wg.load_haul.lh_loading_cycle
    WHERE cycle_start_ts_local::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src

ON tgt.loading_cycle_id = src.loading_cycle_id

WHEN MATCHED AND HASH(
    src.site_code,
    src.orig_src_id,
    src.shift_id,
    src.loading_cycle_of_shift,
    src.excav_cycle_of_shift,
    src.cycle_start_ts_utc,
    src.cycle_start_ts_local,
    src.cycle_end_ts_utc,
    src.cycle_end_ts_local,
    src.measured_payload_short_tons,
    src.measured_payload_metric_tons,
    src.avg_swing_duration_mins,
    src.avg_dig_duration_mins,
    src.hang_duration_mins,
    src.idle_duration_mins,
    src.bucket_count,
    src.excav_id,
    src.truck_id,
    src.excav_operator_id,
    src.material_id,
    src.loading_loc_id,
    src.loading_cycle_dig_elev_avg_feet,
    src.loading_cycle_dig_elev_avg_meters,
    src.interrupted_loading_flag,
    src.associated_haul_cycle_flag,
    src.over_trucked_flag,
    src.under_trucked_flag,
    src.haul_cycle_id,
    src.system_version
) <> HASH(
    tgt.site_code,
    tgt.orig_src_id,
    tgt.shift_id,
    tgt.loading_cycle_of_shift,
    tgt.excav_cycle_of_shift,
    tgt.cycle_start_ts_utc,
    tgt.cycle_start_ts_local,
    tgt.cycle_end_ts_utc,
    tgt.cycle_end_ts_local,
    tgt.measured_payload_short_tons,
    tgt.measured_payload_metric_tons,
    tgt.avg_swing_duration_mins,
    tgt.avg_dig_duration_mins,
    tgt.hang_duration_mins,
    tgt.idle_duration_mins,
    tgt.bucket_count,
    tgt.excav_id,
    tgt.truck_id,
    tgt.excav_operator_id,
    tgt.material_id,
    tgt.loading_loc_id,
    tgt.loading_cycle_dig_elev_avg_feet,
    tgt.loading_cycle_dig_elev_avg_meters,
    tgt.interrupted_loading_flag,
    tgt.associated_haul_cycle_flag,
    tgt.over_trucked_flag,
    tgt.under_trucked_flag,
    tgt.haul_cycle_id,
    tgt.system_version
) THEN UPDATE SET
    tgt.site_code = src.site_code,
    tgt.orig_src_id = src.orig_src_id,
    tgt.shift_id = src.shift_id,
    tgt.loading_cycle_of_shift = src.loading_cycle_of_shift,
    tgt.excav_cycle_of_shift = src.excav_cycle_of_shift,
    tgt.cycle_start_ts_utc = src.cycle_start_ts_utc,
    tgt.cycle_start_ts_local = src.cycle_start_ts_local,
    tgt.cycle_end_ts_utc = src.cycle_end_ts_utc,
    tgt.cycle_end_ts_local = src.cycle_end_ts_local,
    tgt.measured_payload_short_tons = src.measured_payload_short_tons,
    tgt.measured_payload_metric_tons = src.measured_payload_metric_tons,
    tgt.avg_swing_duration_mins = src.avg_swing_duration_mins,
    tgt.avg_dig_duration_mins = src.avg_dig_duration_mins,
    tgt.hang_duration_mins = src.hang_duration_mins,
    tgt.idle_duration_mins = src.idle_duration_mins,
    tgt.bucket_count = src.bucket_count,
    tgt.excav_id = src.excav_id,
    tgt.truck_id = src.truck_id,
    tgt.excav_operator_id = src.excav_operator_id,
    tgt.material_id = src.material_id,
    tgt.loading_loc_id = src.loading_loc_id,
    tgt.loading_cycle_dig_elev_avg_feet = src.loading_cycle_dig_elev_avg_feet,
    tgt.loading_cycle_dig_elev_avg_meters = src.loading_cycle_dig_elev_avg_meters,
    tgt.interrupted_loading_flag = src.interrupted_loading_flag,
    tgt.associated_haul_cycle_flag = src.associated_haul_cycle_flag,
    tgt.over_trucked_flag = src.over_trucked_flag,
    tgt.under_trucked_flag = src.under_trucked_flag,
    tgt.haul_cycle_id = src.haul_cycle_id,
    tgt.system_version = src.system_version,
    tgt.dw_modify_ts = src.dw_modify_ts

WHEN NOT MATCHED THEN INSERT (
    loading_cycle_id,
    site_code,
    orig_src_id,
    shift_id,
    loading_cycle_of_shift,
    excav_cycle_of_shift,
    cycle_start_ts_utc,
    cycle_start_ts_local,
    cycle_end_ts_utc,
    cycle_end_ts_local,
    measured_payload_short_tons,
    measured_payload_metric_tons,
    avg_swing_duration_mins,
    avg_dig_duration_mins,
    hang_duration_mins,
    idle_duration_mins,
    bucket_count,
    excav_id,
    truck_id,
    excav_operator_id,
    material_id,
    loading_loc_id,
    loading_cycle_dig_elev_avg_feet,
    loading_cycle_dig_elev_avg_meters,
    interrupted_loading_flag,
    associated_haul_cycle_flag,
    over_trucked_flag,
    under_trucked_flag,
    haul_cycle_id,
    system_version,
    dw_logical_delete_flag,
    dw_load_ts,
    dw_modify_ts
) VALUES (
    src.loading_cycle_id,
    src.site_code,
    src.orig_src_id,
    src.shift_id,
    src.loading_cycle_of_shift,
    src.excav_cycle_of_shift,
    src.cycle_start_ts_utc,
    src.cycle_start_ts_local,
    src.cycle_end_ts_utc,
    src.cycle_end_ts_local,
    src.measured_payload_short_tons,
    src.measured_payload_metric_tons,
    src.avg_swing_duration_mins,
    src.avg_dig_duration_mins,
    src.hang_duration_mins,
    src.idle_duration_mins,
    src.bucket_count,
    src.excav_id,
    src.truck_id,
    src.excav_operator_id,
    src.material_id,
    src.loading_loc_id,
    src.loading_cycle_dig_elev_avg_feet,
    src.loading_cycle_dig_elev_avg_meters,
    src.interrupted_loading_flag,
    src.associated_haul_cycle_flag,
    src.over_trucked_flag,
    src.under_trucked_flag,
    src.haul_cycle_id,
    src.system_version,
    src.dw_logical_delete_flag,
    src.dw_load_ts,
    src.dw_modify_ts
);`;

// Soft delete: Mark records that no longer exist in source
sql_delete = `UPDATE dev_api_ref.fuse.lh_loading_cycle_incr tgt
              SET dw_logical_delete_flag = ''Y'',
                  dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (
                  SELECT 1
                  FROM prod_wg.load_haul.lh_loading_cycle src
                  WHERE src.loading_cycle_id = tgt.loading_cycle_id
              );`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});

    rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    var rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');

    if (rs_records_incr > 0) {
        // Delete old records outside lookback window
        rs_delete_incr = snowflake.execute({sqlText: sql_delete_incr});
        rs_deleted_records_incr = rs_delete_incr.getNumRowsAffected();
        
        // Merge new/updated records
        rs_merge = snowflake.execute({sqlText: sql_merge});
        rs_merged_records = rs_merge.getNumRowsAffected();
        
        // Soft delete archived records
        rs_delete = snowflake.execute({sqlText: sql_delete});
        rs_delete_records = rs_delete.getNumRowsAffected();
        
        sp_result = "Execution complete, deleted records from INCR table: " + rs_deleted_records_incr + 
                    ", merged records into INCR table: " + rs_merged_records + 
                    ", archived records in INCR table: " + rs_delete_records;
    } else {
        // No records to delete, just merge and archive
        rs_merge = snowflake.execute({sqlText: sql_merge});
        rs_merged_records = rs_merge.getNumRowsAffected();
        
        rs_delete = snowflake.execute({sqlText: sql_delete});
        rs_delete_records = rs_delete.getNumRowsAffected();
        
        sp_result = "Execution complete, merged records into INCR table: " + rs_merged_records + 
                    ", archived records in INCR table: " + rs_delete_records;
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
-- STEP 3: INITIAL LOAD (one-time backfill)
-- ============================================================================
-- Run with larger lookback for initial population
-- CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('30');


-- ============================================================================
-- STEP 4: CREATE TASK (every 15 minutes)
-- ============================================================================
CREATE OR REPLACE TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_T
    WAREHOUSE = 'WH_BATCH_DE_NONPROD'
    SCHEDULE = 'USING CRON */15 * * * * UTC'
    COMMENT = 'Refresh LH_LOADING_CYCLE_INCR every 15 minutes with 3-day lookback'
AS
    CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3');

-- Enable the task (run after testing)
-- ALTER TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_T RESUME;


-- ============================================================================
-- TESTING QUERIES
-- ============================================================================
-- Test procedure execution:
-- CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P('3');

-- Verify row counts:
-- SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR;
-- SELECT COUNT(*) FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE 
-- WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE());

-- Check for logical deletes:
-- SELECT dw_logical_delete_flag, COUNT(*) 
-- FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR 
-- GROUP BY dw_logical_delete_flag;

-- Check task status:
-- SHOW TASKS LIKE 'LH_LOADING_CYCLE_INCR_T' IN DEV_API_REF.FUSE;
