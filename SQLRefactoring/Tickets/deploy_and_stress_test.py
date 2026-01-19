"""
LH_BUCKET_CT and LH_LOADING_CYCLE_CT Deployment and Stress Test
================================================================
1. Deploy CT tables and procedures
2. Run stress tests with varying lookback days (1-90)
3. Log execution times for analysis
"""
import time
import json
from datetime import datetime
from snowrefactor.snowflake_conn import connect

# Test ranges for stress testing
TEST_DAYS = [1, 3, 5, 7, 10, 14, 21, 30, 45, 60, 75, 90]

def log_result(results: list, table_name: str, days: int, duration: float, result: str, row_counts: dict = None):
    """Log a test result."""
    entry = {
        "timestamp": datetime.now().isoformat(),
        "table": table_name,
        "days": days,
        "duration_seconds": round(duration, 2),
        "result": result,
        "row_counts": row_counts
    }
    results.append(entry)
    print(f"  [{table_name}] Days={days:2d} | Duration={duration:6.2f}s | {result}")
    return entry

def deploy_lh_bucket_ct(cur):
    """Deploy LH_BUCKET_CT table and procedure."""
    print("\n" + "="*80)
    print("DEPLOYING LH_BUCKET_CT")
    print("="*80)
    
    # Create CT table
    print("\n[1/2] Creating table DEV_API_REF.FUSE.LH_BUCKET_CT...")
    ct_table_ddl = """
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
    COMMENT = 'CT table for LH_BUCKET - MERGE-driven upserts with 3-day incremental window'
    """
    cur.execute(ct_table_ddl)
    print("  ✓ Table created")
    
    # Create procedure - read from file
    print("\n[2/2] Creating procedure DEV_API_REF.FUSE.LH_BUCKET_CT_P...")
    with open(r"C:\Users\Lenovo\dataqbs\FP\SQLRefactoring\Tickets\LH_BUCKET\refactor_ddl.sql", "r") as f:
        content = f.read()
    
    # Extract procedure DDL (between CREATE OR REPLACE PROCEDURE and the closing ';' after the JS block)
    proc_start = content.find("CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.LH_BUCKET_CT_P")
    proc_end = content.find("-- ============================================================================\n-- STEP 3:")
    if proc_start != -1 and proc_end != -1:
        proc_ddl = content[proc_start:proc_end].strip().rstrip(';')
        # Need to handle the JavaScript string properly
        cur.execute(proc_ddl)
        print("  ✓ Procedure created")
    else:
        print("  ⚠ Could not extract procedure DDL, using inline definition...")
        # Use a simpler inline version for testing
        raise Exception("Procedure DDL extraction failed - check file format")

def deploy_lh_loading_cycle_ct(cur):
    """Deploy LH_LOADING_CYCLE_CT table and procedure."""
    print("\n" + "="*80)
    print("DEPLOYING LH_LOADING_CYCLE_CT")
    print("="*80)
    
    # Create CT table
    print("\n[1/2] Creating table DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT...")
    ct_table_ddl = """
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
    COMMENT = 'CT table for LH_LOADING_CYCLE - MERGE-driven upserts with 3-day incremental window'
    """
    cur.execute(ct_table_ddl)
    print("  ✓ Table created")
    
    print("\n[2/2] Creating procedure DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_P...")
    # Similar to above - would need to execute the procedure DDL
    print("  ⚠ Procedure will be created from file...")

def run_stress_test(cur, proc_name: str, table_name: str, test_days: list) -> list:
    """Run stress tests with varying lookback days."""
    results = []
    
    print(f"\n{'='*80}")
    print(f"STRESS TEST: {proc_name}")
    print(f"Testing with days: {test_days}")
    print(f"{'='*80}\n")
    
    for days in test_days:
        try:
            # Truncate table before each test for clean measurement
            cur.execute(f"TRUNCATE TABLE DEV_API_REF.FUSE.{table_name}")
            
            # Run the procedure and measure time
            start_time = time.time()
            cur.execute(f"CALL DEV_API_REF.FUSE.{proc_name}('{days}')")
            result = cur.fetchone()[0]
            duration = time.time() - start_time
            
            # Get row count
            cur.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table_name}")
            row_count = cur.fetchone()[0]
            
            log_result(results, table_name, days, duration, result, {"rows": row_count})
            
        except Exception as e:
            duration = time.time() - start_time
            log_result(results, table_name, days, duration, f"ERROR: {str(e)[:100]}")
    
    return results

def main():
    print("="*80)
    print("LH_BUCKET_CT & LH_LOADING_CYCLE_CT - DEPLOYMENT AND STRESS TEST")
    print(f"Started at: {datetime.now().isoformat()}")
    print("="*80)
    
    all_results = []
    
    with connect() as conn:
        cur = conn.cursor()
        
        # Set context
        cur.execute("USE ROLE FREEPORT_DE_DEV")
        cur.execute("USE WAREHOUSE WH_API_INTEGRATION")
        cur.execute("USE DATABASE DEV_API_REF")
        cur.execute("USE SCHEMA FUSE")
        
        # ==== PHASE 1: Deploy LH_BUCKET_CT ====
        try:
            deploy_lh_bucket_ct(cur)
        except Exception as e:
            print(f"  ✗ Deployment failed: {e}")
            print("  → Will try to run stress test if procedure already exists...")
        
        # ==== PHASE 2: Stress Test LH_BUCKET_CT ====
        print("\n" + "="*80)
        print("STRESS TESTING LH_BUCKET_CT")
        print("="*80)
        
        bucket_results = run_stress_test(
            cur, 
            "LH_BUCKET_CT_P", 
            "LH_BUCKET_CT", 
            TEST_DAYS
        )
        all_results.extend(bucket_results)
        
        # ==== PHASE 3: Deploy LH_LOADING_CYCLE_CT ====
        try:
            deploy_lh_loading_cycle_ct(cur)
        except Exception as e:
            print(f"  ✗ Deployment failed: {e}")
        
        # ==== PHASE 4: Stress Test LH_LOADING_CYCLE_CT ====
        print("\n" + "="*80)
        print("STRESS TESTING LH_LOADING_CYCLE_CT")
        print("="*80)
        
        cycle_results = run_stress_test(
            cur,
            "LH_LOADING_CYCLE_CT_P",
            "LH_LOADING_CYCLE_CT",
            TEST_DAYS
        )
        all_results.extend(cycle_results)
    
    # ==== SAVE RESULTS ====
    output_file = r"C:\Users\Lenovo\dataqbs\FP\SQLRefactoring\Tickets\stress_test_results.json"
    with open(output_file, "w") as f:
        json.dump(all_results, f, indent=2)
    print(f"\n✓ Results saved to: {output_file}")
    
    # ==== SUMMARY ====
    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    
    for table in ["LH_BUCKET_CT", "LH_LOADING_CYCLE_CT"]:
        table_results = [r for r in all_results if r["table"] == table]
        if table_results:
            print(f"\n{table}:")
            print(f"  {'Days':<6} {'Duration (s)':<15} {'Rows':<12} {'Status'}")
            print(f"  {'-'*50}")
            for r in table_results:
                rows = r.get("row_counts", {}).get("rows", "N/A")
                status = "✓" if "ERROR" not in r["result"] else "✗"
                print(f"  {r['days']:<6} {r['duration_seconds']:<15} {rows:<12} {status}")
    
    print(f"\n{'='*80}")
    print(f"Completed at: {datetime.now().isoformat()}")
    print("="*80)

if __name__ == "__main__":
    main()
