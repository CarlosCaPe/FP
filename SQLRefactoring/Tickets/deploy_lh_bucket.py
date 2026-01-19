"""
Simple Deploy: Just deploy the LH_BUCKET_CT table and procedure
Then run one test to verify it works
"""
import time
from snowrefactor.snowflake_conn import connect

def main():
    print("="*60)
    print("DEPLOY LH_BUCKET_CT - SIMPLE VERSION")
    print("="*60)
    
    with connect() as conn:
        cur = conn.cursor()
        
        # Set context
        print("\n[1] Setting context...")
        # Using default role (SG-AZW-SFLK-ENG-GENERAL) from connection
        cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
        cur.execute("USE DATABASE DEV_API_REF")
        cur.execute("USE SCHEMA FUSE")
        print("    ✓ Done")
        
        # Create table
        print("\n[2] Creating LH_BUCKET_CT table...")
        table_ddl = """
        CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_BUCKET_CT (
            BUCKET_ID                       NUMBER(19,0),
            SITE_CODE                       VARCHAR(4),
            LOADING_CYCLE_ID                NUMBER(19,0),
            EXCAV_ID                        VARCHAR(30),
            ORIG_SRC_ID                     NUMBER(38,0),
            BUCKET_OF_CYCLE                 NUMBER(38,0),
            SWING_EMPTY_START_TS_UTC        TIMESTAMP_NTZ(3),
            SWING_EMPTY_START_TS_LOCAL      TIMESTAMP_NTZ(3),
            SWING_EMPTY_END_TS_UTC          TIMESTAMP_NTZ(3),
            SWING_EMPTY_END_TS_LOCAL        TIMESTAMP_NTZ(3),
            DIG_START_TS_UTC                TIMESTAMP_NTZ(3),
            DIG_START_TS_LOCAL              TIMESTAMP_NTZ(3),
            DIG_END_TS_UTC                  TIMESTAMP_NTZ(3),
            DIG_END_TS_LOCAL                TIMESTAMP_NTZ(3),
            SWING_FULL_START_TS_UTC         TIMESTAMP_NTZ(3),
            SWING_FULL_START_TS_LOCAL       TIMESTAMP_NTZ(3),
            SWING_FULL_END_TS_UTC           TIMESTAMP_NTZ(3),
            SWING_FULL_END_TS_LOCAL         TIMESTAMP_NTZ(3),
            TRIP_TS_UTC                     TIMESTAMP_NTZ(3),
            TRIP_TS_LOCAL                   TIMESTAMP_NTZ(3),
            DIG_X                           FLOAT,
            DIG_Y                           FLOAT,
            DIG_Z                           FLOAT,
            TRIP_X                          FLOAT,
            TRIP_Y                          FLOAT,
            TRIP_Z                          FLOAT,
            SWING_ANGLE_DEGREES             FLOAT,
            BLOCK_CENTROID_X                FLOAT,
            BLOCK_CENTROID_Y                FLOAT,
            BLOCK_CENTROID_Z                FLOAT,
            MEASURED_SHORT_TONS             NUMBER(38,6),
            MEASURED_METRIC_TONS            NUMBER(38,6),
            SWING_EMPTY_DURATION_MINS       NUMBER(38,6),
            DIG_DURATION_MINS               NUMBER(38,6),
            SWING_FULL_DURATION_MINS        NUMBER(38,6),
            BUCKET_MATERIAL_ID              NUMBER(19,0),
            SYSTEM_VERSION                  VARCHAR(50),
            DW_LOGICAL_DELETE_FLAG          VARCHAR(1),
            DW_LOAD_TS                      TIMESTAMP_NTZ(0),
            DW_MODIFY_TS                    TIMESTAMP_NTZ(0)
        )
        COMMENT = 'CT table for LH_BUCKET'
        """
        cur.execute(table_ddl)
        print("    ✓ Table created")
        
        # Create procedure
        print("\n[3] Creating LH_BUCKET_CT_P procedure...")
        proc_ddl = '''
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_BUCKET_CT_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS $$
/*****************************************************************************************
* PURPOSE   : Merge data from LH_BUCKET_C into LH_BUCKET_CT
* NOTES     : Default 3 days, max 30 days incremental window
******************************************************************************************/

var numberOfDays = NUMBER_OF_DAYS;

// Validate input
if (numberOfDays === undefined || numberOfDays === null || numberOfDays === '') {
    numberOfDays = 3;
} else if (parseInt(numberOfDays) > 30) {
    numberOfDays = 30;
} else if (parseInt(numberOfDays) < 1) {
    numberOfDays = 1;
}

var result = "";
var rowsInserted = 0;
var rowsUpdated = 0;
var rowsArchived = 0;

try {
    snowflake.execute({sqlText: "BEGIN TRANSACTION"});

    // Archive soft-deleted records
    var archiveSQL = `
        UPDATE DEV_API_REF.FUSE.LH_BUCKET_CT tgt
        SET DW_LOGICAL_DELETE_FLAG = 'Y',
            DW_MODIFY_TS = CURRENT_TIMESTAMP()
        WHERE tgt.TRIP_TS_LOCAL >= DATEADD(day, -` + numberOfDays + `, CURRENT_TIMESTAMP())
          AND tgt.DW_LOGICAL_DELETE_FLAG = 'N'
          AND NOT EXISTS (
              SELECT 1 FROM PROD_TARGET.COLLECTIONS.LH_BUCKET_C src
              WHERE src.BUCKET_ID = tgt.BUCKET_ID
                AND src.TRIP_TS_LOCAL >= DATEADD(day, -` + numberOfDays + `, CURRENT_TIMESTAMP())
          )
    `;
    var stmt = snowflake.createStatement({sqlText: archiveSQL});
    var rs = stmt.execute();
    rowsArchived = stmt.getNumRowsAffected();

    // MERGE statement
    var mergeSQL = `
        MERGE INTO DEV_API_REF.FUSE.LH_BUCKET_CT tgt
        USING (
            SELECT 
                BUCKET_ID, SITE_CODE, LOADING_CYCLE_ID, EXCAV_ID, ORIG_SRC_ID,
                BUCKET_OF_CYCLE, SWING_EMPTY_START_TS_UTC, SWING_EMPTY_START_TS_LOCAL,
                SWING_EMPTY_END_TS_UTC, SWING_EMPTY_END_TS_LOCAL, DIG_START_TS_UTC,
                DIG_START_TS_LOCAL, DIG_END_TS_UTC, DIG_END_TS_LOCAL,
                SWING_FULL_START_TS_UTC, SWING_FULL_START_TS_LOCAL, SWING_FULL_END_TS_UTC,
                SWING_FULL_END_TS_LOCAL, TRIP_TS_UTC, TRIP_TS_LOCAL, DIG_X, DIG_Y, DIG_Z,
                TRIP_X, TRIP_Y, TRIP_Z, SWING_ANGLE_DEGREES, BLOCK_CENTROID_X,
                BLOCK_CENTROID_Y, BLOCK_CENTROID_Z, MEASURED_SHORT_TONS,
                MEASURED_METRIC_TONS, SWING_EMPTY_DURATION_MINS, DIG_DURATION_MINS,
                SWING_FULL_DURATION_MINS, BUCKET_MATERIAL_ID, SYSTEM_VERSION
            FROM PROD_TARGET.COLLECTIONS.LH_BUCKET_C
            WHERE TRIP_TS_LOCAL >= DATEADD(day, -` + numberOfDays + `, CURRENT_TIMESTAMP())
        ) src
        ON tgt.BUCKET_ID = src.BUCKET_ID
        WHEN MATCHED AND (
            HASH(src.SITE_CODE, src.LOADING_CYCLE_ID, src.EXCAV_ID, src.ORIG_SRC_ID,
                 src.BUCKET_OF_CYCLE, src.SWING_EMPTY_START_TS_UTC, src.SWING_EMPTY_START_TS_LOCAL,
                 src.SWING_EMPTY_END_TS_UTC, src.SWING_EMPTY_END_TS_LOCAL, src.DIG_START_TS_UTC,
                 src.DIG_START_TS_LOCAL, src.DIG_END_TS_UTC, src.DIG_END_TS_LOCAL,
                 src.SWING_FULL_START_TS_UTC, src.SWING_FULL_START_TS_LOCAL, src.SWING_FULL_END_TS_UTC,
                 src.SWING_FULL_END_TS_LOCAL, src.TRIP_TS_UTC, src.TRIP_TS_LOCAL,
                 src.DIG_X, src.DIG_Y, src.DIG_Z, src.TRIP_X, src.TRIP_Y, src.TRIP_Z,
                 src.SWING_ANGLE_DEGREES, src.BLOCK_CENTROID_X, src.BLOCK_CENTROID_Y,
                 src.BLOCK_CENTROID_Z, src.MEASURED_SHORT_TONS, src.MEASURED_METRIC_TONS,
                 src.SWING_EMPTY_DURATION_MINS, src.DIG_DURATION_MINS, src.SWING_FULL_DURATION_MINS,
                 src.BUCKET_MATERIAL_ID, src.SYSTEM_VERSION)
            <>
            HASH(tgt.SITE_CODE, tgt.LOADING_CYCLE_ID, tgt.EXCAV_ID, tgt.ORIG_SRC_ID,
                 tgt.BUCKET_OF_CYCLE, tgt.SWING_EMPTY_START_TS_UTC, tgt.SWING_EMPTY_START_TS_LOCAL,
                 tgt.SWING_EMPTY_END_TS_UTC, tgt.SWING_EMPTY_END_TS_LOCAL, tgt.DIG_START_TS_UTC,
                 tgt.DIG_START_TS_LOCAL, tgt.DIG_END_TS_UTC, tgt.DIG_END_TS_LOCAL,
                 tgt.SWING_FULL_START_TS_UTC, tgt.SWING_FULL_START_TS_LOCAL, tgt.SWING_FULL_END_TS_UTC,
                 tgt.SWING_FULL_END_TS_LOCAL, tgt.TRIP_TS_UTC, tgt.TRIP_TS_LOCAL,
                 tgt.DIG_X, tgt.DIG_Y, tgt.DIG_Z, tgt.TRIP_X, tgt.TRIP_Y, tgt.TRIP_Z,
                 tgt.SWING_ANGLE_DEGREES, tgt.BLOCK_CENTROID_X, tgt.BLOCK_CENTROID_Y,
                 tgt.BLOCK_CENTROID_Z, tgt.MEASURED_SHORT_TONS, tgt.MEASURED_METRIC_TONS,
                 tgt.SWING_EMPTY_DURATION_MINS, tgt.DIG_DURATION_MINS, tgt.SWING_FULL_DURATION_MINS,
                 tgt.BUCKET_MATERIAL_ID, tgt.SYSTEM_VERSION)
            OR tgt.DW_LOGICAL_DELETE_FLAG = 'Y'
        )
        THEN UPDATE SET
            tgt.SITE_CODE = src.SITE_CODE,
            tgt.LOADING_CYCLE_ID = src.LOADING_CYCLE_ID,
            tgt.EXCAV_ID = src.EXCAV_ID,
            tgt.ORIG_SRC_ID = src.ORIG_SRC_ID,
            tgt.BUCKET_OF_CYCLE = src.BUCKET_OF_CYCLE,
            tgt.SWING_EMPTY_START_TS_UTC = src.SWING_EMPTY_START_TS_UTC,
            tgt.SWING_EMPTY_START_TS_LOCAL = src.SWING_EMPTY_START_TS_LOCAL,
            tgt.SWING_EMPTY_END_TS_UTC = src.SWING_EMPTY_END_TS_UTC,
            tgt.SWING_EMPTY_END_TS_LOCAL = src.SWING_EMPTY_END_TS_LOCAL,
            tgt.DIG_START_TS_UTC = src.DIG_START_TS_UTC,
            tgt.DIG_START_TS_LOCAL = src.DIG_START_TS_LOCAL,
            tgt.DIG_END_TS_UTC = src.DIG_END_TS_UTC,
            tgt.DIG_END_TS_LOCAL = src.DIG_END_TS_LOCAL,
            tgt.SWING_FULL_START_TS_UTC = src.SWING_FULL_START_TS_UTC,
            tgt.SWING_FULL_START_TS_LOCAL = src.SWING_FULL_START_TS_LOCAL,
            tgt.SWING_FULL_END_TS_UTC = src.SWING_FULL_END_TS_UTC,
            tgt.SWING_FULL_END_TS_LOCAL = src.SWING_FULL_END_TS_LOCAL,
            tgt.TRIP_TS_UTC = src.TRIP_TS_UTC,
            tgt.TRIP_TS_LOCAL = src.TRIP_TS_LOCAL,
            tgt.DIG_X = src.DIG_X,
            tgt.DIG_Y = src.DIG_Y,
            tgt.DIG_Z = src.DIG_Z,
            tgt.TRIP_X = src.TRIP_X,
            tgt.TRIP_Y = src.TRIP_Y,
            tgt.TRIP_Z = src.TRIP_Z,
            tgt.SWING_ANGLE_DEGREES = src.SWING_ANGLE_DEGREES,
            tgt.BLOCK_CENTROID_X = src.BLOCK_CENTROID_X,
            tgt.BLOCK_CENTROID_Y = src.BLOCK_CENTROID_Y,
            tgt.BLOCK_CENTROID_Z = src.BLOCK_CENTROID_Z,
            tgt.MEASURED_SHORT_TONS = src.MEASURED_SHORT_TONS,
            tgt.MEASURED_METRIC_TONS = src.MEASURED_METRIC_TONS,
            tgt.SWING_EMPTY_DURATION_MINS = src.SWING_EMPTY_DURATION_MINS,
            tgt.DIG_DURATION_MINS = src.DIG_DURATION_MINS,
            tgt.SWING_FULL_DURATION_MINS = src.SWING_FULL_DURATION_MINS,
            tgt.BUCKET_MATERIAL_ID = src.BUCKET_MATERIAL_ID,
            tgt.SYSTEM_VERSION = src.SYSTEM_VERSION,
            tgt.DW_LOGICAL_DELETE_FLAG = 'N',
            tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP()
        WHEN NOT MATCHED THEN INSERT (
            BUCKET_ID, SITE_CODE, LOADING_CYCLE_ID, EXCAV_ID, ORIG_SRC_ID,
            BUCKET_OF_CYCLE, SWING_EMPTY_START_TS_UTC, SWING_EMPTY_START_TS_LOCAL,
            SWING_EMPTY_END_TS_UTC, SWING_EMPTY_END_TS_LOCAL, DIG_START_TS_UTC,
            DIG_START_TS_LOCAL, DIG_END_TS_UTC, DIG_END_TS_LOCAL,
            SWING_FULL_START_TS_UTC, SWING_FULL_START_TS_LOCAL, SWING_FULL_END_TS_UTC,
            SWING_FULL_END_TS_LOCAL, TRIP_TS_UTC, TRIP_TS_LOCAL, DIG_X, DIG_Y, DIG_Z,
            TRIP_X, TRIP_Y, TRIP_Z, SWING_ANGLE_DEGREES, BLOCK_CENTROID_X,
            BLOCK_CENTROID_Y, BLOCK_CENTROID_Z, MEASURED_SHORT_TONS,
            MEASURED_METRIC_TONS, SWING_EMPTY_DURATION_MINS, DIG_DURATION_MINS,
            SWING_FULL_DURATION_MINS, BUCKET_MATERIAL_ID, SYSTEM_VERSION,
            DW_LOGICAL_DELETE_FLAG, DW_LOAD_TS, DW_MODIFY_TS
        ) VALUES (
            src.BUCKET_ID, src.SITE_CODE, src.LOADING_CYCLE_ID, src.EXCAV_ID, src.ORIG_SRC_ID,
            src.BUCKET_OF_CYCLE, src.SWING_EMPTY_START_TS_UTC, src.SWING_EMPTY_START_TS_LOCAL,
            src.SWING_EMPTY_END_TS_UTC, src.SWING_EMPTY_END_TS_LOCAL, src.DIG_START_TS_UTC,
            src.DIG_START_TS_LOCAL, src.DIG_END_TS_UTC, src.DIG_END_TS_LOCAL,
            src.SWING_FULL_START_TS_UTC, src.SWING_FULL_START_TS_LOCAL, src.SWING_FULL_END_TS_UTC,
            src.SWING_FULL_END_TS_LOCAL, src.TRIP_TS_UTC, src.TRIP_TS_LOCAL,
            src.DIG_X, src.DIG_Y, src.DIG_Z, src.TRIP_X, src.TRIP_Y, src.TRIP_Z,
            src.SWING_ANGLE_DEGREES, src.BLOCK_CENTROID_X, src.BLOCK_CENTROID_Y,
            src.BLOCK_CENTROID_Z, src.MEASURED_SHORT_TONS, src.MEASURED_METRIC_TONS,
            src.SWING_EMPTY_DURATION_MINS, src.DIG_DURATION_MINS, src.SWING_FULL_DURATION_MINS,
            src.BUCKET_MATERIAL_ID, src.SYSTEM_VERSION,
            'N', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
        )
    `;
    
    stmt = snowflake.createStatement({sqlText: mergeSQL});
    rs = stmt.execute();
    
    // Get merge stats
    rs.next();
    rowsInserted = stmt.getNumRowsInserted();
    rowsUpdated = stmt.getNumRowsUpdated();

    snowflake.execute({sqlText: "COMMIT"});
    
    result = "SUCCESS: Inserted=" + rowsInserted + ", Updated=" + rowsUpdated + ", Archived=" + rowsArchived;

} catch (err) {
    snowflake.execute({sqlText: "ROLLBACK"});
    result = "ERROR: " + err.message;
}

return result;
$$;
'''
        cur.execute(proc_ddl)
        print("    ✓ Procedure created")
        
        # Test with 3 days
        print("\n[4] Testing with 3 days...")
        start = time.time()
        cur.execute("CALL DEV_API_REF.FUSE.LH_BUCKET_CT_P('3')")
        result = cur.fetchone()[0]
        duration = time.time() - start
        print(f"    ✓ Result: {result}")
        print(f"    ✓ Duration: {duration:.2f}s")
        
        # Get row count
        cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_CT")
        row_count = cur.fetchone()[0]
        print(f"    ✓ Rows: {row_count:,}")
        
    print("\n" + "="*60)
    print("DONE!")
    print("="*60)

if __name__ == "__main__":
    main()
