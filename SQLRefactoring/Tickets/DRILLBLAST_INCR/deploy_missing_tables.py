"""
DRILLBLAST_INCR - Execute individual SQL files
Runs each .sql file directly in Snowflake
"""

import os
import json
import time
from datetime import datetime

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

# Files that need tables created
FILES_NEEDING_TABLES = [
    "BL_DW_BLAST_INCR.sql",
    "BL_DW_BLASTPROPERTYVALUE_INCR.sql",
    "BL_DW_HOLE_INCR.sql",
    "DRILLBLAST_EQUIPMENT_INCR.sql",
    "DRILLBLAST_OPERATOR_INCR.sql",
    "DRILLBLAST_SHIFT_INCR.sql",
    "LH_HAUL_CYCLE_INCR.sql",
]


def run_deployment():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("=" * 70)
    print("DRILLBLAST_INCR - CREATE MISSING TABLES")
    print("=" * 70)
    
    # Connect
    print("\n📋 Connecting to Snowflake...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    print("✅ Connected!\n")
    
    # Set context
    cursor.execute("USE DATABASE DEV_API_REF;")
    cursor.execute("USE SCHEMA FUSE;")
    cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD;")
    
    results = []
    
    for sql_file in FILES_NEEDING_TABLES:
        file_path = os.path.join(script_dir, sql_file)
        table_name = sql_file.replace(".sql", "")
        
        print(f"\n📄 Creating: {table_name}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract just the CREATE TABLE statement
        # Find from "CREATE OR REPLACE TABLE" to the closing ");" before CREATE PROCEDURE
        import re
        
        # Pattern: CREATE TABLE ... until COMMENT = '...' followed by ;
        match = re.search(
            r"(CREATE\s+OR\s+REPLACE\s+TABLE\s+[\w.]+\s*\([\s\S]*?\)\s*COMMENT\s*=\s*'[^']*'\s*;)",
            content,
            re.IGNORECASE
        )
        
        if not match:
            # Try simpler pattern - table without COMMENT
            match = re.search(
                r"(CREATE\s+OR\s+REPLACE\s+TABLE\s+[\w.]+\s*\([\s\S]*?PRIMARY KEY[^)]*\)\s*\)\s*;)",
                content,
                re.IGNORECASE
            )
        
        if not match:
            # Simplest - find up to first lone );
            lines = content.split('\n')
            in_table = False
            table_lines = []
            for line in lines:
                if 'CREATE OR REPLACE TABLE' in line.upper():
                    in_table = True
                if in_table:
                    table_lines.append(line)
                    # Check if line is just ); or COMMENT = '...';
                    stripped = line.strip()
                    if stripped.endswith(';') and ('COMMENT' in stripped.upper() or stripped == ');'):
                        break
            
            if table_lines:
                table_sql = '\n'.join(table_lines)
            else:
                print(f"  ⚠️ Could not extract CREATE TABLE from {sql_file}")
                continue
        else:
            table_sql = match.group(1)
        
        try:
            start = time.time()
            cursor.execute(table_sql)
            duration = round(time.time() - start, 2)
            print(f"  ✅ Table created ({duration}s)")
            results.append({"table": table_name, "status": "SUCCESS"})
        except Exception as e:
            error = str(e)[:300]
            print(f"  ❌ Error: {error}")
            results.append({"table": table_name, "status": "ERROR", "error": error})
    
    # Final verification
    print("\n" + "=" * 70)
    print("FINAL VERIFICATION")
    print("=" * 70)
    
    cursor.execute("""
        SELECT TABLE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'FUSE' AND TABLE_NAME LIKE '%_INCR'
        ORDER BY TABLE_NAME
    """)
    tables = [row[0] for row in cursor.fetchall()]
    print(f"\n📊 All *_INCR Tables in DEV_API_REF.FUSE: {len(tables)}")
    for t in tables:
        print(f"  ✅ {t}")
    
    cursor.execute("""
        SELECT PROCEDURE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
        WHERE PROCEDURE_SCHEMA = 'FUSE' 
        AND (PROCEDURE_NAME LIKE '%_INCR_P' OR PROCEDURE_NAME LIKE 'SP_%_INCR')
        ORDER BY PROCEDURE_NAME
    """)
    procs = [row[0] for row in cursor.fetchall()]
    print(f"\n📊 All *_INCR_P / SP_*_INCR Procedures: {len(procs)}")
    for p in procs:
        print(f"  ✅ {p}")
    
    cursor.close()
    conn.close()
    
    print(f"\n🎉 Completed: {datetime.now().isoformat()}")


if __name__ == "__main__":
    run_deployment()
