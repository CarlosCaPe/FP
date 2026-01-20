-- =============================================================================
-- LH_BUCKET_INCR - Incremental Table and Procedure
-- Target: DEV_API_REF.FUSE.LH_BUCKET_INCR
-- =============================================================================
-- Author: Carlos Carrillo (based on DRILLBLAST_DRILL_CYCLE_CT_P pattern by Hidayath)
-- Date: 2026-01-20
-- Pattern: MERGE-driven upserts with hash-based conditional updates
-- Incremental window: 3 days (default)
-- Task schedule: Every 15 minutes
-- =============================================================================
-- Source: PROD_WG.LOAD_HAUL.LH_BUCKET (VIEW)
-- Business Key: BUCKET_ID
-- Timestamp for incremental: TRIP_TS_LOCAL
-- =============================================================================


-- ============================================================================
-- STEP 1: CREATE INCR TABLE
-- ============================================================================
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_BUCKET_INCR (
    BUCKET_ID                           NUMBER(19,0),           -- Business Key
    SITE_CODE                           VARCHAR(4) COLLATE 'en-ci',
    LOADING_CYCLE_ID                    NUMBER(19,0),
    LH_EQUIP_ID                         NUMBER(38,5),
    ORIG_SRC_ID                         NUMBER(38,0),
    BUCKET_OF_CYCLE                     NUMBER(38,0),
    SWING_EMPTY_START_TS_UTC            TIMESTAMP_NTZ(3),
    SWING_EMPTY_START_TS_LOCAL          TIMESTAMP_NTZ(3),
    SWING_EMPTY_END_TS_UTC              TIMESTAMP_NTZ(3),
    SWING_EMPTY_END_TS_LOCAL            TIMESTAMP_NTZ(3),
    DIG_START_TS_UTC                    TIMESTAMP_NTZ(3),
    DIG_START_TS_LOCAL                  TIMESTAMP_NTZ(3),
    DIG_END_TS_UTC                      TIMESTAMP_NTZ(3),
    DIG_END_TS_LOCAL                    TIMESTAMP_NTZ(3),
    SWING_FULL_START_TS_UTC             TIMESTAMP_NTZ(3),
    SWING_FULL_START_TS_LOCAL           TIMESTAMP_NTZ(3),
    SWING_FULL_END_TS_UTC               TIMESTAMP_NTZ(3),
    SWING_FULL_END_TS_LOCAL             TIMESTAMP_NTZ(3),
    TRIP_TS_UTC                         TIMESTAMP_NTZ(3),
    TRIP_TS_LOCAL                       TIMESTAMP_NTZ(3),       -- Incremental timestamp
    DIG_X                               FLOAT,
    DIG_Y                               FLOAT,
    DIG_Z                               FLOAT,
    TRIP_X                              FLOAT,
    TRIP_Y                              FLOAT,
    TRIP_Z                              FLOAT,
    SWING_ANGLE_DEGREES                 FLOAT,
    BLOCK_CENTROID_X                    FLOAT,
    BLOCK_CENTROID_Y                    FLOAT,
    BLOCK_CENTROID_Z                    FLOAT,
    MEASURED_SHORT_TONS                 NUMBER(38,6),
    MEASURED_METRIC_TONS                NUMBER(38,6),
    SWING_EMPTY_DURATION_MINS           NUMBER(38,6),
    DIG_DURATION_MINS                   NUMBER(38,6),
    SWING_FULL_DURATION_MINS            NUMBER(38,6),
    SYSTEM_VERSION                      VARCHAR(50) COLLATE 'en-ci',
    DW_LOGICAL_DELETE_FLAG              VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
    DW_LOAD_TS                          TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                        TIMESTAMP_NTZ(0)
)
COMMENT = 'Incremental table for LH_BUCKET - MERGE-driven upserts with 3-day incremental window';


-- ============================================================================
-- STEP 2: CREATE INCR PROCEDURE
-- ============================================================================
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_BUCKET_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : The LH_BUCKET_INCR_P procedure is designed to merge data from the 
*             LH_BUCKET view into the LH_BUCKET_INCR incremental table.
*             It processes data from the last 3 days by default, with the option to extend
*             up to a maximum of 30 days.
*
* NOTES     : As part of the IROC project, We are creating this incremental table and
*             it will process the incremental data from Snowflake to SQL
*             using the high watermark strategy. This procedure is helpful for the 
*             incremental and history data load up to 30 days from the source view
*             into the Incremental table.
*
* USAGE     : CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P(3);
*
* SOURCE    : PROD_WG.LOAD_HAUL.LH_BUCKET
* TARGET    : DEV_API_REF.FUSE.LH_BUCKET_INCR
* BUSINESS KEY: BUCKET_ID
* INCREMENTAL COLUMN: TRIP_TS_LOCAL
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
                  FROM dev_api_ref.fuse.lh_bucket_incr 
                  WHERE trip_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// Delete records outside the lookback window
sql_delete_incr = `DELETE FROM dev_api_ref.fuse.lh_bucket_incr 
                   WHERE trip_ts_local::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// MERGE: Upsert new/changed records using BUCKET_ID as business key
sql_merge = `MERGE INTO dev_api_ref.fuse.lh_bucket_incr tgt
USING (
    SELECT
        bucket_id,
        site_code,
        loading_cycle_id,
        lh_equip_id,
        orig_src_id,
        bucket_of_cycle,
        swing_empty_start_ts_utc,
        swing_empty_start_ts_local,
        swing_empty_end_ts_utc,
        swing_empty_end_ts_local,
        dig_start_ts_utc,
        dig_start_ts_local,
        dig_end_ts_utc,
        dig_end_ts_local,
        swing_full_start_ts_utc,
        swing_full_start_ts_local,
        swing_full_end_ts_utc,
        swing_full_end_ts_local,
        trip_ts_utc,
        trip_ts_local,
        dig_x,
        dig_y,
        dig_z,
        trip_x,
        trip_y,
        trip_z,
        swing_angle_degrees,
        block_centroid_x,
        block_centroid_y,
        block_centroid_z,
        measured_short_tons,
        measured_metric_tons,
        swing_empty_duration_mins,
        dig_duration_mins,
        swing_full_duration_mins,
        system_version,
        ''N'' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_modify_ts
    FROM prod_wg.load_haul.lh_bucket
    WHERE trip_ts_local::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src

ON tgt.bucket_id = src.bucket_id

WHEN MATCHED AND HASH(
    src.site_code,
    src.loading_cycle_id,
    src.lh_equip_id,
    src.orig_src_id,
    src.bucket_of_cycle,
    src.swing_empty_start_ts_utc,
    src.swing_empty_start_ts_local,
    src.swing_empty_end_ts_utc,
    src.swing_empty_end_ts_local,
    src.dig_start_ts_utc,
    src.dig_start_ts_local,
    src.dig_end_ts_utc,
    src.dig_end_ts_local,
    src.swing_full_start_ts_utc,
    src.swing_full_start_ts_local,
    src.swing_full_end_ts_utc,
    src.swing_full_end_ts_local,
    src.trip_ts_utc,
    src.trip_ts_local,
    src.dig_x,
    src.dig_y,
    src.dig_z,
    src.trip_x,
    src.trip_y,
    src.trip_z,
    src.swing_angle_degrees,
    src.block_centroid_x,
    src.block_centroid_y,
    src.block_centroid_z,
    src.measured_short_tons,
    src.measured_metric_tons,
    src.swing_empty_duration_mins,
    src.dig_duration_mins,
    src.swing_full_duration_mins,
    src.system_version
) <> HASH(
    tgt.site_code,
    tgt.loading_cycle_id,
    tgt.lh_equip_id,
    tgt.orig_src_id,
    tgt.bucket_of_cycle,
    tgt.swing_empty_start_ts_utc,
    tgt.swing_empty_start_ts_local,
    tgt.swing_empty_end_ts_utc,
    tgt.swing_empty_end_ts_local,
    tgt.dig_start_ts_utc,
    tgt.dig_start_ts_local,
    tgt.dig_end_ts_utc,
    tgt.dig_end_ts_local,
    tgt.swing_full_start_ts_utc,
    tgt.swing_full_start_ts_local,
    tgt.swing_full_end_ts_utc,
    tgt.swing_full_end_ts_local,
    tgt.trip_ts_utc,
    tgt.trip_ts_local,
    tgt.dig_x,
    tgt.dig_y,
    tgt.dig_z,
    tgt.trip_x,
    tgt.trip_y,
    tgt.trip_z,
    tgt.swing_angle_degrees,
    tgt.block_centroid_x,
    tgt.block_centroid_y,
    tgt.block_centroid_z,
    tgt.measured_short_tons,
    tgt.measured_metric_tons,
    tgt.swing_empty_duration_mins,
    tgt.dig_duration_mins,
    tgt.swing_full_duration_mins,
    tgt.system_version
) THEN UPDATE SET
    tgt.site_code = src.site_code,
    tgt.loading_cycle_id = src.loading_cycle_id,
    tgt.lh_equip_id = src.lh_equip_id,
    tgt.orig_src_id = src.orig_src_id,
    tgt.bucket_of_cycle = src.bucket_of_cycle,
    tgt.swing_empty_start_ts_utc = src.swing_empty_start_ts_utc,
    tgt.swing_empty_start_ts_local = src.swing_empty_start_ts_local,
    tgt.swing_empty_end_ts_utc = src.swing_empty_end_ts_utc,
    tgt.swing_empty_end_ts_local = src.swing_empty_end_ts_local,
    tgt.dig_start_ts_utc = src.dig_start_ts_utc,
    tgt.dig_start_ts_local = src.dig_start_ts_local,
    tgt.dig_end_ts_utc = src.dig_end_ts_utc,
    tgt.dig_end_ts_local = src.dig_end_ts_local,
    tgt.swing_full_start_ts_utc = src.swing_full_start_ts_utc,
    tgt.swing_full_start_ts_local = src.swing_full_start_ts_local,
    tgt.swing_full_end_ts_utc = src.swing_full_end_ts_utc,
    tgt.swing_full_end_ts_local = src.swing_full_end_ts_local,
    tgt.trip_ts_utc = src.trip_ts_utc,
    tgt.trip_ts_local = src.trip_ts_local,
    tgt.dig_x = src.dig_x,
    tgt.dig_y = src.dig_y,
    tgt.dig_z = src.dig_z,
    tgt.trip_x = src.trip_x,
    tgt.trip_y = src.trip_y,
    tgt.trip_z = src.trip_z,
    tgt.swing_angle_degrees = src.swing_angle_degrees,
    tgt.block_centroid_x = src.block_centroid_x,
    tgt.block_centroid_y = src.block_centroid_y,
    tgt.block_centroid_z = src.block_centroid_z,
    tgt.measured_short_tons = src.measured_short_tons,
    tgt.measured_metric_tons = src.measured_metric_tons,
    tgt.swing_empty_duration_mins = src.swing_empty_duration_mins,
    tgt.dig_duration_mins = src.dig_duration_mins,
    tgt.swing_full_duration_mins = src.swing_full_duration_mins,
    tgt.system_version = src.system_version,
    tgt.dw_modify_ts = src.dw_modify_ts

WHEN NOT MATCHED THEN INSERT (
    bucket_id,
    site_code,
    loading_cycle_id,
    lh_equip_id,
    orig_src_id,
    bucket_of_cycle,
    swing_empty_start_ts_utc,
    swing_empty_start_ts_local,
    swing_empty_end_ts_utc,
    swing_empty_end_ts_local,
    dig_start_ts_utc,
    dig_start_ts_local,
    dig_end_ts_utc,
    dig_end_ts_local,
    swing_full_start_ts_utc,
    swing_full_start_ts_local,
    swing_full_end_ts_utc,
    swing_full_end_ts_local,
    trip_ts_utc,
    trip_ts_local,
    dig_x,
    dig_y,
    dig_z,
    trip_x,
    trip_y,
    trip_z,
    swing_angle_degrees,
    block_centroid_x,
    block_centroid_y,
    block_centroid_z,
    measured_short_tons,
    measured_metric_tons,
    swing_empty_duration_mins,
    dig_duration_mins,
    swing_full_duration_mins,
    system_version,
    dw_logical_delete_flag,
    dw_load_ts,
    dw_modify_ts
) VALUES (
    src.bucket_id,
    src.site_code,
    src.loading_cycle_id,
    src.lh_equip_id,
    src.orig_src_id,
    src.bucket_of_cycle,
    src.swing_empty_start_ts_utc,
    src.swing_empty_start_ts_local,
    src.swing_empty_end_ts_utc,
    src.swing_empty_end_ts_local,
    src.dig_start_ts_utc,
    src.dig_start_ts_local,
    src.dig_end_ts_utc,
    src.dig_end_ts_local,
    src.swing_full_start_ts_utc,
    src.swing_full_start_ts_local,
    src.swing_full_end_ts_utc,
    src.swing_full_end_ts_local,
    src.trip_ts_utc,
    src.trip_ts_local,
    src.dig_x,
    src.dig_y,
    src.dig_z,
    src.trip_x,
    src.trip_y,
    src.trip_z,
    src.swing_angle_degrees,
    src.block_centroid_x,
    src.block_centroid_y,
    src.block_centroid_z,
    src.measured_short_tons,
    src.measured_metric_tons,
    src.swing_empty_duration_mins,
    src.dig_duration_mins,
    src.swing_full_duration_mins,
    src.system_version,
    src.dw_logical_delete_flag,
    src.dw_load_ts,
    src.dw_modify_ts
);`;

// Soft delete: Mark records that no longer exist in source
sql_delete = `UPDATE dev_api_ref.fuse.lh_bucket_incr tgt
              SET dw_logical_delete_flag = ''Y'',
                  dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (
                  SELECT 1
                  FROM prod_wg.load_haul.lh_bucket src
                  WHERE src.bucket_id = tgt.bucket_id
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
-- CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('30');


-- ============================================================================
-- STEP 4: CREATE TASK (every 15 minutes)
-- ============================================================================
CREATE OR REPLACE TASK DEV_API_REF.FUSE.LH_BUCKET_INCR_T
    WAREHOUSE = 'WH_BATCH_DE_NONPROD'
    SCHEDULE = 'USING CRON */15 * * * * UTC'
    COMMENT = 'Refresh LH_BUCKET_INCR every 15 minutes with 3-day lookback'
AS
    CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('3');

-- Enable the task (run after testing)
-- ALTER TASK DEV_API_REF.FUSE.LH_BUCKET_INCR_T RESUME;


-- ============================================================================
-- TESTING QUERIES
-- ============================================================================
-- Test procedure execution:
-- CALL DEV_API_REF.FUSE.LH_BUCKET_INCR_P('3');

-- Verify row counts:
-- SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_INCR;
-- SELECT COUNT(*) FROM PROD_WG.LOAD_HAUL.LH_BUCKET 
-- WHERE trip_ts_local::date >= DATEADD(day, -3, CURRENT_DATE());

-- Check for logical deletes:
-- SELECT dw_logical_delete_flag, COUNT(*) 
-- FROM DEV_API_REF.FUSE.LH_BUCKET_INCR 
-- GROUP BY dw_logical_delete_flag;

-- Check task status:
-- SHOW TASKS LIKE 'LH_BUCKET_INCR_T' IN DEV_API_REF.FUSE;
