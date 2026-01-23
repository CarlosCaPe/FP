/*******************************************************************************
 * DRILL_PLAN_INCR - Incremental Table and Stored Procedure
 * 
 * Source: PROD_WG.DRILL_BLAST.DRILL_PLAN
 * Target: DEV_API_REF.FUSE.DRILL_PLAN_INCR
 * Business Key: DRILL_PLAN_SK
 * Timestamp Column: DW_MODIFY_TS
 * 
 * Pattern: MERGE-driven upserts with hash-based conditional updates
 * Incremental Window: 3 days default, max 30 days
 * Soft Deletes: DW_LOGICAL_DELETE_FLAG = 'Y'
 ******************************************************************************/

-- =============================================================================
-- TABLE DDL
-- =============================================================================
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.DRILL_PLAN_INCR (
    -- Business Key
    DRILL_PLAN_SK               BIGINT          NOT NULL,
    
    -- Source Identifiers
    ORIG_SRC_ID                 BIGINT,
    SITE_CODE                   VARCHAR(5),
    
    -- Pattern Identifiers
    BENCH                       DECIMAL(38,1),
    PUSHBACK                    VARCHAR(5000),
    PATTERN_NAME                VARCHAR(510),
    ORIGINAL_PATTERN_NAME       VARCHAR(510),
    
    -- Plan Creation
    PLAN_CREATION_TS_UTC        VARCHAR(50),
    PLAN_CREATION_TS_LOCAL      VARCHAR(50),
    DESIGN_BY                   VARCHAR(100),
    
    -- Hole Identification
    HOLE_NAME                   VARCHAR(256),
    
    -- Hole Diameter
    HOLE_DIAMETER_MM            DECIMAL(38,5),
    HOLE_DIAMETER_INCHES        DECIMAL(38,5),
    
    -- Hole Depth
    HOLE_DEPTH_METERS           DECIMAL(38,5),
    HOLE_DEPTH_FEET             DECIMAL(38,5),
    
    -- Hole Start Coordinates (Meters)
    HOLE_START_METERS_X         DECIMAL(38,5),
    HOLE_START_METERS_Y         DECIMAL(38,5),
    HOLE_START_METERS_Z         DECIMAL(38,5),
    
    -- Hole End Coordinates (Meters)
    HOLE_END_METERS_X           DECIMAL(38,5),
    HOLE_END_METERS_Y           DECIMAL(38,5),
    HOLE_END_METERS_Z           DECIMAL(38,5),
    
    -- Hole Start Coordinates (Feet)
    HOLE_START_FEET_X           DECIMAL(38,5),
    HOLE_START_FEET_Y           DECIMAL(38,5),
    HOLE_START_FEET_Z           DECIMAL(38,5),
    
    -- Hole End Coordinates (Feet)
    HOLE_END_FEET_X             DECIMAL(38,5),
    HOLE_END_FEET_Y             DECIMAL(38,5),
    HOLE_END_FEET_Z             DECIMAL(38,5),
    
    -- Spacing and Burden
    BURDEN                      FLOAT,
    SPACING                     FLOAT,
    
    -- Geotechnical Parameters
    TONS_PER_HOLE               VARCHAR(5000),
    BLASTABILITY_INDEX          VARCHAR(5000),
    RQD                         VARCHAR(5000),
    UCS                         VARCHAR(5000),
    PREDICTED_PENRATE           VARCHAR(5000),
    PROJECTED_MECHANICAL_SPECIFIC_ENERGY VARCHAR(5000),
    TARGET_P80                  VARCHAR(5000),
    SHOT_GOAL                   VARCHAR(5000),
    
    -- System Version
    SYSTEM_VERSION              VARCHAR(20),
    
    -- Data Warehouse Audit Columns
    DW_LOAD_TS                  TIMESTAMP_NTZ,
    DW_MODIFY_TS                TIMESTAMP_NTZ,
    DW_LOGICAL_DELETE_FLAG      VARCHAR(1)      DEFAULT 'N',
    DW_ROW_HASH                 VARCHAR(64),
    
    -- Primary Key
    CONSTRAINT PK_DRILL_PLAN_INCR PRIMARY KEY (DRILL_PLAN_SK)
);

-- =============================================================================
-- STORED PROCEDURE
-- =============================================================================
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.SP_DRILL_PLAN_INCR(
    P_DAYS_BACK FLOAT DEFAULT 3,
    P_MAX_DAYS FLOAT DEFAULT 30
)
RETURNS VARIANT
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var result = {
        procedure: 'SP_DRILL_PLAN_INCR',
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
            MERGE INTO DEV_API_REF.FUSE.DRILL_PLAN_INCR AS TGT
            USING (
                SELECT 
                    DRILL_PLAN_SK,
                    ORIG_SRC_ID,
                    SITE_CODE,
                    BENCH,
                    PUSHBACK,
                    PATTERN_NAME,
                    ORIGINAL_PATTERN_NAME,
                    PLAN_CREATION_TS_UTC,
                    PLAN_CREATION_TS_LOCAL,
                    DESIGN_BY,
                    HOLE_NAME,
                    HOLE_DIAMETER_MM,
                    HOLE_DIAMETER_INCHES,
                    HOLE_DEPTH_METERS,
                    HOLE_DEPTH_FEET,
                    HOLE_START_METERS_X,
                    HOLE_START_METERS_Y,
                    HOLE_START_METERS_Z,
                    HOLE_END_METERS_X,
                    HOLE_END_METERS_Y,
                    HOLE_END_METERS_Z,
                    HOLE_START_FEET_X,
                    HOLE_START_FEET_Y,
                    HOLE_START_FEET_Z,
                    HOLE_END_FEET_X,
                    HOLE_END_FEET_Y,
                    HOLE_END_FEET_Z,
                    BURDEN,
                    SPACING,
                    TONS_PER_HOLE,
                    BLASTABILITY_INDEX,
                    RQD,
                    UCS,
                    PREDICTED_PENRATE,
                    PROJECTED_MECHANICAL_SPECIFIC_ENERGY,
                    TARGET_P80,
                    SHOT_GOAL,
                    SYSTEM_VERSION,
                    TRY_TO_TIMESTAMP(DW_LOAD_TS)    AS DW_LOAD_TS,
                    TRY_TO_TIMESTAMP(DW_MODIFY_TS)  AS DW_MODIFY_TS,
                    'N'                             AS DW_LOGICAL_DELETE_FLAG,
                    SHA2(CONCAT_WS('|',
                        COALESCE(CAST(DRILL_PLAN_SK AS VARCHAR), ''),
                        COALESCE(CAST(ORIG_SRC_ID AS VARCHAR), ''),
                        COALESCE(SITE_CODE, ''),
                        COALESCE(CAST(BENCH AS VARCHAR), ''),
                        COALESCE(PATTERN_NAME, ''),
                        COALESCE(HOLE_NAME, ''),
                        COALESCE(CAST(HOLE_DEPTH_METERS AS VARCHAR), ''),
                        COALESCE(CAST(HOLE_DEPTH_FEET AS VARCHAR), ''),
                        COALESCE(CAST(BURDEN AS VARCHAR), ''),
                        COALESCE(CAST(SPACING AS VARCHAR), ''),
                        COALESCE(TONS_PER_HOLE, ''),
                        COALESCE(SHOT_GOAL, '')
                    ), 256) AS DW_ROW_HASH
                FROM PROD_WG.DRILL_BLAST.DRILL_PLAN
                WHERE TRY_TO_TIMESTAMP(DW_MODIFY_TS) >= '${cutoffTs}'
            ) AS SRC
            ON TGT.DRILL_PLAN_SK = SRC.DRILL_PLAN_SK
            
            WHEN MATCHED AND TGT.DW_ROW_HASH != SRC.DW_ROW_HASH THEN UPDATE SET
                TGT.ORIG_SRC_ID = SRC.ORIG_SRC_ID,
                TGT.SITE_CODE = SRC.SITE_CODE,
                TGT.BENCH = SRC.BENCH,
                TGT.PUSHBACK = SRC.PUSHBACK,
                TGT.PATTERN_NAME = SRC.PATTERN_NAME,
                TGT.ORIGINAL_PATTERN_NAME = SRC.ORIGINAL_PATTERN_NAME,
                TGT.PLAN_CREATION_TS_UTC = SRC.PLAN_CREATION_TS_UTC,
                TGT.PLAN_CREATION_TS_LOCAL = SRC.PLAN_CREATION_TS_LOCAL,
                TGT.DESIGN_BY = SRC.DESIGN_BY,
                TGT.HOLE_NAME = SRC.HOLE_NAME,
                TGT.HOLE_DIAMETER_MM = SRC.HOLE_DIAMETER_MM,
                TGT.HOLE_DIAMETER_INCHES = SRC.HOLE_DIAMETER_INCHES,
                TGT.HOLE_DEPTH_METERS = SRC.HOLE_DEPTH_METERS,
                TGT.HOLE_DEPTH_FEET = SRC.HOLE_DEPTH_FEET,
                TGT.HOLE_START_METERS_X = SRC.HOLE_START_METERS_X,
                TGT.HOLE_START_METERS_Y = SRC.HOLE_START_METERS_Y,
                TGT.HOLE_START_METERS_Z = SRC.HOLE_START_METERS_Z,
                TGT.HOLE_END_METERS_X = SRC.HOLE_END_METERS_X,
                TGT.HOLE_END_METERS_Y = SRC.HOLE_END_METERS_Y,
                TGT.HOLE_END_METERS_Z = SRC.HOLE_END_METERS_Z,
                TGT.HOLE_START_FEET_X = SRC.HOLE_START_FEET_X,
                TGT.HOLE_START_FEET_Y = SRC.HOLE_START_FEET_Y,
                TGT.HOLE_START_FEET_Z = SRC.HOLE_START_FEET_Z,
                TGT.HOLE_END_FEET_X = SRC.HOLE_END_FEET_X,
                TGT.HOLE_END_FEET_Y = SRC.HOLE_END_FEET_Y,
                TGT.HOLE_END_FEET_Z = SRC.HOLE_END_FEET_Z,
                TGT.BURDEN = SRC.BURDEN,
                TGT.SPACING = SRC.SPACING,
                TGT.TONS_PER_HOLE = SRC.TONS_PER_HOLE,
                TGT.BLASTABILITY_INDEX = SRC.BLASTABILITY_INDEX,
                TGT.RQD = SRC.RQD,
                TGT.UCS = SRC.UCS,
                TGT.PREDICTED_PENRATE = SRC.PREDICTED_PENRATE,
                TGT.PROJECTED_MECHANICAL_SPECIFIC_ENERGY = SRC.PROJECTED_MECHANICAL_SPECIFIC_ENERGY,
                TGT.TARGET_P80 = SRC.TARGET_P80,
                TGT.SHOT_GOAL = SRC.SHOT_GOAL,
                TGT.SYSTEM_VERSION = SRC.SYSTEM_VERSION,
                TGT.DW_LOAD_TS = SRC.DW_LOAD_TS,
                TGT.DW_MODIFY_TS = SRC.DW_MODIFY_TS,
                TGT.DW_LOGICAL_DELETE_FLAG = SRC.DW_LOGICAL_DELETE_FLAG,
                TGT.DW_ROW_HASH = SRC.DW_ROW_HASH
            
            WHEN NOT MATCHED THEN INSERT (
                DRILL_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, ORIGINAL_PATTERN_NAME,
                PLAN_CREATION_TS_UTC, PLAN_CREATION_TS_LOCAL, DESIGN_BY, HOLE_NAME, HOLE_DIAMETER_MM,
                HOLE_DIAMETER_INCHES, HOLE_DEPTH_METERS, HOLE_DEPTH_FEET, HOLE_START_METERS_X,
                HOLE_START_METERS_Y, HOLE_START_METERS_Z, HOLE_END_METERS_X, HOLE_END_METERS_Y, HOLE_END_METERS_Z,
                HOLE_START_FEET_X, HOLE_START_FEET_Y, HOLE_START_FEET_Z, HOLE_END_FEET_X, HOLE_END_FEET_Y,
                HOLE_END_FEET_Z, BURDEN, SPACING, TONS_PER_HOLE, BLASTABILITY_INDEX, RQD, UCS,
                PREDICTED_PENRATE, PROJECTED_MECHANICAL_SPECIFIC_ENERGY, TARGET_P80, SHOT_GOAL, SYSTEM_VERSION,
                DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG, DW_ROW_HASH
            ) VALUES (
                SRC.DRILL_PLAN_SK, SRC.ORIG_SRC_ID, SRC.SITE_CODE, SRC.BENCH, SRC.PUSHBACK, SRC.PATTERN_NAME,
                SRC.ORIGINAL_PATTERN_NAME, SRC.PLAN_CREATION_TS_UTC, SRC.PLAN_CREATION_TS_LOCAL, SRC.DESIGN_BY,
                SRC.HOLE_NAME, SRC.HOLE_DIAMETER_MM, SRC.HOLE_DIAMETER_INCHES, SRC.HOLE_DEPTH_METERS,
                SRC.HOLE_DEPTH_FEET, SRC.HOLE_START_METERS_X, SRC.HOLE_START_METERS_Y, SRC.HOLE_START_METERS_Z,
                SRC.HOLE_END_METERS_X, SRC.HOLE_END_METERS_Y, SRC.HOLE_END_METERS_Z, SRC.HOLE_START_FEET_X,
                SRC.HOLE_START_FEET_Y, SRC.HOLE_START_FEET_Z, SRC.HOLE_END_FEET_X, SRC.HOLE_END_FEET_Y,
                SRC.HOLE_END_FEET_Z, SRC.BURDEN, SRC.SPACING, SRC.TONS_PER_HOLE, SRC.BLASTABILITY_INDEX,
                SRC.RQD, SRC.UCS, SRC.PREDICTED_PENRATE, SRC.PROJECTED_MECHANICAL_SPECIFIC_ENERGY,
                SRC.TARGET_P80, SRC.SHOT_GOAL, SRC.SYSTEM_VERSION, SRC.DW_LOAD_TS, SRC.DW_MODIFY_TS,
                SRC.DW_LOGICAL_DELETE_FLAG, SRC.DW_ROW_HASH
            )
        `;
        
        var mergeStmt = snowflake.createStatement({sqlText: mergeSQL});
        var mergeResult = mergeStmt.execute();
        mergeResult.next();
        result.rows_merged = mergeStmt.getNumRowsAffected();
        
        // Handle soft deletes for records no longer in source
        var softDeleteSQL = `
            UPDATE DEV_API_REF.FUSE.DRILL_PLAN_INCR
            SET DW_LOGICAL_DELETE_FLAG = 'Y',
                DW_MODIFY_TS = CURRENT_TIMESTAMP()
            WHERE DRILL_PLAN_SK NOT IN (
                SELECT DRILL_PLAN_SK FROM PROD_WG.DRILL_BLAST.DRILL_PLAN
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
-- CALL DEV_API_REF.FUSE.SP_DRILL_PLAN_INCR();

-- Custom lookback period
-- CALL DEV_API_REF.FUSE.SP_DRILL_PLAN_INCR(7, 30);

-- Full reload (30 days max)
-- CALL DEV_API_REF.FUSE.SP_DRILL_PLAN_INCR(30, 30);
