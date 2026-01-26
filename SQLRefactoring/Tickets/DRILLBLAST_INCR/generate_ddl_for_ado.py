"""
Generate complete DDL scripts for TEST_API_REF.FUSE deployment via ADO
- Extracts full CREATE TABLE DDL (not CLONE)
- Extracts full CREATE PROCEDURE DDL
"""
import snowflake.connector
from datetime import datetime

INCR_TABLES = [
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

print("=" * 70)
print("Generating DDL Scripts for ADO Deployment")
print(f"Started: {datetime.now().isoformat()}")
print("=" * 70)

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

# Output file
output_file = "DDL_FOR_TEST_API_REF_ADO.sql"
print(f"\nGenerating {output_file}...")

with open(output_file, "w", encoding="utf-8") as f:
    f.write(f"""/*
================================================================================
DRILLBLAST_INCR Objects - DDL for TEST_API_REF.FUSE
================================================================================
Generated: {datetime.now().isoformat()}
Purpose: Complete DDL scripts for Azure DevOps deployment to TEST environment

Objects:
  - 11 Tables (CREATE TABLE with full column definitions)
  - 11 Stored Procedures (CREATE PROCEDURE)

Instructions:
  1. Deploy tables first (Section 1)
  2. Deploy procedures second (Section 2)
  3. Run initial load: CALL <procedure_name>('30');
================================================================================
*/

USE DATABASE TEST_API_REF;
USE SCHEMA FUSE;
USE WAREHOUSE WH_BATCH_DE_NONPROD;

""")

    # =========================================================================
    # SECTION 1: TABLE DDL
    # =========================================================================
    f.write("-- " + "=" * 76 + "\n")
    f.write("-- SECTION 1: TABLE DDL (11 Tables)\n")
    f.write("-- " + "=" * 76 + "\n\n")
    
    tables_ok = 0
    for table_name in INCR_TABLES:
        print(f"  Getting DDL for TABLE {table_name}...")
        try:
            cursor.execute(f"SELECT GET_DDL('TABLE', 'DEV_API_REF.FUSE.{table_name}')")
            ddl = cursor.fetchone()[0]
            
            # Replace database reference
            ddl = ddl.replace("DEV_API_REF.FUSE", "TEST_API_REF.FUSE")
            ddl = ddl.replace("DEV_API_REF", "TEST_API_REF")
            
            f.write(f"-- ----------------------------------------------------------------------------\n")
            f.write(f"-- TABLE: {table_name}\n")
            f.write(f"-- ----------------------------------------------------------------------------\n\n")
            f.write(f"DROP TABLE IF EXISTS TEST_API_REF.FUSE.{table_name};\n\n")
            f.write(ddl)
            f.write(";\n\n")
            
            print(f"    ✅ {table_name}")
            tables_ok += 1
        except Exception as e:
            print(f"    ❌ {table_name}: {str(e)[:60]}")
            f.write(f"-- ERROR: Could not get DDL for {table_name}: {str(e)[:100]}\n\n")

    print(f"\n  Tables: {tables_ok}/{len(INCR_TABLES)} extracted")

    # =========================================================================
    # SECTION 2: PROCEDURE DDL
    # =========================================================================
    f.write("\n\n-- " + "=" * 76 + "\n")
    f.write("-- SECTION 2: STORED PROCEDURE DDL (11 Procedures)\n")
    f.write("-- " + "=" * 76 + "\n\n")
    
    procs_ok = 0
    for table_name in INCR_TABLES:
        proc_name = f"{table_name}_P"
        print(f"  Getting DDL for PROCEDURE {proc_name}...")
        try:
            cursor.execute(f"SELECT GET_DDL('PROCEDURE', 'DEV_API_REF.FUSE.{proc_name}(VARCHAR)')")
            ddl = cursor.fetchone()[0]
            
            # Replace database reference
            ddl = ddl.replace("DEV_API_REF.FUSE", "TEST_API_REF.FUSE")
            ddl = ddl.replace("DEV_API_REF", "TEST_API_REF")
            
            f.write(f"-- ----------------------------------------------------------------------------\n")
            f.write(f"-- PROCEDURE: {proc_name}\n")
            f.write(f"-- ----------------------------------------------------------------------------\n\n")
            f.write(f"DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.{proc_name}(VARCHAR);\n\n")
            f.write(ddl)
            f.write("\n\n")
            
            print(f"    ✅ {proc_name}")
            procs_ok += 1
        except Exception as e:
            print(f"    ❌ {proc_name}: {str(e)[:60]}")
            f.write(f"-- ERROR: Could not get DDL for {proc_name}: {str(e)[:100]}\n\n")

    print(f"\n  Procedures: {procs_ok}/{len(INCR_TABLES)} extracted")

    # =========================================================================
    # SECTION 3: INITIAL LOAD COMMANDS
    # =========================================================================
    f.write("\n\n-- " + "=" * 76 + "\n")
    f.write("-- SECTION 3: INITIAL LOAD (Run after deployment)\n")
    f.write("-- " + "=" * 76 + "\n\n")
    f.write("-- Run each procedure with 30-day lookback for initial data load:\n\n")
    
    for table_name in INCR_TABLES:
        proc_name = f"{table_name}_P"
        f.write(f"CALL TEST_API_REF.FUSE.{proc_name}('30');\n")

    # =========================================================================
    # SECTION 4: VALIDATION QUERIES
    # =========================================================================
    f.write("\n\n-- " + "=" * 76 + "\n")
    f.write("-- SECTION 4: VALIDATION QUERIES\n")
    f.write("-- " + "=" * 76 + "\n\n")
    f.write("""-- Verify all tables exist
SELECT TABLE_NAME, ROW_COUNT, CREATED
FROM TEST_API_REF.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'FUSE' 
AND TABLE_NAME LIKE '%_INCR'
ORDER BY TABLE_NAME;

-- Verify all procedures exist
SELECT PROCEDURE_NAME, ARGUMENT_SIGNATURE, CREATED
FROM TEST_API_REF.INFORMATION_SCHEMA.PROCEDURES 
WHERE PROCEDURE_SCHEMA = 'FUSE' 
AND PROCEDURE_NAME LIKE '%_INCR_P'
ORDER BY PROCEDURE_NAME;

-- Quick test one procedure
CALL TEST_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P('3');
""")

cursor.close()
conn.close()

print("\n" + "=" * 70)
print(f"✅ Generated: {output_file}")
print(f"   Tables: {tables_ok}/11")
print(f"   Procedures: {procs_ok}/11")
print("=" * 70)
print("\nThis file contains complete DDL (not CLONE) ready for ADO deployment.")
