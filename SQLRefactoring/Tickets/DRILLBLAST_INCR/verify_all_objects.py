"""
Final verification - ensure all 22 objects exist with correct names
"""

import snowflake.connector

SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "DEV_API_REF",
    "schema": "FUSE",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
}

# Expected objects per Vikas's requirement
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

print("Connecting to Snowflake...")
conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
cursor = conn.cursor()
print("Connected!\n")

# Check tables
print("=" * 70)
print("TABLES IN DEV_API_REF.FUSE")
print("=" * 70)
cursor.execute("""
SELECT TABLE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'FUSE' AND TABLE_NAME LIKE '%_INCR'
ORDER BY TABLE_NAME
""")
existing_tables = [r[0] for r in cursor.fetchall()]

missing_tables = []
for t in EXPECTED_TABLES:
    if t in existing_tables:
        print(f"  ✅ {t}")
    else:
        print(f"  ❌ MISSING: {t}")
        missing_tables.append(t)

# Check procedures
print("\n" + "=" * 70)
print("PROCEDURES IN DEV_API_REF.FUSE")
print("=" * 70)
cursor.execute("""
SELECT DISTINCT PROCEDURE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
WHERE PROCEDURE_SCHEMA = 'FUSE' AND PROCEDURE_NAME LIKE '%_INCR_P'
ORDER BY PROCEDURE_NAME
""")
existing_procs = [r[0] for r in cursor.fetchall()]

missing_procs = []
for p in EXPECTED_PROCEDURES:
    if p in existing_procs:
        print(f"  ✅ {p}")
    else:
        print(f"  ❌ MISSING: {p}")
        missing_procs.append(p)

# Summary
print("\n" + "=" * 70)
print("SUMMARY")
print("=" * 70)
print(f"Tables:     {len(EXPECTED_TABLES) - len(missing_tables)}/{len(EXPECTED_TABLES)}")
print(f"Procedures: {len(EXPECTED_PROCEDURES) - len(missing_procs)}/{len(EXPECTED_PROCEDURES)}")

if missing_tables:
    print(f"\n⚠️ Missing tables: {missing_tables}")
if missing_procs:
    print(f"\n⚠️ Missing procedures: {missing_procs}")

if not missing_tables and not missing_procs:
    print("\n✅ ALL 22 OBJECTS PRESENT AND CORRECTLY NAMED!")

cursor.close()
conn.close()
