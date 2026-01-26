"""
Generate all 11 procedure DDLs for TEST_API_REF.FUSE
Extracts DDL from DEV and replaces database name
"""
import snowflake.connector
from datetime import datetime

INCR_OBJECTS = [
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
conn = snowflake.connector.connect(
    account="fcx.west-us-2.azure",
    user="CCARRILL2@fmi.com",
    authenticator="externalbrowser",
    warehouse="WH_BATCH_DE_NONPROD",
    database="DEV_API_REF",
    schema="FUSE",
    role="SG-AZW-SFLK-ENG-GENERAL"
)
cursor = conn.cursor()

output_file = "ALL_PROCEDURES_FOR_TEST.sql"
print(f"Generating {output_file}...")

with open(output_file, "w", encoding="utf-8") as f:
    f.write(f"""/*
================================================================================
All 11 DRILLBLAST_INCR Procedures for TEST_API_REF.FUSE
================================================================================
Generated: {datetime.now().isoformat()}
Purpose: Create all procedures in TEST environment

Instructions:
1. First run the CLONE TABLE statements to create tables
2. Then run each procedure CREATE statement below
================================================================================
*/

USE DATABASE TEST_API_REF;
USE SCHEMA FUSE;
USE WAREHOUSE WH_BATCH_DE_NONPROD;

""")
    
    for proc_name in INCR_OBJECTS:
        print(f"  Getting DDL for {proc_name}...")
        try:
            cursor.execute(f"SELECT GET_DDL('PROCEDURE', 'DEV_API_REF.FUSE.{proc_name}(VARCHAR)')")
            ddl = cursor.fetchone()[0]
            
            # Replace database name
            ddl = ddl.replace("DEV_API_REF.FUSE", "TEST_API_REF.FUSE")
            ddl = ddl.replace("DEV_API_REF", "TEST_API_REF")
            
            f.write(f"-- ============================================================================\n")
            f.write(f"-- {proc_name}\n")
            f.write(f"-- ============================================================================\n\n")
            f.write(f"DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.{proc_name}(VARCHAR);\n\n")
            f.write(ddl)
            f.write("\n\n")
            
            print(f"    ✅ {proc_name}")
        except Exception as e:
            print(f"    ❌ {proc_name}: {e}")
            f.write(f"-- ERROR: Could not get DDL for {proc_name}: {str(e)[:100]}\n\n")

cursor.close()
conn.close()

print(f"\n✅ Generated {output_file}")
print("Now copy this file to someone with CREATE PROCEDURE privileges on TEST_API_REF.FUSE")
