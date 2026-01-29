"""
DRILLBLAST INCR v3.0 - Full Deployment and E2E Test
Deploys all 14 procedures to DEV and executes them to populate INCR tables
"""
import snowflake.connector
import os
from pathlib import Path

# Snowflake connection parameters
SNOWFLAKE_ACCOUNT = os.environ.get("CONN_LIB_SNOWFLAKE_ACCOUNT", "FCX-NA")
SNOWFLAKE_USER = os.environ.get("SNOWFLAKE_USER", "ccarrill2@fmi.com")
SNOWFLAKE_AUTHENTICATOR = "externalbrowser"
SNOWFLAKE_ROLE = "_AR_GENERAL_DBO_DEV"
SNOWFLAKE_WAREHOUSE = "WH_BATCH_DE_NONPROD"
SNOWFLAKE_DATABASE = "DEV_API_REF"
SNOWFLAKE_SCHEMA = "FUSE"

# All 14 procedures
PROCEDURES = [
    "BL_DW_BLAST_INCR_P",
    "BL_DW_BLASTPROPERTYVALUE_INCR_P",
    "BL_DW_HOLE_INCR_P",
    "BLAST_PLAN_INCR_P",
    "BLAST_PLAN_EXECUTION_INCR_P",
    "DRILL_CYCLE_INCR_P",
    "DRILL_PLAN_INCR_P",
    "DRILLBLAST_EQUIPMENT_INCR_P",
    "DRILLBLAST_OPERATOR_INCR_P",
    "DRILLBLAST_SHIFT_INCR_P",
    "LH_BUCKET_INCR_P",
    "LH_EQUIPMENT_STATUS_EVENT_INCR_P",
    "LH_HAUL_CYCLE_INCR_P",
    "LH_LOADING_CYCLE_INCR_P",
]

# Corresponding tables (exact names, not derived from procedures)
TABLES = [
    "BL_DW_BLAST_INCR",
    "BL_DW_BLASTPROPERTYVALUE_INCR",
    "BL_DW_HOLE_INCR",
    "BLAST_PLAN_INCR",
    "BLAST_PLAN_EXECUTION_INCR",
    "DRILL_CYCLE_INCR",
    "DRILL_PLAN_INCR",
    "DRILLBLAST_EQUIPMENT_INCR",
    "DRILLBLAST_OPERATOR_INCR",
    "DRILLBLAST_SHIFT_INCR",
    "LH_BUCKET_INCR",
    "LH_EQUIPMENT_STATUS_EVENT_INCR",
    "LH_HAUL_CYCLE_INCR",
    "LH_LOADING_CYCLE_INCR",
]

def get_connection():
    """Create Snowflake connection using browser auth"""
    print(f"Connecting to {SNOWFLAKE_DATABASE}.{SNOWFLAKE_SCHEMA}...")
    conn = snowflake.connector.connect(
        account=SNOWFLAKE_ACCOUNT,
        user=SNOWFLAKE_USER,
        authenticator=SNOWFLAKE_AUTHENTICATOR,
        role=SNOWFLAKE_ROLE,
        warehouse=SNOWFLAKE_WAREHOUSE,
        database=SNOWFLAKE_DATABASE,
        schema=SNOWFLAKE_SCHEMA,
    )
    print(f"Connected successfully with role: {SNOWFLAKE_ROLE}")
    return conn

def deploy_procedures(conn):
    """Deploy all 14 procedures from DDL files"""
    base_path = Path(__file__).parent / "DDL-Scripts-FINAL-2026-01-29" / "API_REF" / "FUSE" / "PROCEDURES"
    cursor = conn.cursor()
    
    print("\n" + "="*60)
    print("PHASE 1: DEPLOYING PROCEDURES")
    print("="*60)
    
    deployed = 0
    failed = 0
    
    for proc in PROCEDURES:
        sql_file = base_path / f"R__{proc}.sql"
        if sql_file.exists():
            print(f"\n  Deploying {proc}...", end=" ")
            try:
                sql_content = sql_file.read_text(encoding='utf-8')
                cursor.execute(sql_content)
                print("✓ SUCCESS")
                deployed += 1
            except Exception as e:
                print(f"✗ FAILED: {str(e)[:50]}")
                failed += 1
        else:
            print(f"\n  ✗ File not found: {sql_file}")
            failed += 1
    
    print(f"\n  Summary: {deployed} deployed, {failed} failed")
    return deployed, failed

def execute_procedures(conn):
    """Execute all 14 procedures with 3-day lookback"""
    cursor = conn.cursor()
    
    print("\n" + "="*60)
    print("PHASE 2: EXECUTING PROCEDURES (3-day lookback)")
    print("="*60)
    
    executed = 0
    failed = 0
    
    for proc in PROCEDURES:
        print(f"\n  Calling {proc}(3)...", end=" ")
        try:
            cursor.execute(f"CALL {proc}(3)")
            result = cursor.fetchone()
            rows = result[0] if result else "unknown"
            print(f"✓ SUCCESS ({rows} rows)")
            executed += 1
        except Exception as e:
            error_msg = str(e)
            if "does not exist" in error_msg:
                print(f"✗ PROCEDURE NOT FOUND")
            else:
                print(f"✗ FAILED: {error_msg[:60]}")
            failed += 1
    
    print(f"\n  Summary: {executed} executed, {failed} failed")
    return executed, failed

def verify_tables(conn):
    """Verify all 14 tables have data"""
    cursor = conn.cursor()
    
    print("\n" + "="*60)
    print("PHASE 3: VERIFYING TABLE DATA")
    print("="*60)
    
    results = []
    tables_with_data = 0
    empty_tables = 0
    
    for table in TABLES:
        print(f"\n  Checking {table}...", end=" ")
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            status = "✓ HAS DATA" if count > 0 else "✗ EMPTY"
            print(f"{status} ({count:,} rows)")
            results.append((table, count, "PASS" if count > 0 else "FAIL"))
            if count > 0:
                tables_with_data += 1
            else:
                empty_tables += 1
        except Exception as e:
            print(f"✗ ERROR: {str(e)[:50]}")
            results.append((table, 0, "ERROR"))
            empty_tables += 1
    
    print(f"\n  Summary: {tables_with_data} with data, {empty_tables} empty/error")
    return results, tables_with_data, empty_tables

def main():
    print("\n" + "="*60)
    print("DRILLBLAST INCR v3.0 - FULL E2E DEPLOYMENT & TEST")
    print("="*60)
    print(f"Target: {SNOWFLAKE_DATABASE}.{SNOWFLAKE_SCHEMA}")
    print(f"Role: {SNOWFLAKE_ROLE}")
    print(f"Procedures: {len(PROCEDURES)}")
    
    conn = get_connection()
    
    try:
        # Phase 1: Deploy procedures
        deployed, deploy_failed = deploy_procedures(conn)
        
        # Phase 2: Execute procedures
        executed, exec_failed = execute_procedures(conn)
        
        # Phase 3: Verify tables
        results, with_data, empty = verify_tables(conn)
        
        # Final Summary
        print("\n" + "="*60)
        print("FINAL SUMMARY")
        print("="*60)
        print(f"  Procedures Deployed:  {deployed}/14")
        print(f"  Procedures Executed:  {executed}/14")
        print(f"  Tables with Data:     {with_data}/14")
        print(f"  Empty Tables:         {empty}/14")
        
        if with_data == 14:
            print("\n  🎉 ALL 14 PIPELINES COMPLETE - E2E TEST PASSED!")
        elif with_data > 0:
            print(f"\n  ⚠️ PARTIAL SUCCESS - {with_data}/14 tables have data")
        else:
            print("\n  ❌ E2E TEST FAILED - No tables have data")
        
        # List results
        print("\n  Table Status:")
        for table, count, status in results:
            emoji = "✓" if status == "PASS" else "✗"
            print(f"    {emoji} {table}: {count:,} rows")
        
    finally:
        conn.close()
        print("\n  Connection closed.")

if __name__ == "__main__":
    main()
