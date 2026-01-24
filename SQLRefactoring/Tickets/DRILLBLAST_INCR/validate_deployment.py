"""
DRILLBLAST_INCR - Final Validation and Summary
"""

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
}

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

print("=" * 70)
print("DRILLBLAST_INCR - FINAL VALIDATION")
print("=" * 70)
print(f"Time: {datetime.now().isoformat()}")
print("=" * 70)

print("\nConnecting to Snowflake...")
conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
cursor = conn.cursor()
print("✅ Connected!\n")

# Get tables
cursor.execute("""
    SELECT TABLE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'FUSE' AND TABLE_NAME LIKE '%_INCR'
    ORDER BY TABLE_NAME
""")
existing_tables = {row[0] for row in cursor.fetchall()}

# Get procedures
cursor.execute("""
    SELECT PROCEDURE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
    WHERE PROCEDURE_SCHEMA = 'FUSE' 
    AND (PROCEDURE_NAME LIKE '%_INCR_P' OR PROCEDURE_NAME LIKE 'SP_%_INCR')
    ORDER BY PROCEDURE_NAME
""")
existing_procs = {row[0] for row in cursor.fetchall()}

# Check required tables
print("📊 REQUIRED DRILLBLAST_INCR TABLES:")
tables_ok = 0
for table in EXPECTED_TABLES:
    if table in existing_tables:
        print(f"  ✅ {table}")
        tables_ok += 1
    else:
        print(f"  ❌ {table} - MISSING!")

# Check required procedures
print("\n📊 REQUIRED DRILLBLAST_INCR PROCEDURES:")
procs_ok = 0
for proc in EXPECTED_PROCEDURES:
    if proc in existing_procs:
        print(f"  ✅ {proc}")
        procs_ok += 1
    else:
        print(f"  ❌ {proc} - MISSING!")

# Summary
print("\n" + "=" * 70)
print("DEPLOYMENT SUMMARY")
print("=" * 70)
print(f"Required Tables:     {tables_ok}/{len(EXPECTED_TABLES)}")
print(f"Required Procedures: {procs_ok}/{len(EXPECTED_PROCEDURES)}")

if tables_ok == len(EXPECTED_TABLES) and procs_ok == len(EXPECTED_PROCEDURES):
    print("\n🎉 ALL DRILLBLAST_INCR OBJECTS DEPLOYED SUCCESSFULLY!")
    print("\nVikas can now use these objects:")
    print("  SELECT * FROM DEV_API_REF.FUSE.BL_DW_BLAST_INCR;")
    print("  CALL DEV_API_REF.FUSE.BL_DW_BLAST_INCR_P('3');")
else:
    print(f"\n⚠️ DEPLOYMENT INCOMPLETE - Missing {len(EXPECTED_TABLES) - tables_ok} tables and {len(EXPECTED_PROCEDURES) - procs_ok} procedures")

cursor.close()
conn.close()
