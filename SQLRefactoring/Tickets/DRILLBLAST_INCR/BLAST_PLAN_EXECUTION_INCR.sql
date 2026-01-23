/*******************************************************************************
 * BLAST_PLAN_EXECUTION_INCR - Incremental Table and Stored Procedure
 * 
 * Source: PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION
 * Target: DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR
 * Business Key: ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID (composite)
 * Timestamp Column: DW_MODIFY_TS
 * 
 * Pattern: MERGE-driven upserts with hash-based conditional updates
 * Incremental Window: 3 days default, max 30 days
 * Soft Deletes: DW_LOGICAL_DELETE_FLAG = 'Y'
 ******************************************************************************/

-- =============================================================================
-- TABLE DDL
-- =============================================================================
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR (
    -- Business Keys (Composite Primary Key)
    ORIG_SRC_ID                 BIGINT          NOT NULL,
    SITE_CODE                   VARCHAR(50)     NOT NULL,
    BENCH                       FLOAT           NOT NULL,
    PUSHBACK                    VARCHAR(50)     NOT NULL,
    PATTERN_NAME                VARCHAR(400)    NOT NULL,
    BLAST_NAME                  VARCHAR(5000)   NOT NULL,
    DRILLED_HOLE_ID             INT             NOT NULL,
    
    -- Hole Identification
    DRILLED_HOLE_NAME           VARCHAR(500),
    
    -- Related Keys
    DRILL_CYCLE_SK              BIGINT,
    BLAST_PLAN_SK               BIGINT,
    SHIFT_ID                    VARCHAR(500),
    BLAST_ID                    INT,
    
    -- Shot Details
    SHOT_DATE_UTC               VARCHAR(50),
    SHOT_DATE_LOCAL             VARCHAR(50),
    BLAST_TYPE                  VARCHAR(400),
    BLAST_ENGINEER_NAME         VARCHAR(500),
    LOADING_TRUCK_OPERATOR_NAME VARCHAR(200),
    
    -- Hole Loading
    HOLE_LOADED_TS_UTC          VARCHAR(50),
    HOLE_LOADED_TS_LOCAL        VARCHAR(50),
    HOLE_LAST_KNOWN_DEPTH_METERS    DECIMAL(38,5),
    HOLE_LAST_KNOWN_DEPTH_FEET      DECIMAL(38,5),
    HOLE_TAPED_DEPTH_METERS         DECIMAL(38,5),
    HOLE_TAPED_DEPTH_FEET           DECIMAL(38,5),
    HOLE_PLUGGED_FLAG               BOOLEAN,
    
    -- Explosive Products
    EXPLOSIVE_PRODUCT_BOTTOM    BIGINT,
    EXPLOSIVE_PRODUCT_TOP       BIGINT,
    EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS  DECIMAL(38,5),
    EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS     DECIMAL(38,5),
    EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS     DECIMAL(38,5),
    EXPLOSIVE_PRODUCT_USED_TOP_POUNDS        DECIMAL(38,5),
    EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS   DECIMAL(38,5),
    EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET     DECIMAL(38,5),
    EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS      DECIMAL(38,5),
    EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET        DECIMAL(38,5),
    
    -- Stemming
    STEMMING_LENGTH_TOTAL_METERS    DECIMAL(38,5),
    STEMMING_LENGTH_TOTAL_FEET      DECIMAL(38,5),
    STEMMING_LENGTH_BOTTOM_METERS   DECIMAL(38,5),
    STEMMING_LENGTH_BOTTOM_FEET     DECIMAL(38,5),
    STEMMING_LENGTH_TOP_METERS      DECIMAL(38,5),
    STEMMING_LENGTH_TOP_FEET        DECIMAL(38,5),
    
    -- Spacing and Burden
    BURDEN_METERS               DECIMAL(38,5),
    BURDEN_FEET                 DECIMAL(38,5),
    SPACING_METERS              DECIMAL(38,5),
    SPACING_FEET                DECIMAL(38,5),
    
    -- Calculated Metrics
    TONS_PER_HOLE               DECIMAL(38,5),
    KCALS_PER_TON               DECIMAL(38,5),
    POWDER_FACTOR               DECIMAL(38,5),
    MEGAJOULES_PER_TON          DECIMAL(38,5),
    CONFINEMENT_FACTOR          DECIMAL(38,5),
    PRIMER_COUNT                INT,
    
    -- Temperature
    HOLE_TEMPERATURE_CELSIUS    DECIMAL(38,5),
    HOLE_TEMPERATURE_FAHRENHEIT DECIMAL(38,5),
    
    -- Comments
    PRODUCT_BOTTOM_COMMENTS     VARCHAR(5000),
    PRODUCT_TOP_COMMENTS        VARCHAR(5000),
    STEMMING_BOTTOM_COMMENT     VARCHAR(5000),
    STEMMING_TOP_COMMENT        VARCHAR(5000),
    
    -- Water and Misfire
    WATER_DEPTH_METERS          DECIMAL(38,5),
    WATER_DEPTH_FEET            DECIMAL(38,5),
    MISFIRE_FLAG                BOOLEAN,
    
    -- Data Warehouse Audit Columns
    DW_LOAD_TS                  TIMESTAMP_NTZ,
    DW_MODIFY_TS                TIMESTAMP_NTZ,
    DW_LOGICAL_DELETE_FLAG      VARCHAR(1)      DEFAULT 'N',
    DW_ROW_HASH                 VARCHAR(64),
    
    -- Primary Key (Composite)
    CONSTRAINT PK_BLAST_PLAN_EXECUTION_INCR PRIMARY KEY (
        ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID
    )
);

-- =============================================================================
-- STORED PROCEDURE
-- =============================================================================
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.SP_BLAST_PLAN_EXECUTION_INCR(
    P_DAYS_BACK FLOAT DEFAULT 3,
    P_MAX_DAYS FLOAT DEFAULT 30
)
RETURNS VARIANT
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var result = {
        procedure: 'SP_BLAST_PLAN_EXECUTION_INCR',
        start_time: new Date().toISOString(),
        rows_merged: 0,
        rows_inserted: 0,
        rows_updated: 0,
        rows_soft_deleted: 0,
        status: 'SUCCESS',
        error_message: null
    };
    
    try {
        // Validate parameters
        var daysBack = P_DAYS_BACK || 3;
        var maxDays = P_MAX_DAYS || 30;
        
        if (daysBack > maxDays) {
            daysBack = maxDays;
        }
        
        // Calculate cutoff timestamp
        var cutoffSQL = `SELECT DATEADD(day, -${daysBack}, CURRENT_TIMESTAMP())::TIMESTAMP_NTZ`;
        var cutoffStmt = snowflake.createStatement({sqlText: cutoffSQL});
        var cutoffResult = cutoffStmt.execute();
        cutoffResult.next();
        var cutoffTs = cutoffResult.getColumnValue(1);
        result.cutoff_timestamp = cutoffTs;
        
        // MERGE statement with hash-based conditional updates
        var mergeSQL = `
            MERGE INTO DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR AS TGT
            USING (
                SELECT 
                    ORIG_SRC_ID,
                    SITE_CODE,
                    BENCH,
                    PUSHBACK,
                    PATTERN_NAME,
                    BLAST_NAME,
                    DRILLED_HOLE_ID,
                    DRILLED_HOLE_NAME,
                    DRILL_CYCLE_SK,
                    BLAST_PLAN_SK,
                    SHIFT_ID,
                    BLAST_ID,
                    SHOT_DATE_UTC,
                    SHOT_DATE_LOCAL,
                    BLAST_TYPE,
                    BLAST_ENGINEER_NAME,
                    LOADING_TRUCK_OPERATOR_NAME,
                    HOLE_LOADED_TS_UTC,
                    HOLE_LOADED_TS_LOCAL,
                    HOLE_LAST_KNOWN_DEPTH_METERS,
                    HOLE_LAST_KNOWN_DEPTH_FEET,
                    HOLE_TAPED_DEPTH_METERS,
                    HOLE_TAPED_DEPTH_FEET,
                    HOLE_PLUGGED_FLAG,
                    EXPLOSIVE_PRODUCT_BOTTOM,
                    EXPLOSIVE_PRODUCT_TOP,
                    EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS,
                    EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
                    EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS,
                    EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
                    EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS,
                    EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
                    EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS,
                    EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
                    STEMMING_LENGTH_TOTAL_METERS,
                    STEMMING_LENGTH_TOTAL_FEET,
                    STEMMING_LENGTH_BOTTOM_METERS,
                    STEMMING_LENGTH_BOTTOM_FEET,
                    STEMMING_LENGTH_TOP_METERS,
                    STEMMING_LENGTH_TOP_FEET,
                    BURDEN_METERS,
                    BURDEN_FEET,
                    SPACING_METERS,
                    SPACING_FEET,
                    TONS_PER_HOLE,
                    KCALS_PER_TON,
                    POWDER_FACTOR,
                    MEGAJOULES_PER_TON,
                    CONFINEMENT_FACTOR,
                    PRIMER_COUNT,
                    HOLE_TEMPERATURE_CELSIUS,
                    HOLE_TEMPERATURE_FAHRENHEIT,
                    PRODUCT_BOTTOM_COMMENTS,
                    PRODUCT_TOP_COMMENTS,
                    STEMMING_BOTTOM_COMMENT,
                    STEMMING_TOP_COMMENT,
                    WATER_DEPTH_METERS,
                    WATER_DEPTH_FEET,
                    MISFIRE_FLAG,
                    TRY_TO_TIMESTAMP(DW_LOAD_TS)    AS DW_LOAD_TS,
                    TRY_TO_TIMESTAMP(DW_MODIFY_TS)  AS DW_MODIFY_TS,
                    'N'                             AS DW_LOGICAL_DELETE_FLAG,
                    SHA2(CONCAT_WS('|',
                        COALESCE(CAST(ORIG_SRC_ID AS VARCHAR), ''),
                        COALESCE(SITE_CODE, ''),
                        COALESCE(CAST(BENCH AS VARCHAR), ''),
                        COALESCE(PUSHBACK, ''),
                        COALESCE(PATTERN_NAME, ''),
                        COALESCE(BLAST_NAME, ''),
                        COALESCE(CAST(DRILLED_HOLE_ID AS VARCHAR), ''),
                        COALESCE(DRILLED_HOLE_NAME, ''),
                        COALESCE(BLAST_TYPE, ''),
                        COALESCE(BLAST_ENGINEER_NAME, ''),
                        COALESCE(CAST(TONS_PER_HOLE AS VARCHAR), ''),
                        COALESCE(CAST(POWDER_FACTOR AS VARCHAR), ''),
                        COALESCE(CAST(MISFIRE_FLAG AS VARCHAR), '')
                    ), 256) AS DW_ROW_HASH
                FROM PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION
                WHERE TRY_TO_TIMESTAMP(DW_MODIFY_TS) >= '${cutoffTs}'
            ) AS SRC
            ON TGT.ORIG_SRC_ID = SRC.ORIG_SRC_ID
               AND TGT.SITE_CODE = SRC.SITE_CODE
               AND TGT.BENCH = SRC.BENCH
               AND TGT.PUSHBACK = SRC.PUSHBACK
               AND TGT.PATTERN_NAME = SRC.PATTERN_NAME
               AND TGT.BLAST_NAME = SRC.BLAST_NAME
               AND TGT.DRILLED_HOLE_ID = SRC.DRILLED_HOLE_ID
            
            WHEN MATCHED AND TGT.DW_ROW_HASH != SRC.DW_ROW_HASH THEN UPDATE SET
                TGT.DRILLED_HOLE_NAME = SRC.DRILLED_HOLE_NAME,
                TGT.DRILL_CYCLE_SK = SRC.DRILL_CYCLE_SK,
                TGT.BLAST_PLAN_SK = SRC.BLAST_PLAN_SK,
                TGT.SHIFT_ID = SRC.SHIFT_ID,
                TGT.BLAST_ID = SRC.BLAST_ID,
                TGT.SHOT_DATE_UTC = SRC.SHOT_DATE_UTC,
                TGT.SHOT_DATE_LOCAL = SRC.SHOT_DATE_LOCAL,
                TGT.BLAST_TYPE = SRC.BLAST_TYPE,
                TGT.BLAST_ENGINEER_NAME = SRC.BLAST_ENGINEER_NAME,
                TGT.LOADING_TRUCK_OPERATOR_NAME = SRC.LOADING_TRUCK_OPERATOR_NAME,
                TGT.HOLE_LOADED_TS_UTC = SRC.HOLE_LOADED_TS_UTC,
                TGT.HOLE_LOADED_TS_LOCAL = SRC.HOLE_LOADED_TS_LOCAL,
                TGT.HOLE_LAST_KNOWN_DEPTH_METERS = SRC.HOLE_LAST_KNOWN_DEPTH_METERS,
                TGT.HOLE_LAST_KNOWN_DEPTH_FEET = SRC.HOLE_LAST_KNOWN_DEPTH_FEET,
                TGT.HOLE_TAPED_DEPTH_METERS = SRC.HOLE_TAPED_DEPTH_METERS,
                TGT.HOLE_TAPED_DEPTH_FEET = SRC.HOLE_TAPED_DEPTH_FEET,
                TGT.HOLE_PLUGGED_FLAG = SRC.HOLE_PLUGGED_FLAG,
                TGT.EXPLOSIVE_PRODUCT_BOTTOM = SRC.EXPLOSIVE_PRODUCT_BOTTOM,
                TGT.EXPLOSIVE_PRODUCT_TOP = SRC.EXPLOSIVE_PRODUCT_TOP,
                TGT.EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS = SRC.EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS,
                TGT.EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS = SRC.EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
                TGT.EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS = SRC.EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS,
                TGT.EXPLOSIVE_PRODUCT_USED_TOP_POUNDS = SRC.EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
                TGT.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS = SRC.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS,
                TGT.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET = SRC.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
                TGT.EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS = SRC.EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS,
                TGT.EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET = SRC.EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
                TGT.STEMMING_LENGTH_TOTAL_METERS = SRC.STEMMING_LENGTH_TOTAL_METERS,
                TGT.STEMMING_LENGTH_TOTAL_FEET = SRC.STEMMING_LENGTH_TOTAL_FEET,
                TGT.STEMMING_LENGTH_BOTTOM_METERS = SRC.STEMMING_LENGTH_BOTTOM_METERS,
                TGT.STEMMING_LENGTH_BOTTOM_FEET = SRC.STEMMING_LENGTH_BOTTOM_FEET,
                TGT.STEMMING_LENGTH_TOP_METERS = SRC.STEMMING_LENGTH_TOP_METERS,
                TGT.STEMMING_LENGTH_TOP_FEET = SRC.STEMMING_LENGTH_TOP_FEET,
                TGT.BURDEN_METERS = SRC.BURDEN_METERS,
                TGT.BURDEN_FEET = SRC.BURDEN_FEET,
                TGT.SPACING_METERS = SRC.SPACING_METERS,
                TGT.SPACING_FEET = SRC.SPACING_FEET,
                TGT.TONS_PER_HOLE = SRC.TONS_PER_HOLE,
                TGT.KCALS_PER_TON = SRC.KCALS_PER_TON,
                TGT.POWDER_FACTOR = SRC.POWDER_FACTOR,
                TGT.MEGAJOULES_PER_TON = SRC.MEGAJOULES_PER_TON,
                TGT.CONFINEMENT_FACTOR = SRC.CONFINEMENT_FACTOR,
                TGT.PRIMER_COUNT = SRC.PRIMER_COUNT,
                TGT.HOLE_TEMPERATURE_CELSIUS = SRC.HOLE_TEMPERATURE_CELSIUS,
                TGT.HOLE_TEMPERATURE_FAHRENHEIT = SRC.HOLE_TEMPERATURE_FAHRENHEIT,
                TGT.PRODUCT_BOTTOM_COMMENTS = SRC.PRODUCT_BOTTOM_COMMENTS,
                TGT.PRODUCT_TOP_COMMENTS = SRC.PRODUCT_TOP_COMMENTS,
                TGT.STEMMING_BOTTOM_COMMENT = SRC.STEMMING_BOTTOM_COMMENT,
                TGT.STEMMING_TOP_COMMENT = SRC.STEMMING_TOP_COMMENT,
                TGT.WATER_DEPTH_METERS = SRC.WATER_DEPTH_METERS,
                TGT.WATER_DEPTH_FEET = SRC.WATER_DEPTH_FEET,
                TGT.MISFIRE_FLAG = SRC.MISFIRE_FLAG,
                TGT.DW_LOAD_TS = SRC.DW_LOAD_TS,
                TGT.DW_MODIFY_TS = SRC.DW_MODIFY_TS,
                TGT.DW_LOGICAL_DELETE_FLAG = SRC.DW_LOGICAL_DELETE_FLAG,
                TGT.DW_ROW_HASH = SRC.DW_ROW_HASH
            
            WHEN NOT MATCHED THEN INSERT (
                ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID,
                DRILLED_HOLE_NAME, DRILL_CYCLE_SK, BLAST_PLAN_SK, SHIFT_ID, BLAST_ID, SHOT_DATE_UTC,
                SHOT_DATE_LOCAL, BLAST_TYPE, BLAST_ENGINEER_NAME, LOADING_TRUCK_OPERATOR_NAME,
                HOLE_LOADED_TS_UTC, HOLE_LOADED_TS_LOCAL, HOLE_LAST_KNOWN_DEPTH_METERS,
                HOLE_LAST_KNOWN_DEPTH_FEET, HOLE_TAPED_DEPTH_METERS, HOLE_TAPED_DEPTH_FEET,
                HOLE_PLUGGED_FLAG, EXPLOSIVE_PRODUCT_BOTTOM, EXPLOSIVE_PRODUCT_TOP,
                EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS, EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
                EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS, EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
                EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS, EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
                EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS, EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
                STEMMING_LENGTH_TOTAL_METERS, STEMMING_LENGTH_TOTAL_FEET, STEMMING_LENGTH_BOTTOM_METERS,
                STEMMING_LENGTH_BOTTOM_FEET, STEMMING_LENGTH_TOP_METERS, STEMMING_LENGTH_TOP_FEET,
                BURDEN_METERS, BURDEN_FEET, SPACING_METERS, SPACING_FEET, TONS_PER_HOLE, KCALS_PER_TON,
                POWDER_FACTOR, MEGAJOULES_PER_TON, CONFINEMENT_FACTOR, PRIMER_COUNT,
                HOLE_TEMPERATURE_CELSIUS, HOLE_TEMPERATURE_FAHRENHEIT, PRODUCT_BOTTOM_COMMENTS,
                PRODUCT_TOP_COMMENTS, STEMMING_BOTTOM_COMMENT, STEMMING_TOP_COMMENT, WATER_DEPTH_METERS,
                WATER_DEPTH_FEET, MISFIRE_FLAG, DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG, DW_ROW_HASH
            ) VALUES (
                SRC.ORIG_SRC_ID, SRC.SITE_CODE, SRC.BENCH, SRC.PUSHBACK, SRC.PATTERN_NAME, SRC.BLAST_NAME,
                SRC.DRILLED_HOLE_ID, SRC.DRILLED_HOLE_NAME, SRC.DRILL_CYCLE_SK, SRC.BLAST_PLAN_SK,
                SRC.SHIFT_ID, SRC.BLAST_ID, SRC.SHOT_DATE_UTC, SRC.SHOT_DATE_LOCAL, SRC.BLAST_TYPE,
                SRC.BLAST_ENGINEER_NAME, SRC.LOADING_TRUCK_OPERATOR_NAME, SRC.HOLE_LOADED_TS_UTC,
                SRC.HOLE_LOADED_TS_LOCAL, SRC.HOLE_LAST_KNOWN_DEPTH_METERS, SRC.HOLE_LAST_KNOWN_DEPTH_FEET,
                SRC.HOLE_TAPED_DEPTH_METERS, SRC.HOLE_TAPED_DEPTH_FEET, SRC.HOLE_PLUGGED_FLAG,
                SRC.EXPLOSIVE_PRODUCT_BOTTOM, SRC.EXPLOSIVE_PRODUCT_TOP,
                SRC.EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS, SRC.EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
                SRC.EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS, SRC.EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
                SRC.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS, SRC.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
                SRC.EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS, SRC.EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
                SRC.STEMMING_LENGTH_TOTAL_METERS, SRC.STEMMING_LENGTH_TOTAL_FEET,
                SRC.STEMMING_LENGTH_BOTTOM_METERS, SRC.STEMMING_LENGTH_BOTTOM_FEET,
                SRC.STEMMING_LENGTH_TOP_METERS, SRC.STEMMING_LENGTH_TOP_FEET,
                SRC.BURDEN_METERS, SRC.BURDEN_FEET, SRC.SPACING_METERS, SRC.SPACING_FEET,
                SRC.TONS_PER_HOLE, SRC.KCALS_PER_TON, SRC.POWDER_FACTOR, SRC.MEGAJOULES_PER_TON,
                SRC.CONFINEMENT_FACTOR, SRC.PRIMER_COUNT, SRC.HOLE_TEMPERATURE_CELSIUS,
                SRC.HOLE_TEMPERATURE_FAHRENHEIT, SRC.PRODUCT_BOTTOM_COMMENTS, SRC.PRODUCT_TOP_COMMENTS,
                SRC.STEMMING_BOTTOM_COMMENT, SRC.STEMMING_TOP_COMMENT, SRC.WATER_DEPTH_METERS,
                SRC.WATER_DEPTH_FEET, SRC.MISFIRE_FLAG, SRC.DW_LOAD_TS, SRC.DW_MODIFY_TS,
                SRC.DW_LOGICAL_DELETE_FLAG, SRC.DW_ROW_HASH
            )
        `;
        
        var mergeStmt = snowflake.createStatement({sqlText: mergeSQL});
        var mergeResult = mergeStmt.execute();
        mergeResult.next();
        result.rows_merged = mergeStmt.getNumRowsAffected();
        
        // Handle soft deletes for records no longer in source
        var softDeleteSQL = `
            UPDATE DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR TGT
            SET DW_LOGICAL_DELETE_FLAG = 'Y',
                DW_MODIFY_TS = CURRENT_TIMESTAMP()
            WHERE NOT EXISTS (
                SELECT 1 FROM PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION SRC
                WHERE TGT.ORIG_SRC_ID = SRC.ORIG_SRC_ID
                  AND TGT.SITE_CODE = SRC.SITE_CODE
                  AND TGT.BENCH = SRC.BENCH
                  AND TGT.PUSHBACK = SRC.PUSHBACK
                  AND TGT.PATTERN_NAME = SRC.PATTERN_NAME
                  AND TGT.BLAST_NAME = SRC.BLAST_NAME
                  AND TGT.DRILLED_HOLE_ID = SRC.DRILLED_HOLE_ID
            )
            AND TGT.DW_LOGICAL_DELETE_FLAG = 'N'
        `;
        
        var softDeleteStmt = snowflake.createStatement({sqlText: softDeleteSQL});
        softDeleteStmt.execute();
        result.rows_soft_deleted = softDeleteStmt.getNumRowsAffected();
        
        result.end_time = new Date().toISOString();
        
    } catch (err) {
        result.status = 'FAILED';
        result.error_message = err.message;
        result.end_time = new Date().toISOString();
    }
    
    return result;
$$;

-- =============================================================================
-- USAGE EXAMPLES
-- =============================================================================
-- Default execution (3 days lookback)
-- CALL DEV_API_REF.FUSE.SP_BLAST_PLAN_EXECUTION_INCR();

-- Custom lookback period
-- CALL DEV_API_REF.FUSE.SP_BLAST_PLAN_EXECUTION_INCR(7, 30);

-- Full reload (30 days max)
-- CALL DEV_API_REF.FUSE.SP_BLAST_PLAN_EXECUTION_INCR(30, 30);
