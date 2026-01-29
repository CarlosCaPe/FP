"""
Test script for new INCR tables in DEV environment
Tables: LH_EQUIPMENT_STATUS_EVENT_INCR, LH_LOADING_CYCLE_INCR, LH_BUCKET_INCR
Author: Carlos Carrillo
Date: 2026-01-27
"""

import snowflake.connector
import os
import json
from datetime import datetime

# Connection parameters
def get_connection():
    """Get Snowflake connection to DEV environment"""
    conn_params = {
        "account": "fcx.west-us-2.azure",
        "user": "CCARRILL2@fmi.com",
        "authenticator": "externalbrowser",
        "warehouse": "WH_BATCH_DE_NONPROD",
        "database": "DEV_API_REF",
        "schema": "FUSE",
        "role": "SG-AZW-SFLK-ENG-GENERAL"
    }
    return snowflake.connector.connect(**conn_params)


def print_header(title):
    print(f"\n{'='*80}")
    print(f" {title}")
    print(f"{'='*80}")


def print_result(label, value, status=""):
    status_icon = "✅" if status == "pass" else "❌" if status == "fail" else "📊"
    print(f"  {status_icon} {label}: {value}")


def test_source_tables(cursor):
    """Verify source tables exist and have DW_MODIFY_TS column"""
    print_header("STEP 1: Verify Source Tables in PROD_WG.LOAD_HAUL")
    
    source_tables = [
        ("PROD_WG.LOAD_HAUL.LH_EQUIPMENT_STATUS_EVENT", "EQUIP_STATUS_EVENT_SK"),
        ("PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE", "LOADING_CYCLE_ID"),
        ("PROD_WG.LOAD_HAUL.LH_BUCKET", "BUCKET_ID")
    ]
    
    all_pass = True
    for table, pk in source_tables:
        try:
            # Check if table exists and has DW_MODIFY_TS
            cursor.execute(f"""
                SELECT COUNT(*) as cnt, 
                       MAX(DW_MODIFY_TS) as max_ts,
                       MIN(DW_MODIFY_TS) as min_ts
                FROM {table}
                WHERE DW_MODIFY_TS >= DATEADD(day, -3, CURRENT_TIMESTAMP())
            """)
            row = cursor.fetchone()
            print_result(f"{table.split('.')[-1]}", 
                        f"{row[0]:,} records in 3-day window | Latest: {row[1]}", "pass")
        except Exception as e:
            print_result(f"{table.split('.')[-1]}", f"ERROR: {str(e)[:50]}", "fail")
            all_pass = False
    
    return all_pass


def deploy_tables(cursor):
    """Deploy the INCR tables to DEV"""
    print_header("STEP 2: Deploy INCR Tables to DEV_API_REF.FUSE")
    
    tables_ddl = {
        "LH_EQUIPMENT_STATUS_EVENT_INCR": """
            CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_EQUIPMENT_STATUS_EVENT_INCR (
                SITE_CODE VARCHAR(4) COLLATE 'en-ci' NOT NULL,
                EQUIP_ID NUMBER(19,0) NOT NULL,
                EQUIP_CATEGORY VARCHAR(64) COLLATE 'en-ci',
                ORIG_SRC_ID NUMBER(38,0),
                EQUIP_STATUS_EVENT_SK VARCHAR(8000) COLLATE 'en-ci',
                SHIFT_ID VARCHAR(8000) COLLATE 'en-ci',
                CYCLE_ID NUMBER(19,0),
                STATUS_EVENT_REASON_ID NUMBER(19,0),
                START_TS_UTC TIMESTAMP_NTZ(3),
                END_TS_UTC TIMESTAMP_NTZ(3),
                START_TS_LOCAL TIMESTAMP_NTZ(3) NOT NULL,
                END_TS_LOCAL TIMESTAMP_NTZ(3),
                DURATION_MINS NUMBER(38,12),
                EVENT_COMMENTS VARCHAR(8000) COLLATE 'en-ci',
                DISTINCT_STATUS_EVENT_FLAG NUMBER(1,0),
                PREV_STATUS_EVENT_ID VARCHAR(8000) COLLATE 'en-ci',
                NEXT_STATUS_EVENT_ID VARCHAR(8000) COLLATE 'en-ci',
                SYSTEM_VERSION VARCHAR(50) COLLATE 'en-ci',
                DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
                DW_LOAD_TS TIMESTAMP_NTZ(0),
                DW_MODIFY_TS TIMESTAMP_NTZ(0)
            ) COMMENT='Incremental table for LH_EQUIPMENT_STATUS_EVENT'
        """,
        "LH_LOADING_CYCLE_INCR": """
            CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR (
                LOADING_CYCLE_ID NUMBER(19,0) NOT NULL,
                SITE_CODE VARCHAR(4) COLLATE 'en-ci',
                ORIG_SRC_ID NUMBER(38,0),
                SHIFT_ID VARCHAR(12) COLLATE 'en-ci',
                LOADING_CYCLE_OF_SHIFT NUMBER(38,0),
                EXCAV_CYCLE_OF_SHIFT NUMBER(38,0),
                CYCLE_START_TS_UTC TIMESTAMP_NTZ(3),
                CYCLE_START_TS_LOCAL TIMESTAMP_NTZ(3),
                CYCLE_END_TS_UTC TIMESTAMP_NTZ(3),
                CYCLE_END_TS_LOCAL TIMESTAMP_NTZ(3),
                MEASURED_PAYLOAD_SHORT_TONS NUMBER(38,6),
                MEASURED_PAYLOAD_METRIC_TONS NUMBER(38,6),
                AVG_SWING_DURATION_MINS NUMBER(38,6),
                AVG_DIG_DURATION_MINS NUMBER(38,6),
                HANG_DURATION_MINS NUMBER(38,6),
                IDLE_DURATION_MINS NUMBER(38,6),
                BUCKET_COUNT NUMBER(38,0),
                EXCAV_ID NUMBER(19,0),
                TRUCK_ID NUMBER(19,0),
                EXCAV_OPERATOR_ID NUMBER(19,0),
                MATERIAL_ID NUMBER(19,0),
                LOADING_LOC_ID NUMBER(19,0),
                LOADING_CYCLE_DIG_ELEV_AVG_FEET FLOAT,
                LOADING_CYCLE_DIG_ELEV_AVG_METERS FLOAT,
                INTERRUPTED_LOADING_FLAG NUMBER(1,0),
                ASSOCIATED_HAUL_CYCLE_FLAG NUMBER(1,0),
                OVER_TRUCKED_FLAG NUMBER(1,0),
                UNDER_TRUCKED_FLAG NUMBER(1,0),
                HAUL_CYCLE_ID NUMBER(19,0),
                SYSTEM_VERSION VARCHAR(50) COLLATE 'en-ci',
                DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
                DW_LOAD_TS TIMESTAMP_NTZ(0),
                DW_MODIFY_TS TIMESTAMP_NTZ(0)
            ) COMMENT='Incremental table for LH_LOADING_CYCLE'
        """,
        "LH_BUCKET_INCR": """
            CREATE OR REPLACE TABLE DEV_API_REF.FUSE.LH_BUCKET_INCR (
                BUCKET_ID NUMBER(19,0) NOT NULL,
                SITE_CODE VARCHAR(4) COLLATE 'en-ci',
                LOADING_CYCLE_ID NUMBER(19,0),
                LH_EQUIP_ID NUMBER(38,5),
                ORIG_SRC_ID NUMBER(38,0),
                BUCKET_OF_CYCLE NUMBER(38,0),
                SWING_EMPTY_START_TS_UTC TIMESTAMP_NTZ(3),
                SWING_EMPTY_START_TS_LOCAL TIMESTAMP_NTZ(3),
                SWING_EMPTY_END_TS_UTC TIMESTAMP_NTZ(3),
                SWING_EMPTY_END_TS_LOCAL TIMESTAMP_NTZ(3),
                DIG_START_TS_UTC TIMESTAMP_NTZ(3),
                DIG_START_TS_LOCAL TIMESTAMP_NTZ(3),
                DIG_END_TS_UTC TIMESTAMP_NTZ(3),
                DIG_END_TS_LOCAL TIMESTAMP_NTZ(3),
                SWING_FULL_START_TS_UTC TIMESTAMP_NTZ(3),
                SWING_FULL_START_TS_LOCAL TIMESTAMP_NTZ(3),
                SWING_FULL_END_TS_UTC TIMESTAMP_NTZ(3),
                SWING_FULL_END_TS_LOCAL TIMESTAMP_NTZ(3),
                TRIP_TS_UTC TIMESTAMP_NTZ(3),
                TRIP_TS_LOCAL TIMESTAMP_NTZ(3),
                DIG_X FLOAT,
                DIG_Y FLOAT,
                DIG_Z FLOAT,
                TRIP_X FLOAT,
                TRIP_Y FLOAT,
                TRIP_Z FLOAT,
                SWING_ANGLE_DEGREES FLOAT,
                BLOCK_CENTROID_X FLOAT,
                BLOCK_CENTROID_Y FLOAT,
                BLOCK_CENTROID_Z FLOAT,
                MEASURED_SHORT_TONS NUMBER(38,6),
                MEASURED_METRIC_TONS NUMBER(38,6),
                SWING_EMPTY_DURATION_MINS NUMBER(38,6),
                DIG_DURATION_MINS NUMBER(38,6),
                SWING_FULL_DURATION_MINS NUMBER(38,6),
                SYSTEM_VERSION VARCHAR(50) COLLATE 'en-ci',
                DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
                DW_LOAD_TS TIMESTAMP_NTZ(0),
                DW_MODIFY_TS TIMESTAMP_NTZ(0)
            ) COMMENT='Incremental table for LH_BUCKET'
        """
    }
    
    all_pass = True
    for table_name, ddl in tables_ddl.items():
        try:
            cursor.execute(ddl)
            print_result(table_name, "Created successfully", "pass")
        except Exception as e:
            print_result(table_name, f"ERROR: {str(e)[:60]}", "fail")
            all_pass = False
    
    return all_pass


def deploy_procedures(cursor):
    """Deploy the INCR procedures to DEV"""
    print_header("STEP 3: Deploy INCR Procedures to DEV_API_REF.FUSE")
    
    # Read and deploy each procedure
    proc_files = [
        ("R__LH_EQUIPMENT_STATUS_EVENT_INCR_P.sql", "LH_EQUIPMENT_STATUS_EVENT_INCR_P"),
        ("R__LH_LOADING_CYCLE_INCR_P.sql", "LH_LOADING_CYCLE_INCR_P"),
        ("R__LH_BUCKET_INCR_P.sql", "LH_BUCKET_INCR_P")
    ]
    
    base_path = os.path.dirname(os.path.abspath(__file__))
    proc_path = os.path.join(base_path, "DDL-Scripts", "API_REF", "FUSE", "PROCEDURES")
    
    all_pass = True
    for filename, proc_name in proc_files:
        try:
            filepath = os.path.join(proc_path, filename)
            with open(filepath, 'r') as f:
                sql = f.read()
            
            # Replace template variables for DEV
            sql = sql.replace("{{ envi }}", "DEV")
            sql = sql.replace("{{ RO_PROD }}", "PROD")
            
            cursor.execute(sql)
            print_result(proc_name, "Created successfully", "pass")
        except Exception as e:
            print_result(proc_name, f"ERROR: {str(e)[:60]}", "fail")
            all_pass = False
    
    return all_pass


def execute_procedures(cursor):
    """Execute procedures and verify they work"""
    print_header("STEP 4: Execute Procedures (3-day lookback)")
    
    procedures = [
        ("LH_EQUIPMENT_STATUS_EVENT_INCR_P", "LH_EQUIPMENT_STATUS_EVENT_INCR"),
        ("LH_LOADING_CYCLE_INCR_P", "LH_LOADING_CYCLE_INCR"),
        ("LH_BUCKET_INCR_P", "LH_BUCKET_INCR")
    ]
    
    all_pass = True
    for proc_name, table_name in procedures:
        try:
            print(f"\n  🔄 Executing {proc_name}...")
            cursor.execute(f"CALL DEV_API_REF.FUSE.{proc_name}('3')")
            result = cursor.fetchone()[0]
            print_result(proc_name, result, "pass")
            
            # Verify row count
            cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table_name}")
            count = cursor.fetchone()[0]
            print_result(f"  → {table_name} rows", f"{count:,}", "pass" if count > 0 else "fail")
            
        except Exception as e:
            print_result(proc_name, f"ERROR: {str(e)[:80]}", "fail")
            all_pass = False
    
    return all_pass


def verify_objects(cursor):
    """Verify all objects exist in DEV"""
    print_header("STEP 5: Verify Objects Exist in DEV_API_REF.FUSE")
    
    # Check tables
    cursor.execute("""
        SELECT TABLE_NAME, ROW_COUNT, CREATED
        FROM DEV_API_REF.INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = 'FUSE'
        AND TABLE_NAME IN ('LH_EQUIPMENT_STATUS_EVENT_INCR', 'LH_LOADING_CYCLE_INCR', 'LH_BUCKET_INCR')
        ORDER BY TABLE_NAME
    """)
    
    print("\n  📋 Tables:")
    tables_found = 0
    for row in cursor.fetchall():
        print_result(f"    {row[0]}", f"{row[1]:,} rows | Created: {row[2]}", "pass")
        tables_found += 1
    
    if tables_found != 3:
        print_result("  MISSING TABLES", f"Found {tables_found}/3", "fail")
    
    # Check procedures
    cursor.execute("""
        SELECT PROCEDURE_NAME, CREATED
        FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES
        WHERE PROCEDURE_SCHEMA = 'FUSE'
        AND PROCEDURE_NAME IN ('LH_EQUIPMENT_STATUS_EVENT_INCR_P', 'LH_LOADING_CYCLE_INCR_P', 'LH_BUCKET_INCR_P')
        ORDER BY PROCEDURE_NAME
    """)
    
    print("\n  📋 Procedures:")
    procs_found = 0
    for row in cursor.fetchall():
        print_result(f"    {row[0]}", f"Created: {row[1]}", "pass")
        procs_found += 1
    
    if procs_found != 3:
        print_result("  MISSING PROCEDURES", f"Found {procs_found}/3", "fail")
    
    return tables_found == 3 and procs_found == 3


def run_regression_test(cursor):
    """Run regression test - execute procedures multiple times"""
    print_header("STEP 6: Regression Test (Re-execute procedures)")
    
    procedures = [
        ("LH_EQUIPMENT_STATUS_EVENT_INCR_P", "LH_EQUIPMENT_STATUS_EVENT_INCR"),
        ("LH_LOADING_CYCLE_INCR_P", "LH_LOADING_CYCLE_INCR"),
        ("LH_BUCKET_INCR_P", "LH_BUCKET_INCR")
    ]
    
    all_pass = True
    for proc_name, table_name in procedures:
        try:
            # Get count before
            cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table_name}")
            before = cursor.fetchone()[0]
            
            # Execute again
            cursor.execute(f"CALL DEV_API_REF.FUSE.{proc_name}('3')")
            result = cursor.fetchone()[0]
            
            # Get count after
            cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table_name}")
            after = cursor.fetchone()[0]
            
            # Verify idempotency (count should be similar)
            diff = abs(after - before)
            status = "pass" if diff < before * 0.1 else "fail"  # Less than 10% change
            print_result(proc_name, f"Before: {before:,} | After: {after:,} | Δ: {diff:,}", status)
            
        except Exception as e:
            print_result(proc_name, f"ERROR: {str(e)[:60]}", "fail")
            all_pass = False
    
    return all_pass


def main():
    print("\n" + "="*80)
    print(" 🧪 DEV ENVIRONMENT TEST FOR NEW INCR TABLES")
    print(" Date:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("="*80)
    
    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        results = {}
        
        # Run all tests
        results['source_tables'] = test_source_tables(cursor)
        results['deploy_tables'] = deploy_tables(cursor)
        results['deploy_procedures'] = deploy_procedures(cursor)
        results['execute_procedures'] = execute_procedures(cursor)
        results['verify_objects'] = verify_objects(cursor)
        results['regression_test'] = run_regression_test(cursor)
        
        # Summary
        print_header("FINAL SUMMARY")
        all_pass = True
        for test_name, passed in results.items():
            status = "pass" if passed else "fail"
            print_result(test_name.replace('_', ' ').title(), "PASSED" if passed else "FAILED", status)
            all_pass = all_pass and passed
        
        print("\n" + "="*80)
        if all_pass:
            print(" ✅ ALL TESTS PASSED - Ready for TEST environment deployment")
        else:
            print(" ❌ SOME TESTS FAILED - Review errors above")
        print("="*80 + "\n")
        
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    main()
