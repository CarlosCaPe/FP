"""
DRILLBLAST_INCR - Complete Validation & Testing
Tests all 11 tables and 11 procedures as Vikas would
"""

import snowflake.connector
from datetime import datetime
import json

SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "DEV_API_REF",
    "schema": "FUSE",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
}

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
    "LH_HAUL_CYCLE_INCR",
]

PROCEDURES = [
    ("BL_DW_BLAST_INCR_P", "'3'"),
    ("BL_DW_BLASTPROPERTYVALUE_INCR_P", "'3'"),
    ("BL_DW_HOLE_INCR_P", "'3'"),
    ("DRILLBLAST_EQUIPMENT_INCR_P", "'3'"),
    ("DRILLBLAST_OPERATOR_INCR_P", "'3'"),
    ("DRILLBLAST_SHIFT_INCR_P", "'3'"),
    ("LH_HAUL_CYCLE_INCR_P", "'3'"),
    ("BLAST_PLAN_INCR_P", "'3'"),
    ("BLAST_PLAN_EXECUTION_INCR_P", "'3'"),
    ("DRILL_CYCLE_INCR_P", "'3'"),
    ("DRILL_PLAN_INCR_P", "'3'"),
]

def main():
    print("=" * 80)
    print("DRILLBLAST_INCR - COMPLETE VALIDATION & TESTING")
    print("=" * 80)
    print(f"Time: {datetime.now().isoformat()}")
    print(f"Database: DEV_API_REF.FUSE")
    print("=" * 80)
    
    print("\n📋 Connecting to Snowflake...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    print("✅ Connected!\n")
    
    # Set context
    cursor.execute("USE DATABASE DEV_API_REF;")
    cursor.execute("USE SCHEMA FUSE;")
    cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD;")
    
    # Check current role and grants
    print("=" * 80)
    print("CHECKING PERMISSIONS")
    print("=" * 80)
    
    cursor.execute("SELECT CURRENT_ROLE(), CURRENT_USER(), CURRENT_DATABASE(), CURRENT_SCHEMA();")
    row = cursor.fetchone()
    print(f"Role: {row[0]}")
    print(f"User: {row[1]}")
    print(f"Database: {row[2]}")
    print(f"Schema: {row[3]}")
    
    # Check schema grants
    print("\n📋 Checking schema grants...")
    try:
        cursor.execute("SHOW GRANTS ON SCHEMA DEV_API_REF.FUSE;")
        grants = cursor.fetchall()
        print(f"Found {len(grants)} grants on schema FUSE")
        for g in grants[:5]:
            print(f"  - {g}")
    except Exception as e:
        print(f"  ⚠️ Cannot check grants: {str(e)[:100]}")
    
    results = {"tables": [], "procedures": [], "grants_needed": []}
    
    # Test Tables
    print("\n" + "=" * 80)
    print("TESTING TABLES (SELECT)")
    print("=" * 80)
    
    for table in TABLES:
        full_name = f"DEV_API_REF.FUSE.{table}"
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {full_name};")
            count = cursor.fetchone()[0]
            status = "✅ EXISTS"
            results["tables"].append({
                "table": table,
                "status": "SUCCESS",
                "row_count": count,
                "select_test": "PASSED"
            })
            print(f"  {status} {table}: {count} rows")
        except Exception as e:
            error = str(e)
            if "does not exist" in error.lower():
                status = "❌ NOT FOUND"
                results["tables"].append({
                    "table": table,
                    "status": "NOT_EXISTS",
                    "error": error[:100]
                })
            elif "not authorized" in error.lower():
                status = "🔒 NO ACCESS"
                results["tables"].append({
                    "table": table,
                    "status": "NO_ACCESS",
                    "error": error[:100]
                })
                results["grants_needed"].append(f"GRANT SELECT ON TABLE {full_name} TO ROLE <role>;")
            else:
                status = "⚠️ ERROR"
                results["tables"].append({
                    "table": table,
                    "status": "ERROR",
                    "error": error[:100]
                })
            print(f"  {status} {table}: {error[:80]}")
    
    # Test Procedures
    print("\n" + "=" * 80)
    print("TESTING PROCEDURES (CALL)")
    print("=" * 80)
    
    for proc_name, args in PROCEDURES:
        full_name = f"DEV_API_REF.FUSE.{proc_name}"
        try:
            cursor.execute(f"CALL {full_name}({args});")
            result = cursor.fetchone()
            status = "✅ WORKS"
            results["procedures"].append({
                "procedure": proc_name,
                "status": "SUCCESS",
                "result": str(result)[:100] if result else "OK"
            })
            print(f"  {status} {proc_name}: {str(result)[:60] if result else 'OK'}")
        except Exception as e:
            error = str(e)
            if "does not exist" in error.lower():
                status = "❌ NOT FOUND"
            elif "not authorized" in error.lower():
                status = "🔒 NO ACCESS"
                results["grants_needed"].append(f"GRANT USAGE ON PROCEDURE {full_name}(...) TO ROLE <role>;")
            else:
                status = "⚠️ ERROR"
            results["procedures"].append({
                "procedure": proc_name,
                "status": "FAILED",
                "error": error[:100]
            })
            print(f"  {status} {proc_name}: {error[:60]}")
    
    # Summary
    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    
    tables_ok = sum(1 for t in results["tables"] if t["status"] == "SUCCESS")
    procs_ok = sum(1 for p in results["procedures"] if p["status"] == "SUCCESS")
    
    print(f"Tables:     {tables_ok}/{len(TABLES)}")
    print(f"Procedures: {procs_ok}/{len(PROCEDURES)}")
    
    if results["grants_needed"]:
        print("\n⚠️ GRANTS NEEDED FOR OTHER USERS:")
        for grant in results["grants_needed"]:
            print(f"  {grant}")
    
    # Generate markdown table for response
    print("\n" + "=" * 80)
    print("MARKDOWN TABLE FOR VIKAS")
    print("=" * 80)
    
    print("\n| Object | Type | Status | Details |")
    print("|--------|------|--------|---------|")
    for t in results["tables"]:
        status = "✅" if t["status"] == "SUCCESS" else "❌"
        detail = f"{t.get('row_count', 0)} rows" if t["status"] == "SUCCESS" else t.get("error", "")[:30]
        print(f"| {t['table']} | TABLE | {status} | {detail} |")
    for p in results["procedures"]:
        status = "✅" if p["status"] == "SUCCESS" else "❌"
        detail = p.get("result", "")[:30] if p["status"] == "SUCCESS" else p.get("error", "")[:30]
        print(f"| {p['procedure']} | PROCEDURE | {status} | {detail} |")
    
    # Save results
    output_file = f"test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\n📁 Results saved to: {output_file}")
    
    cursor.close()
    conn.close()
    
    print("\n🎉 Testing complete!")

if __name__ == "__main__":
    main()
