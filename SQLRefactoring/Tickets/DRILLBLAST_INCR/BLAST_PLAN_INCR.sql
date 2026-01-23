/*******************************************************************************
 * BLAST_PLAN_INCR - Incremental Table and Stored Procedure
 * 
 * Source: PROD_WG.DRILL_BLAST.BLAST_PLAN
 * Target: DEV_API_REF.FUSE.BLAST_PLAN_INCR
 * Business Key: BLAST_PLAN_SK
 * Timestamp Column: DW_MODIFY_TS
 * 
 * Pattern: MERGE-driven upserts with hash-based conditional updates
 * Incremental Window: 3 days default, max 30 days
 * Soft Deletes: DW_LOGICAL_DELETE_FLAG = 'Y'
 ******************************************************************************/

-- =============================================================================
-- TABLE DDL
-- =============================================================================
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.BLAST_PLAN_INCR (
    -- Business Keys
    BLAST_PLAN_SK               BIGINT          NOT NULL,
    
    -- Source Identifiers
    ORIG_SRC_ID                 BIGINT,
    SITE_CODE                   VARCHAR(50),
    
    -- Plan Identifiers
    BENCH                       FLOAT,
    PUSHBACK                    VARCHAR(5000),
    PATTERN_NAME                VARCHAR(510),
    BLAST_NAME                  VARCHAR(5000),
    
    -- Plan Creation
    PLAN_CREATION_TS_UTC        VARCHAR(50),
    PLAN_CREATION_TS_LOCAL      VARCHAR(50),
    DESIGN_BY                   VARCHAR(500),
    
    -- Related Keys
    DRILL_CYCLE_SK              BIGINT,
    BLAST_ID                    BIGINT,
    DRILLED_HOLE_ID             BIGINT,
    
    -- Blast Details
    BLAST_TYPE                  VARCHAR(400),
    BLAST_GOAL                  VARCHAR(400),
    BLAST_DATE_UTC              VARCHAR(50),
    
    -- Hole Identification
    DRILLED_HOLE_NAME           VARCHAR(500),
    DRILLED_HOLE_FLAG           BOOLEAN,
    
    -- Hole Coordinates (Meters)
    HOLE_START_METERS_X         FLOAT,
    HOLE_START_METERS_Y         FLOAT,
    HOLE_START_METERS_Z         FLOAT,
    
    -- Hole Coordinates (Feet)
    HOLE_START_FEET_X           FLOAT,
    HOLE_START_FEET_Y           FLOAT,
    HOLE_START_FEET_Z           FLOAT,
    
    -- Depth
    DEPTH_METERS                FLOAT,
    DEPTH_FEET                  FLOAT,
    
    -- Charge Configuration
    CHARGE_RULE_NAME            VARCHAR(100),
    EXPLOSIVE_PRODUCT_BOTTOM    BIGINT,
    EXPLOSIVE_PRODUCT_TOP       BIGINT,
    EXPLOSIVE_PRODUCT_COUNT     BIGINT,
    
    -- Explosive Product Usage (Kilograms/Pounds)
    EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS  FLOAT,
    EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS     FLOAT,
    EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS     FLOAT,
    EXPLOSIVE_PRODUCT_USED_TOP_POUNDS        FLOAT,
    
    -- Explosive Product Length (Meters/Feet)
    EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS   FLOAT,
    EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET     FLOAT,
    EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS      FLOAT,
    EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET        FLOAT,
    
    -- Stemming (Meters/Feet)
    STEMMING_LENGTH_TOTAL_METERS    FLOAT,
    STEMMING_LENGTH_TOTAL_FEET      FLOAT,
    STEMMING_LENGTH_BOTTOM_METERS   FLOAT,
    STEMMING_LENGTH_BOTTOM_FEET     FLOAT,
    STEMMING_LENGTH_TOP_METERS      FLOAT,
    STEMMING_LENGTH_TOP_FEET        FLOAT,
    
    -- Air Bag
    AIR_BAG_ELEVATION_METERS    FLOAT,
    AIR_BAG_ELEVATION_FEET      FLOAT,
    AIR_BAG_FLAG                BOOLEAN,
    
    -- Air
    AIR_ELEVATION_METERS        FLOAT,
    AIR_ELEVATION_FEET          FLOAT,
    AIR_FLAG                    BOOLEAN,
    
    -- Spacing and Burden
    BURDEN_METERS               FLOAT,
    BURDEN_FEET                 FLOAT,
    SPACING_METERS              FLOAT,
    SPACING_FEET                FLOAT,
    
    -- Calculated Metrics
    TONS_PER_HOLE               FLOAT,
    HOLE_REMOVED_FLAG           BOOLEAN,
    KCALS_PER_TON               FLOAT,
    POWDER_FACTOR               FLOAT,
    MEGAJOULES_PER_TON          FLOAT,
    CONFINEMENT_FACTOR          FLOAT,
    TIMING_RATIO                FLOAT,
    TARGET_P80                  FLOAT,
    REACTIVE_GROUND_FLAG        DECIMAL(18,5),
    PRIMER_COUNT                INT,
    
    -- Data Warehouse Audit Columns
    DW_LOAD_TS                  TIMESTAMP_NTZ,
    DW_MODIFY_TS                TIMESTAMP_NTZ,
    DW_LOGICAL_DELETE_FLAG      VARCHAR(1)      DEFAULT 'N',
    DW_ROW_HASH                 VARCHAR(64),
    
    -- Primary Key
    CONSTRAINT PK_BLAST_PLAN_INCR PRIMARY KEY (BLAST_PLAN_SK)
);

-- =============================================================================
-- STORED PROCEDURE
-- =============================================================================
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.SP_BLAST_PLAN_INCR(
    P_DAYS_BACK FLOAT DEFAULT 3,
    P_MAX_DAYS FLOAT DEFAULT 30
)
RETURNS VARIANT
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var result = {
        procedure: 'SP_BLAST_PLAN_INCR',
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
            MERGE INTO DEV_API_REF.FUSE.BLAST_PLAN_INCR AS TGT
            USING (
                SELECT 
                    BLAST_PLAN_SK,
                    ORIG_SRC_ID,
                    SITE_CODE,
                    BENCH,
                    PUSHBACK,
                    PATTERN_NAME,
                    BLAST_NAME,
                    TRY_TO_TIMESTAMP(PLAN_CREATION_TS_UTC)       AS PLAN_CREATION_TS_UTC,
                    TRY_TO_TIMESTAMP(PLAN_CREATION_TS_LOCAL)     AS PLAN_CREATION_TS_LOCAL,
                    DESIGN_BY,
                    DRILL_CYCLE_SK,
                    BLAST_ID,
                    DRILLED_HOLE_ID,
                    BLAST_TYPE,
                    BLAST_GOAL,
                    BLAST_DATE_UTC,
                    DRILLED_HOLE_NAME,
                    DRILLED_HOLE_FLAG,
                    HOLE_START_METERS_X,
                    HOLE_START_METERS_Y,
                    HOLE_START_METERS_Z,
                    HOLE_START_FEET_X,
                    HOLE_START_FEET_Y,
                    HOLE_START_FEET_Z,
                    DEPTH_METERS,
                    DEPTH_FEET,
                    CHARGE_RULE_NAME,
                    EXPLOSIVE_PRODUCT_BOTTOM,
                    EXPLOSIVE_PRODUCT_TOP,
                    EXPLOSIVE_PRODUCT_COUNT,
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
                    AIR_BAG_ELEVATION_METERS,
                    AIR_BAG_ELEVATION_FEET,
                    AIR_BAG_FLAG,
                    AIR_ELEVATION_METERS,
                    AIR_ELEVATION_FEET,
                    AIR_FLAG,
                    BURDEN_METERS,
                    BURDEN_FEET,
                    SPACING_METERS,
                    SPACING_FEET,
                    TONS_PER_HOLE,
                    HOLE_REMOVED_FLAG,
                    KCALS_PER_TON,
                    POWDER_FACTOR,
                    MEGAJOULES_PER_TON,
                    CONFINEMENT_FACTOR,
                    TIMING_RATIO,
                    TARGET_P80,
                    REACTIVE_GROUND_FLAG,
                    PRIMER_COUNT,
                    TRY_TO_TIMESTAMP(DW_LOAD_TS)    AS DW_LOAD_TS,
                    TRY_TO_TIMESTAMP(DW_MODIFY_TS)  AS DW_MODIFY_TS,
                    'N'                             AS DW_LOGICAL_DELETE_FLAG,
                    SHA2(CONCAT_WS('|',
                        COALESCE(CAST(BLAST_PLAN_SK AS VARCHAR), ''),
                        COALESCE(CAST(ORIG_SRC_ID AS VARCHAR), ''),
                        COALESCE(SITE_CODE, ''),
                        COALESCE(CAST(BENCH AS VARCHAR), ''),
                        COALESCE(PUSHBACK, ''),
                        COALESCE(PATTERN_NAME, ''),
                        COALESCE(BLAST_NAME, ''),
                        COALESCE(BLAST_TYPE, ''),
                        COALESCE(BLAST_GOAL, ''),
                        COALESCE(DRILLED_HOLE_NAME, ''),
                        COALESCE(CAST(DEPTH_METERS AS VARCHAR), ''),
                        COALESCE(CAST(DEPTH_FEET AS VARCHAR), ''),
                        COALESCE(CAST(TONS_PER_HOLE AS VARCHAR), ''),
                        COALESCE(CAST(POWDER_FACTOR AS VARCHAR), '')
                    ), 256) AS DW_ROW_HASH
                FROM PROD_WG.DRILL_BLAST.BLAST_PLAN
                WHERE TRY_TO_TIMESTAMP(DW_MODIFY_TS) >= '${cutoffTs}'
            ) AS SRC
            ON TGT.BLAST_PLAN_SK = SRC.BLAST_PLAN_SK
            
            WHEN MATCHED AND TGT.DW_ROW_HASH != SRC.DW_ROW_HASH THEN UPDATE SET
                TGT.ORIG_SRC_ID = SRC.ORIG_SRC_ID,
                TGT.SITE_CODE = SRC.SITE_CODE,
                TGT.BENCH = SRC.BENCH,
                TGT.PUSHBACK = SRC.PUSHBACK,
                TGT.PATTERN_NAME = SRC.PATTERN_NAME,
                TGT.BLAST_NAME = SRC.BLAST_NAME,
                TGT.PLAN_CREATION_TS_UTC = SRC.PLAN_CREATION_TS_UTC,
                TGT.PLAN_CREATION_TS_LOCAL = SRC.PLAN_CREATION_TS_LOCAL,
                TGT.DESIGN_BY = SRC.DESIGN_BY,
                TGT.DRILL_CYCLE_SK = SRC.DRILL_CYCLE_SK,
                TGT.BLAST_ID = SRC.BLAST_ID,
                TGT.DRILLED_HOLE_ID = SRC.DRILLED_HOLE_ID,
                TGT.BLAST_TYPE = SRC.BLAST_TYPE,
                TGT.BLAST_GOAL = SRC.BLAST_GOAL,
                TGT.BLAST_DATE_UTC = SRC.BLAST_DATE_UTC,
                TGT.DRILLED_HOLE_NAME = SRC.DRILLED_HOLE_NAME,
                TGT.DRILLED_HOLE_FLAG = SRC.DRILLED_HOLE_FLAG,
                TGT.HOLE_START_METERS_X = SRC.HOLE_START_METERS_X,
                TGT.HOLE_START_METERS_Y = SRC.HOLE_START_METERS_Y,
                TGT.HOLE_START_METERS_Z = SRC.HOLE_START_METERS_Z,
                TGT.HOLE_START_FEET_X = SRC.HOLE_START_FEET_X,
                TGT.HOLE_START_FEET_Y = SRC.HOLE_START_FEET_Y,
                TGT.HOLE_START_FEET_Z = SRC.HOLE_START_FEET_Z,
                TGT.DEPTH_METERS = SRC.DEPTH_METERS,
                TGT.DEPTH_FEET = SRC.DEPTH_FEET,
                TGT.CHARGE_RULE_NAME = SRC.CHARGE_RULE_NAME,
                TGT.EXPLOSIVE_PRODUCT_BOTTOM = SRC.EXPLOSIVE_PRODUCT_BOTTOM,
                TGT.EXPLOSIVE_PRODUCT_TOP = SRC.EXPLOSIVE_PRODUCT_TOP,
                TGT.EXPLOSIVE_PRODUCT_COUNT = SRC.EXPLOSIVE_PRODUCT_COUNT,
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
                TGT.AIR_BAG_ELEVATION_METERS = SRC.AIR_BAG_ELEVATION_METERS,
                TGT.AIR_BAG_ELEVATION_FEET = SRC.AIR_BAG_ELEVATION_FEET,
                TGT.AIR_BAG_FLAG = SRC.AIR_BAG_FLAG,
                TGT.AIR_ELEVATION_METERS = SRC.AIR_ELEVATION_METERS,
                TGT.AIR_ELEVATION_FEET = SRC.AIR_ELEVATION_FEET,
                TGT.AIR_FLAG = SRC.AIR_FLAG,
                TGT.BURDEN_METERS = SRC.BURDEN_METERS,
                TGT.BURDEN_FEET = SRC.BURDEN_FEET,
                TGT.SPACING_METERS = SRC.SPACING_METERS,
                TGT.SPACING_FEET = SRC.SPACING_FEET,
                TGT.TONS_PER_HOLE = SRC.TONS_PER_HOLE,
                TGT.HOLE_REMOVED_FLAG = SRC.HOLE_REMOVED_FLAG,
                TGT.KCALS_PER_TON = SRC.KCALS_PER_TON,
                TGT.POWDER_FACTOR = SRC.POWDER_FACTOR,
                TGT.MEGAJOULES_PER_TON = SRC.MEGAJOULES_PER_TON,
                TGT.CONFINEMENT_FACTOR = SRC.CONFINEMENT_FACTOR,
                TGT.TIMING_RATIO = SRC.TIMING_RATIO,
                TGT.TARGET_P80 = SRC.TARGET_P80,
                TGT.REACTIVE_GROUND_FLAG = SRC.REACTIVE_GROUND_FLAG,
                TGT.PRIMER_COUNT = SRC.PRIMER_COUNT,
                TGT.DW_LOAD_TS = SRC.DW_LOAD_TS,
                TGT.DW_MODIFY_TS = SRC.DW_MODIFY_TS,
                TGT.DW_LOGICAL_DELETE_FLAG = SRC.DW_LOGICAL_DELETE_FLAG,
                TGT.DW_ROW_HASH = SRC.DW_ROW_HASH
            
            WHEN NOT MATCHED THEN INSERT (
                BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME,
                PLAN_CREATION_TS_UTC, PLAN_CREATION_TS_LOCAL, DESIGN_BY, DRILL_CYCLE_SK, BLAST_ID,
                DRILLED_HOLE_ID, BLAST_TYPE, BLAST_GOAL, BLAST_DATE_UTC, DRILLED_HOLE_NAME,
                DRILLED_HOLE_FLAG, HOLE_START_METERS_X, HOLE_START_METERS_Y, HOLE_START_METERS_Z,
                HOLE_START_FEET_X, HOLE_START_FEET_Y, HOLE_START_FEET_Z, DEPTH_METERS, DEPTH_FEET,
                CHARGE_RULE_NAME, EXPLOSIVE_PRODUCT_BOTTOM, EXPLOSIVE_PRODUCT_TOP, EXPLOSIVE_PRODUCT_COUNT,
                EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS, EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
                EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS, EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
                EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS, EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
                EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS, EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
                STEMMING_LENGTH_TOTAL_METERS, STEMMING_LENGTH_TOTAL_FEET, STEMMING_LENGTH_BOTTOM_METERS,
                STEMMING_LENGTH_BOTTOM_FEET, STEMMING_LENGTH_TOP_METERS, STEMMING_LENGTH_TOP_FEET,
                AIR_BAG_ELEVATION_METERS, AIR_BAG_ELEVATION_FEET, AIR_BAG_FLAG, AIR_ELEVATION_METERS,
                AIR_ELEVATION_FEET, AIR_FLAG, BURDEN_METERS, BURDEN_FEET, SPACING_METERS, SPACING_FEET,
                TONS_PER_HOLE, HOLE_REMOVED_FLAG, KCALS_PER_TON, POWDER_FACTOR, MEGAJOULES_PER_TON,
                CONFINEMENT_FACTOR, TIMING_RATIO, TARGET_P80, REACTIVE_GROUND_FLAG, PRIMER_COUNT,
                DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG, DW_ROW_HASH
            ) VALUES (
                SRC.BLAST_PLAN_SK, SRC.ORIG_SRC_ID, SRC.SITE_CODE, SRC.BENCH, SRC.PUSHBACK, SRC.PATTERN_NAME,
                SRC.BLAST_NAME, SRC.PLAN_CREATION_TS_UTC, SRC.PLAN_CREATION_TS_LOCAL, SRC.DESIGN_BY,
                SRC.DRILL_CYCLE_SK, SRC.BLAST_ID, SRC.DRILLED_HOLE_ID, SRC.BLAST_TYPE, SRC.BLAST_GOAL,
                SRC.BLAST_DATE_UTC, SRC.DRILLED_HOLE_NAME, SRC.DRILLED_HOLE_FLAG, SRC.HOLE_START_METERS_X,
                SRC.HOLE_START_METERS_Y, SRC.HOLE_START_METERS_Z, SRC.HOLE_START_FEET_X, SRC.HOLE_START_FEET_Y,
                SRC.HOLE_START_FEET_Z, SRC.DEPTH_METERS, SRC.DEPTH_FEET, SRC.CHARGE_RULE_NAME,
                SRC.EXPLOSIVE_PRODUCT_BOTTOM, SRC.EXPLOSIVE_PRODUCT_TOP, SRC.EXPLOSIVE_PRODUCT_COUNT,
                SRC.EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS, SRC.EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
                SRC.EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS, SRC.EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
                SRC.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS, SRC.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
                SRC.EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS, SRC.EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
                SRC.STEMMING_LENGTH_TOTAL_METERS, SRC.STEMMING_LENGTH_TOTAL_FEET, SRC.STEMMING_LENGTH_BOTTOM_METERS,
                SRC.STEMMING_LENGTH_BOTTOM_FEET, SRC.STEMMING_LENGTH_TOP_METERS, SRC.STEMMING_LENGTH_TOP_FEET,
                SRC.AIR_BAG_ELEVATION_METERS, SRC.AIR_BAG_ELEVATION_FEET, SRC.AIR_BAG_FLAG, SRC.AIR_ELEVATION_METERS,
                SRC.AIR_ELEVATION_FEET, SRC.AIR_FLAG, SRC.BURDEN_METERS, SRC.BURDEN_FEET, SRC.SPACING_METERS,
                SRC.SPACING_FEET, SRC.TONS_PER_HOLE, SRC.HOLE_REMOVED_FLAG, SRC.KCALS_PER_TON, SRC.POWDER_FACTOR,
                SRC.MEGAJOULES_PER_TON, SRC.CONFINEMENT_FACTOR, SRC.TIMING_RATIO, SRC.TARGET_P80,
                SRC.REACTIVE_GROUND_FLAG, SRC.PRIMER_COUNT, SRC.DW_LOAD_TS, SRC.DW_MODIFY_TS,
                SRC.DW_LOGICAL_DELETE_FLAG, SRC.DW_ROW_HASH
            )
        `;
        
        var mergeStmt = snowflake.createStatement({sqlText: mergeSQL});
        var mergeResult = mergeStmt.execute();
        mergeResult.next();
        result.rows_merged = mergeStmt.getNumRowsAffected();
        
        // Handle soft deletes for records no longer in source
        var softDeleteSQL = `
            UPDATE DEV_API_REF.FUSE.BLAST_PLAN_INCR
            SET DW_LOGICAL_DELETE_FLAG = 'Y',
                DW_MODIFY_TS = CURRENT_TIMESTAMP()
            WHERE BLAST_PLAN_SK NOT IN (
                SELECT BLAST_PLAN_SK FROM PROD_WG.DRILL_BLAST.BLAST_PLAN
            )
            AND DW_LOGICAL_DELETE_FLAG = 'N'
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
-- CALL DEV_API_REF.FUSE.SP_BLAST_PLAN_INCR();

-- Custom lookback period
-- CALL DEV_API_REF.FUSE.SP_BLAST_PLAN_INCR(7, 30);

-- Full reload (30 days max)
-- CALL DEV_API_REF.FUSE.SP_BLAST_PLAN_INCR(30, 30);
