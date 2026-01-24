"""
DRILLBLAST_INCR Deployment Script
=================================
Deploys ALL 11 INCR tables and stored procedures to DEV_API_REF.FUSE

This script:
1. Reads all .sql files in this folder
2. Splits them into individual statements (CREATE TABLE, CREATE PROCEDURE)
3. Executes each statement in Snowflake
4. Validates deployment by checking object existence

Author: Carlos Carrillo
Date: 2026-01-23
"""

import os
import re
import json
import time
import subprocess
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

# Use SnowSQL CLI instead of Python connector (Python 3.14 compatibility issue)
SNOWSQL_CMD = "snowsql"
SNOWFLAKE_ACCOUNT = "fcx.west-us-2.azure"
SNOWFLAKE_USER = "CCARRILL2@fmi.com"
SNOWFLAKE_WAREHOUSE = "WH_BATCH_DE_NONPROD"
SNOWFLAKE_DATABASE = "DEV_API_REF"
SNOWFLAKE_SCHEMA = "FUSE"
SNOWFLAKE_ROLE = "SG-AZW-SFLK-ENG-GENERAL"

# All SQL files to deploy
SQL_FILES = [
    "BL_DW_BLAST_INCR.sql",
    "BL_DW_BLASTPROPERTYVALUE_INCR.sql",
    "BL_DW_HOLE_INCR.sql",
    "BLAST_PLAN_INCR.sql",
    "BLAST_PLAN_EXECUTION_INCR.sql",
    "DRILL_CYCLE_INCR.sql",
    "DRILL_PLAN_INCR.sql",
    "DRILLBLAST_EQUIPMENT_INCR.sql",
    "DRILLBLAST_OPERATOR_INCR.sql",
    "DRILLBLAST_SHIFT_INCR.sql",
    "LH_HAUL_CYCLE_INCR.sql",
]

# Expected objects after deployment
EXPECTED_TABLES = [
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
    "LH_HAUL_CYCLE_INCR",
]

EXPECTED_PROCEDURES = [
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
    "LH_HAUL_CYCLE_INCR_P",
]


def split_sql_statements(sql_content: str) -> list:
    """
    Split SQL file into individual statements.
    Handles CREATE OR REPLACE TABLE and CREATE OR REPLACE PROCEDURE.
    """
    statements = []
    
    # Pattern to find CREATE TABLE statements
    table_pattern = r"(CREATE\s+OR\s+REPLACE\s+TABLE\s+[\s\S]*?;)(?=\s*(?:CREATE|--|\Z))"
    
    # Find CREATE TABLE statements
    for match in re.finditer(table_pattern, sql_content, re.IGNORECASE):
        stmt = match.group(1).strip()
        if stmt:
            statements.append(("TABLE", stmt))
    
    # Pattern to find CREATE PROCEDURE statements (ends with '; or just ')
    proc_pattern = r"(CREATE\s+OR\s+REPLACE\s+PROCEDURE[\s\S]*?(?:'\s*;|;(?=\s*(?:--|CALL|\Z))))"
    
    for match in re.finditer(proc_pattern, sql_content, re.IGNORECASE):
        stmt = match.group(1).strip()
        if stmt:
            statements.append(("PROCEDURE", stmt))
    
    return statements


def execute_statement(cursor, stmt_type: str, statement: str) -> dict:
    """Execute a single SQL statement and return result."""
    result = {
        "type": stmt_type,
        "status": "PENDING",
        "error": None,
        "duration_seconds": 0,
    }
    
    # Extract object name for logging
    if stmt_type == "TABLE":
        match = re.search(r"CREATE\s+OR\s+REPLACE\s+TABLE\s+([\w.]+)", statement, re.IGNORECASE)
    else:
        match = re.search(r"CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+([\w.]+)", statement, re.IGNORECASE)
    
    result["object_name"] = match.group(1) if match else "UNKNOWN"
    
    start = time.time()
    try:
        cursor.execute(statement)
        result["status"] = "SUCCESS"
        print(f"  ✅ {stmt_type}: {result['object_name']}")
    except Exception as e:
        result["status"] = "ERROR"
        result["error"] = str(e)[:500]
        print(f"  ❌ {stmt_type}: {result['object_name']} - {str(e)[:100]}")
    
    result["duration_seconds"] = round(time.time() - start, 2)
    return result


def verify_objects(cursor) -> dict:
    """Verify all expected objects exist."""
    results = {"tables": {}, "procedures": {}}
    
    # Check tables
    cursor.execute("""
        SELECT TABLE_NAME 
        FROM DEV_API_REF.INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'FUSE' 
        AND TABLE_NAME LIKE '%_INCR'
    """)
    existing_tables = {row[0] for row in cursor.fetchall()}
    
    for table in EXPECTED_TABLES:
        results["tables"][table] = table in existing_tables
    
    # Check procedures
    cursor.execute("""
        SELECT PROCEDURE_NAME 
        FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
        WHERE PROCEDURE_SCHEMA = 'FUSE' 
        AND (PROCEDURE_NAME LIKE '%_INCR_P' OR PROCEDURE_NAME LIKE 'SP_%_INCR')
    """)
    existing_procs = {row[0] for row in cursor.fetchall()}
    
    for proc in EXPECTED_PROCEDURES:
        results["procedures"][proc] = proc in existing_procs
    
    return results


def run_deployment():
    """Main deployment function."""
    print("=" * 70)
    print("DRILLBLAST_INCR DEPLOYMENT")
    print("=" * 70)
    print(f"Started: {datetime.now().isoformat()}")
    print(f"Target: DEV_API_REF.FUSE")
    print(f"SQL Files: {len(SQL_FILES)}")
    print("=" * 70)
    
    # Get script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Connect to Snowflake
    print("\n📋 Connecting to Snowflake...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    print("✅ Connected!\n")
    
    # Set context
    cursor.execute("USE DATABASE DEV_API_REF;")
    cursor.execute("USE SCHEMA FUSE;")
    cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD;")
    
    all_results = []
    total_tables = 0
    total_procedures = 0
    total_errors = 0
    
    # Process each SQL file
    for sql_file in SQL_FILES:
        file_path = os.path.join(script_dir, sql_file)
        
        if not os.path.exists(file_path):
            print(f"\n⚠️ File not found: {sql_file}")
            continue
        
        print(f"\n📄 Processing: {sql_file}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        statements = split_sql_statements(sql_content)
        
        for stmt_type, statement in statements:
            result = execute_statement(cursor, stmt_type, statement)
            all_results.append(result)
            
            if result["status"] == "SUCCESS":
                if stmt_type == "TABLE":
                    total_tables += 1
                else:
                    total_procedures += 1
            else:
                total_errors += 1
    
    # Verify deployment
    print("\n" + "=" * 70)
    print("VERIFICATION")
    print("=" * 70)
    
    verification = verify_objects(cursor)
    
    print("\n📊 Tables:")
    for table, exists in verification["tables"].items():
        status = "✅" if exists else "❌"
        print(f"  {status} {table}")
    
    print("\n📊 Procedures:")
    for proc, exists in verification["procedures"].items():
        status = "✅" if exists else "❌"
        print(f"  {status} {proc}")
    
    # Summary
    tables_ok = sum(1 for v in verification["tables"].values() if v)
    procs_ok = sum(1 for v in verification["procedures"].values() if v)
    
    print("\n" + "=" * 70)
    print("DEPLOYMENT SUMMARY")
    print("=" * 70)
    print(f"Tables created: {total_tables}")
    print(f"Procedures created: {total_procedures}")
    print(f"Errors: {total_errors}")
    print(f"Tables verified: {tables_ok}/{len(EXPECTED_TABLES)}")
    print(f"Procedures verified: {procs_ok}/{len(EXPECTED_PROCEDURES)}")
    print(f"Completed: {datetime.now().isoformat()}")
    
    # Save results
    output = {
        "deployment_time": datetime.now().isoformat(),
        "target": "DEV_API_REF.FUSE",
        "total_tables": total_tables,
        "total_procedures": total_procedures,
        "total_errors": total_errors,
        "verification": verification,
        "details": all_results
    }
    
    output_file = os.path.join(script_dir, f"deployment_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
    with open(output_file, 'w') as f:
        json.dump(output, f, indent=2)
    
    print(f"\n📁 Results saved to: {output_file}")
    
    cursor.close()
    conn.close()
    
    if total_errors == 0 and tables_ok == len(EXPECTED_TABLES) and procs_ok == len(EXPECTED_PROCEDURES):
        print("\n🎉 DEPLOYMENT SUCCESSFUL!")
        return True
    else:
        print("\n⚠️ DEPLOYMENT COMPLETED WITH ISSUES")
        return False


if __name__ == "__main__":
    run_deployment()
