"""
Deploy fix for BLAST_PLAN_EXECUTION_INCR_P - adds QUALIFY deduplication
Only deploys the procedure, not the table (minimal change)
"""

import os
import snowflake.connector
from datetime import datetime

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

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # Use the fixed version with proper signature for Vikas API
    sql_file = os.path.join(script_dir, "BLAST_PLAN_EXECUTION_INCR_P_FIX.sql")
    
    print("=" * 70)
    print("FIX: BLAST_PLAN_EXECUTION_INCR_P - Duplicate Row Error")
    print("=" * 70)
    print(f"Started: {datetime.now().isoformat()}")
    print("Fixes applied:")
    print("  1. Changed signature to VARCHAR for API compatibility")
    print("  2. Added QUALIFY ROW_NUMBER() to deduplicate source data")
    print("  3. Simplified JavaScript to match other INCR procedures")
    print("=" * 70)
    
    # Read SQL file
    with open(sql_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find procedure only (skip comments)
    lines = content.split('\n')
    proc_start = None
    for i, line in enumerate(lines):
        if line.strip().startswith("CREATE OR REPLACE PROCEDURE"):
            proc_start = i
            break
    
    if proc_start is None:
        print("❌ Could not find procedure in SQL file!")
        return
    
    proc_sql = '\n'.join(lines[proc_start:])
    
    # Verify QUALIFY is present
    if "QUALIFY ROW_NUMBER()" not in proc_sql:
        print("❌ QUALIFY fix not found in procedure!")
        return
    
    # Verify VARCHAR signature
    if '"NUMBER_OF_DAYS" VARCHAR' not in proc_sql:
        print("❌ VARCHAR signature not found in procedure!")
        return
    
    print(f"\n✅ Found BLAST_PLAN_EXECUTION_INCR_P with fixes")
    print(f"   SQL length: {len(proc_sql)} chars")
    print("   QUALIFY ROW_NUMBER() deduplication: ✅ Present")
    print("   VARCHAR signature for API: ✅ Present")
    
    # Connect
    print("\n📋 Connecting to Snowflake (browser auth)...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    print("✅ Connected!")
    
    # Set context
    cursor.execute("USE DATABASE DEV_API_REF;")
    cursor.execute("USE SCHEMA FUSE;")
    cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD;")
    
    # Check existing procedures and drop if needed to avoid overload conflict
    print("\n📋 Checking existing procedure versions...")
    cursor.execute("""
        SELECT PROCEDURE_NAME, ARGUMENT_SIGNATURE
        FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
        WHERE PROCEDURE_NAME = 'BLAST_PLAN_EXECUTION_INCR_P'
    """)
    existing = cursor.fetchall()
    for row in existing:
        print(f"   Found: {row[0]}{row[1]}")
    
    # Drop all existing versions to avoid overload conflict
    if existing:
        print("\n🗑️  Dropping existing procedure versions to avoid overload conflict...")
        for row in existing:
            # Parse argument types from signature like "(NUMBER_OF_DAYS VARCHAR)"
            sig = row[1]
            # Extract just the types: VARCHAR, FLOAT, etc.
            import re
            types = re.findall(r'\b(VARCHAR|FLOAT|NUMBER|INT|STRING|BOOLEAN|VARIANT)\b', sig.upper())
            type_str = ", ".join(types) if types else ""
            drop_sql = f"DROP PROCEDURE IF EXISTS DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P({type_str})"
            print(f"   Executing: {drop_sql}")
            try:
                cursor.execute(drop_sql)
                print(f"   ✅ Dropped!")
            except Exception as e:
                print(f"   ⚠️  Could not drop: {e}")
    
    # Deploy procedure
    print("\n🚀 Deploying BLAST_PLAN_EXECUTION_INCR_P...")
    try:
        cursor.execute(proc_sql)
        print("✅ Procedure deployed successfully!")
    except Exception as e:
        print(f"❌ Failed: {e}")
        return
    
    # Verify
    print("\n📋 Verifying deployment...")
    cursor.execute("""
        SELECT PROCEDURE_NAME, CREATED 
        FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
        WHERE PROCEDURE_NAME = 'BLAST_PLAN_EXECUTION_INCR_P'
    """)
    rows = cursor.fetchall()
    if rows:
        print(f"✅ Verified: {rows[0][0]} (created: {rows[0][1]})")
    
    # Test call
    print("\n🧪 Testing procedure (quick test with 1 day lookback)...")
    try:
        cursor.execute("CALL DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P(1, 30);")
        result = cursor.fetchone()
        print(f"✅ Test successful: {result[0] if result else 'OK'}")
    except Exception as e:
        print(f"⚠️  Test failed: {e}")
    
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 70)
    print("✅ DEPLOYMENT COMPLETE")
    print("=" * 70)

if __name__ == "__main__":
    main()
