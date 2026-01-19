"""
Deploy LH_LOADING_CYCLE_CT table and procedure
"""
import time
from snowrefactor.snowflake_conn import connect

def main():
    print("="*60)
    print("DEPLOY LH_LOADING_CYCLE_CT")
    print("="*60)
    
    with connect() as conn:
        cur = conn.cursor()
        
        # Set context
        print("\n[1] Setting context...")
        cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
        cur.execute("USE DATABASE DEV_API_REF")
        cur.execute("USE SCHEMA FUSE")
        print("    ✓ Done")
        
        # Create table
        print("\n[2] Creating LH_LOADING_CYCLE_CT table...")
        table_ddl = """
        CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT (
            LOADING_CYCLE_ID                NUMBER(19,0),
            SITE_CODE                       VARCHAR(4),
            ORIG_SRC_ID                     NUMBER(38,0),
            SHIFT_ID                        VARCHAR(12),
            LOADING_CYCLE_OF_SHIFT          NUMBER(38,0),
            EXCAV_CYCLE_OF_SHIFT            NUMBER(38,0),
            CYCLE_START_TS_UTC              TIMESTAMP_NTZ(3),
            CYCLE_START_TS_LOCAL            TIMESTAMP_NTZ(3),
            CYCLE_END_TS_UTC                TIMESTAMP_NTZ(3),
            CYCLE_END_TS_LOCAL              TIMESTAMP_NTZ(3),
            MEASURED_PAYLOAD_SHORT_TONS     NUMBER(38,6),
            MEASURED_PAYLOAD_METRIC_TONS    NUMBER(38,6),
            AVG_SWING_DURATION_MINS         NUMBER(38,6),
            AVG_DIG_DURATION_MINS           NUMBER(38,6),
            HANG_DURATION_MINS              NUMBER(38,6),
            IDLE_DURATION_MINS              NUMBER(38,6),
            BUCKET_COUNT                    NUMBER(38,0),
            EXCAV_ID                        NUMBER(19,0),
            TRUCK_ID                        NUMBER(19,0),
            EXCAV                           VARCHAR(50),
            TRUCK                           VARCHAR(50),
            EXCAV_OPERATOR_ID               NUMBER(19,0),
            MATERIAL_ID                     NUMBER(19,0),
            LOADING_LOC_ID                  NUMBER(19,0),
            INTERRUPTED_LOADING_FLAG        NUMBER(1,0),
            ASSOCIATED_HAUL_CYCLE_FLAG      NUMBER(1,0),
            OVER_TRUCKED_FLAG               NUMBER(1,0),
            UNDER_TRUCKED_FLAG              NUMBER(1,0),
            HAUL_CYCLE_ID                   NUMBER(19,0),
            SYSTEM_VERSION                  VARCHAR(50),
            DW_LOGICAL_DELETE_FLAG          VARCHAR(1),
            DW_LOAD_TS                      TIMESTAMP_NTZ(0),
            DW_MODIFY_TS                    TIMESTAMP_NTZ(0)
        )
        COMMENT = 'CT table for LH_LOADING_CYCLE'
        """
        cur.execute(table_ddl)
        print("    ✓ Table created")
        
        # Create procedure
        print("\n[3] Creating LH_LOADING_CYCLE_CT_P procedure...")
        proc_ddl = '''
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS $$
/*****************************************************************************************
* PURPOSE   : Merge data from LH_LOADING_CYCLE_C into LH_LOADING_CYCLE_CT
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
        UPDATE DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT tgt
        SET DW_LOGICAL_DELETE_FLAG = 'Y',
            DW_MODIFY_TS = CURRENT_TIMESTAMP()
        WHERE tgt.CYCLE_START_TS_LOCAL >= DATEADD(day, -` + numberOfDays + `, CURRENT_TIMESTAMP())
          AND tgt.DW_LOGICAL_DELETE_FLAG = 'N'
          AND NOT EXISTS (
              SELECT 1 FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C src
              WHERE src.LOADING_CYCLE_ID = tgt.LOADING_CYCLE_ID
                AND src.CYCLE_START_TS_LOCAL >= DATEADD(day, -` + numberOfDays + `, CURRENT_TIMESTAMP())
          )
    `;
    var stmt = snowflake.createStatement({sqlText: archiveSQL});
    var rs = stmt.execute();
    rowsArchived = stmt.getNumRowsAffected();

    // MERGE statement
    var mergeSQL = `
        MERGE INTO DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT tgt
        USING (
            SELECT 
                LOADING_CYCLE_ID, SITE_CODE, ORIG_SRC_ID, SHIFT_ID,
                LOADING_CYCLE_OF_SHIFT, EXCAV_CYCLE_OF_SHIFT,
                CYCLE_START_TS_UTC, CYCLE_START_TS_LOCAL,
                CYCLE_END_TS_UTC, CYCLE_END_TS_LOCAL,
                MEASURED_PAYLOAD_SHORT_TONS, MEASURED_PAYLOAD_METRIC_TONS,
                AVG_SWING_DURATION_MINS, AVG_DIG_DURATION_MINS,
                HANG_DURATION_MINS, IDLE_DURATION_MINS, BUCKET_COUNT,
                EXCAV_ID, TRUCK_ID, EXCAV, TRUCK, EXCAV_OPERATOR_ID,
                MATERIAL_ID, LOADING_LOC_ID, INTERRUPTED_LOADING_FLAG,
                ASSOCIATED_HAUL_CYCLE_FLAG, OVER_TRUCKED_FLAG, UNDER_TRUCKED_FLAG,
                HAUL_CYCLE_ID, SYSTEM_VERSION
            FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C
            WHERE CYCLE_START_TS_LOCAL >= DATEADD(day, -` + numberOfDays + `, CURRENT_TIMESTAMP())
        ) src
        ON tgt.LOADING_CYCLE_ID = src.LOADING_CYCLE_ID
        WHEN MATCHED AND (
            HASH(src.SITE_CODE, src.ORIG_SRC_ID, src.SHIFT_ID,
                 src.LOADING_CYCLE_OF_SHIFT, src.EXCAV_CYCLE_OF_SHIFT,
                 src.CYCLE_START_TS_UTC, src.CYCLE_START_TS_LOCAL,
                 src.CYCLE_END_TS_UTC, src.CYCLE_END_TS_LOCAL,
                 src.MEASURED_PAYLOAD_SHORT_TONS, src.MEASURED_PAYLOAD_METRIC_TONS,
                 src.AVG_SWING_DURATION_MINS, src.AVG_DIG_DURATION_MINS,
                 src.HANG_DURATION_MINS, src.IDLE_DURATION_MINS, src.BUCKET_COUNT,
                 src.EXCAV_ID, src.TRUCK_ID, src.EXCAV, src.TRUCK, src.EXCAV_OPERATOR_ID,
                 src.MATERIAL_ID, src.LOADING_LOC_ID, src.INTERRUPTED_LOADING_FLAG,
                 src.ASSOCIATED_HAUL_CYCLE_FLAG, src.OVER_TRUCKED_FLAG, src.UNDER_TRUCKED_FLAG,
                 src.HAUL_CYCLE_ID, src.SYSTEM_VERSION)
            <>
            HASH(tgt.SITE_CODE, tgt.ORIG_SRC_ID, tgt.SHIFT_ID,
                 tgt.LOADING_CYCLE_OF_SHIFT, tgt.EXCAV_CYCLE_OF_SHIFT,
                 tgt.CYCLE_START_TS_UTC, tgt.CYCLE_START_TS_LOCAL,
                 tgt.CYCLE_END_TS_UTC, tgt.CYCLE_END_TS_LOCAL,
                 tgt.MEASURED_PAYLOAD_SHORT_TONS, tgt.MEASURED_PAYLOAD_METRIC_TONS,
                 tgt.AVG_SWING_DURATION_MINS, tgt.AVG_DIG_DURATION_MINS,
                 tgt.HANG_DURATION_MINS, tgt.IDLE_DURATION_MINS, tgt.BUCKET_COUNT,
                 tgt.EXCAV_ID, tgt.TRUCK_ID, tgt.EXCAV, tgt.TRUCK, tgt.EXCAV_OPERATOR_ID,
                 tgt.MATERIAL_ID, tgt.LOADING_LOC_ID, tgt.INTERRUPTED_LOADING_FLAG,
                 tgt.ASSOCIATED_HAUL_CYCLE_FLAG, tgt.OVER_TRUCKED_FLAG, tgt.UNDER_TRUCKED_FLAG,
                 tgt.HAUL_CYCLE_ID, tgt.SYSTEM_VERSION)
            OR tgt.DW_LOGICAL_DELETE_FLAG = 'Y'
        )
        THEN UPDATE SET
            tgt.SITE_CODE = src.SITE_CODE,
            tgt.ORIG_SRC_ID = src.ORIG_SRC_ID,
            tgt.SHIFT_ID = src.SHIFT_ID,
            tgt.LOADING_CYCLE_OF_SHIFT = src.LOADING_CYCLE_OF_SHIFT,
            tgt.EXCAV_CYCLE_OF_SHIFT = src.EXCAV_CYCLE_OF_SHIFT,
            tgt.CYCLE_START_TS_UTC = src.CYCLE_START_TS_UTC,
            tgt.CYCLE_START_TS_LOCAL = src.CYCLE_START_TS_LOCAL,
            tgt.CYCLE_END_TS_UTC = src.CYCLE_END_TS_UTC,
            tgt.CYCLE_END_TS_LOCAL = src.CYCLE_END_TS_LOCAL,
            tgt.MEASURED_PAYLOAD_SHORT_TONS = src.MEASURED_PAYLOAD_SHORT_TONS,
            tgt.MEASURED_PAYLOAD_METRIC_TONS = src.MEASURED_PAYLOAD_METRIC_TONS,
            tgt.AVG_SWING_DURATION_MINS = src.AVG_SWING_DURATION_MINS,
            tgt.AVG_DIG_DURATION_MINS = src.AVG_DIG_DURATION_MINS,
            tgt.HANG_DURATION_MINS = src.HANG_DURATION_MINS,
            tgt.IDLE_DURATION_MINS = src.IDLE_DURATION_MINS,
            tgt.BUCKET_COUNT = src.BUCKET_COUNT,
            tgt.EXCAV_ID = src.EXCAV_ID,
            tgt.TRUCK_ID = src.TRUCK_ID,
            tgt.EXCAV = src.EXCAV,
            tgt.TRUCK = src.TRUCK,
            tgt.EXCAV_OPERATOR_ID = src.EXCAV_OPERATOR_ID,
            tgt.MATERIAL_ID = src.MATERIAL_ID,
            tgt.LOADING_LOC_ID = src.LOADING_LOC_ID,
            tgt.INTERRUPTED_LOADING_FLAG = src.INTERRUPTED_LOADING_FLAG,
            tgt.ASSOCIATED_HAUL_CYCLE_FLAG = src.ASSOCIATED_HAUL_CYCLE_FLAG,
            tgt.OVER_TRUCKED_FLAG = src.OVER_TRUCKED_FLAG,
            tgt.UNDER_TRUCKED_FLAG = src.UNDER_TRUCKED_FLAG,
            tgt.HAUL_CYCLE_ID = src.HAUL_CYCLE_ID,
            tgt.SYSTEM_VERSION = src.SYSTEM_VERSION,
            tgt.DW_LOGICAL_DELETE_FLAG = 'N',
            tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP()
        WHEN NOT MATCHED THEN INSERT (
            LOADING_CYCLE_ID, SITE_CODE, ORIG_SRC_ID, SHIFT_ID,
            LOADING_CYCLE_OF_SHIFT, EXCAV_CYCLE_OF_SHIFT,
            CYCLE_START_TS_UTC, CYCLE_START_TS_LOCAL,
            CYCLE_END_TS_UTC, CYCLE_END_TS_LOCAL,
            MEASURED_PAYLOAD_SHORT_TONS, MEASURED_PAYLOAD_METRIC_TONS,
            AVG_SWING_DURATION_MINS, AVG_DIG_DURATION_MINS,
            HANG_DURATION_MINS, IDLE_DURATION_MINS, BUCKET_COUNT,
            EXCAV_ID, TRUCK_ID, EXCAV, TRUCK, EXCAV_OPERATOR_ID,
            MATERIAL_ID, LOADING_LOC_ID, INTERRUPTED_LOADING_FLAG,
            ASSOCIATED_HAUL_CYCLE_FLAG, OVER_TRUCKED_FLAG, UNDER_TRUCKED_FLAG,
            HAUL_CYCLE_ID, SYSTEM_VERSION,
            DW_LOGICAL_DELETE_FLAG, DW_LOAD_TS, DW_MODIFY_TS
        ) VALUES (
            src.LOADING_CYCLE_ID, src.SITE_CODE, src.ORIG_SRC_ID, src.SHIFT_ID,
            src.LOADING_CYCLE_OF_SHIFT, src.EXCAV_CYCLE_OF_SHIFT,
            src.CYCLE_START_TS_UTC, src.CYCLE_START_TS_LOCAL,
            src.CYCLE_END_TS_UTC, src.CYCLE_END_TS_LOCAL,
            src.MEASURED_PAYLOAD_SHORT_TONS, src.MEASURED_PAYLOAD_METRIC_TONS,
            src.AVG_SWING_DURATION_MINS, src.AVG_DIG_DURATION_MINS,
            src.HANG_DURATION_MINS, src.IDLE_DURATION_MINS, src.BUCKET_COUNT,
            src.EXCAV_ID, src.TRUCK_ID, src.EXCAV, src.TRUCK, src.EXCAV_OPERATOR_ID,
            src.MATERIAL_ID, src.LOADING_LOC_ID, src.INTERRUPTED_LOADING_FLAG,
            src.ASSOCIATED_HAUL_CYCLE_FLAG, src.OVER_TRUCKED_FLAG, src.UNDER_TRUCKED_FLAG,
            src.HAUL_CYCLE_ID, src.SYSTEM_VERSION,
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
        cur.execute("CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_P('3')")
        result = cur.fetchone()[0]
        duration = time.time() - start
        print(f"    ✓ Result: {result}")
        print(f"    ✓ Duration: {duration:.2f}s")
        
        # Get row count
        cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT")
        row_count = cur.fetchone()[0]
        print(f"    ✓ Rows: {row_count:,}")
        
    print("\n" + "="*60)
    print("DONE!")
    print("="*60)

if __name__ == "__main__":
    main()
