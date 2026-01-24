"""
DRILLBLAST_INCR Quick Deployment Script
Uses Python 3.12 for Snowflake connector compatibility
"""

import os
import json
import time
import re
from datetime import datetime

# Install snowflake-connector if needed
try:
    import snowflake.connector
except ImportError:
    import subprocess
    subprocess.check_call(["py", "-3.12", "-m", "pip", "install", "snowflake-connector-python", "python-dotenv", "-q"])
    import snowflake.connector

from dotenv import load_dotenv
load_dotenv()

SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "DEV_API_REF",
    "schema": "FUSE",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
    "client_session_keep_alive": True,
}

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

def extract_statements(sql_content):
    """Extract CREATE TABLE and CREATE PROCEDURE statements."""
    statements = []
    
    # Find CREATE TABLE - ends with );
    table_matches = re.findall(
        r'(CREATE\s+OR\s+REPLACE\s+TABLE\s+[\s\S]*?\)\s*;)',
        sql_content,
        re.IGNORECASE
    )
    for match in table_matches:
        # Skip if it's inside a procedure
        if "MERGE INTO" not in match and "BEGIN WORK" not in match:
            statements.append(("TABLE", match.strip()))
    
    # Find CREATE PROCEDURE - ends with '; or just ;
    proc_matches = re.findall(
        r"(CREATE\s+OR\s+REPLACE\s+PROCEDURE[\s\S]*?'\s*;)",
        sql_content,
        re.IGNORECASE
    )
    for match in proc_matches:
        statements.append(("PROCEDURE", match.strip()))
    
    return statements


def run_deployment():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("=" * 70)
    print("DRILLBLAST_INCR DEPLOYMENT TO SNOWFLAKE")
    print("=" * 70)
    print(f"Started: {datetime.now().isoformat()}")
    print(f"Target: DEV_API_REF.FUSE")
    print("=" * 70)
    
    # Connect
    print("\n📋 Connecting to Snowflake (browser auth)...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    print("✅ Connected!\n")
    
    # Set context
    cursor.execute("USE DATABASE DEV_API_REF;")
    cursor.execute("USE SCHEMA FUSE;")
    cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD;")
    
    results = {"tables": [], "procedures": [], "errors": []}
    
    for sql_file in SQL_FILES:
        file_path = os.path.join(script_dir, sql_file)
        if not os.path.exists(file_path):
            print(f"⚠️ File not found: {sql_file}")
            continue
        
        print(f"\n📄 Processing: {sql_file}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        statements = extract_statements(sql_content)
        
        for stmt_type, statement in statements:
            # Extract object name
            if stmt_type == "TABLE":
                match = re.search(r'CREATE\s+OR\s+REPLACE\s+TABLE\s+([\w.]+)', statement, re.IGNORECASE)
            else:
                match = re.search(r'CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+([\w.]+)', statement, re.IGNORECASE)
            
            obj_name = match.group(1) if match else "UNKNOWN"
            
            try:
                start = time.time()
                cursor.execute(statement)
                duration = round(time.time() - start, 2)
                print(f"  ✅ {stmt_type}: {obj_name} ({duration}s)")
                
                if stmt_type == "TABLE":
                    results["tables"].append(obj_name)
                else:
                    results["procedures"].append(obj_name)
                    
            except Exception as e:
                error_msg = str(e)[:200]
                print(f"  ❌ {stmt_type}: {obj_name} - {error_msg}")
                results["errors"].append({"object": obj_name, "error": error_msg})
    
    # Verify
    print("\n" + "=" * 70)
    print("VERIFICATION")
    print("=" * 70)
    
    cursor.execute("""
        SELECT TABLE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'FUSE' AND TABLE_NAME LIKE '%_INCR'
        ORDER BY TABLE_NAME
    """)
    tables = [row[0] for row in cursor.fetchall()]
    print(f"\n📊 Tables in FUSE (*_INCR): {len(tables)}")
    for t in tables:
        print(f"  ✅ {t}")
    
    cursor.execute("""
        SELECT PROCEDURE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
        WHERE PROCEDURE_SCHEMA = 'FUSE' 
        AND (PROCEDURE_NAME LIKE '%_INCR_P' OR PROCEDURE_NAME LIKE 'SP_%_INCR')
        ORDER BY PROCEDURE_NAME
    """)
    procs = [row[0] for row in cursor.fetchall()]
    print(f"\n📊 Procedures in FUSE (*_INCR_P / SP_*_INCR): {len(procs)}")
    for p in procs:
        print(f"  ✅ {p}")
    
    # Summary
    print("\n" + "=" * 70)
    print("DEPLOYMENT SUMMARY")
    print("=" * 70)
    print(f"Tables created: {len(results['tables'])}")
    print(f"Procedures created: {len(results['procedures'])}")
    print(f"Errors: {len(results['errors'])}")
    print(f"Tables verified: {len(tables)}")
    print(f"Procedures verified: {len(procs)}")
    print(f"Completed: {datetime.now().isoformat()}")
    
    # Save results
    output_file = os.path.join(script_dir, f"deployment_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
    with open(output_file, 'w') as f:
        json.dump({
            "timestamp": datetime.now().isoformat(),
            "results": results,
            "verified_tables": tables,
            "verified_procedures": procs
        }, f, indent=2)
    
    print(f"\n📁 Results saved to: {output_file}")
    
    cursor.close()
    conn.close()
    
    if len(results["errors"]) == 0:
        print("\n🎉 DEPLOYMENT SUCCESSFUL!")
    else:
        print("\n⚠️ DEPLOYMENT COMPLETED WITH ERRORS")


if __name__ == "__main__":
    run_deployment()
