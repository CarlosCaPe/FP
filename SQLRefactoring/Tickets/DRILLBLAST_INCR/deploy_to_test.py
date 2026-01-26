"""
Deploy DRILLBLAST_INCR Objects to TEST_API_REF.FUSE
====================================================
Moves all 22 objects (11 tables + 11 procedures) from DEV to TEST.

Requested by Vikas: "can you please move all these 22 objects to test (database - TEST_API_REF)"
"""

import snowflake.connector
from datetime import datetime

# All 11 INCR objects
INCR_OBJECTS = [
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

SOURCE_DB = "DEV_API_REF"
TARGET_DB = "TEST_API_REF"
SCHEMA = "FUSE"

print("=" * 70)
print("Deploy DRILLBLAST_INCR Objects to TEST_API_REF.FUSE")
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

# Step 1: Verify TEST_API_REF.FUSE schema exists
print("\n1. Verifying TEST_API_REF.FUSE schema exists...")
try:
    cursor.execute(f"USE DATABASE {TARGET_DB}")
    cursor.execute(f"USE SCHEMA {SCHEMA}")
    print(f"   ✅ {TARGET_DB}.{SCHEMA} exists")
except Exception as e:
    print(f"   ❌ Error: {e}")
    print("   Creating schema...")
    cursor.execute(f"CREATE SCHEMA IF NOT EXISTS {TARGET_DB}.{SCHEMA}")
    print(f"   ✅ Created {TARGET_DB}.{SCHEMA}")

# Step 2: Clone tables from DEV to TEST
print("\n2. Cloning tables from DEV to TEST...")
tables_created = 0
tables_failed = []

for obj in INCR_OBJECTS:
    try:
        # First drop if exists to avoid conflicts
        cursor.execute(f"DROP TABLE IF EXISTS {TARGET_DB}.{SCHEMA}.{obj}")
        
        # Clone table with data
        sql = f"""
            CREATE TABLE {TARGET_DB}.{SCHEMA}.{obj} 
            CLONE {SOURCE_DB}.{SCHEMA}.{obj}
        """
        cursor.execute(sql)
        
        # Get row count
        cursor.execute(f"SELECT COUNT(*) FROM {TARGET_DB}.{SCHEMA}.{obj}")
        count = cursor.fetchone()[0]
        
        print(f"   ✅ {obj}: Cloned ({count:,} rows)")
        tables_created += 1
    except Exception as e:
        print(f"   ❌ {obj}: {str(e)[:60]}")
        tables_failed.append(obj)

print(f"\n   Tables: {tables_created}/{len(INCR_OBJECTS)} created")

# Step 3: Get procedure DDL from DEV and recreate in TEST
print("\n3. Copying procedures from DEV to TEST...")
procs_created = 0
procs_failed = []

for obj in INCR_OBJECTS:
    proc_name = f"{obj}_P"
    try:
        # Get procedure DDL
        cursor.execute(f"""
            SELECT GET_DDL('PROCEDURE', '{SOURCE_DB}.{SCHEMA}.{proc_name}(VARCHAR)')
        """)
        ddl = cursor.fetchone()[0]
        
        # Replace database name in DDL
        ddl = ddl.replace(f"{SOURCE_DB}.{SCHEMA}", f"{TARGET_DB}.{SCHEMA}")
        
        # Drop existing procedure if any
        cursor.execute(f"DROP PROCEDURE IF EXISTS {TARGET_DB}.{SCHEMA}.{proc_name}(VARCHAR)")
        
        # Create procedure in TEST
        cursor.execute(ddl)
        
        print(f"   ✅ {proc_name}: Created")
        procs_created += 1
    except Exception as e:
        print(f"   ❌ {proc_name}: {str(e)[:60]}")
        procs_failed.append(proc_name)

print(f"\n   Procedures: {procs_created}/{len(INCR_OBJECTS)} created")

# Step 4: Verify all objects exist in TEST
print("\n4. Verifying all objects in TEST_API_REF.FUSE...")
cursor.execute(f"""
    SELECT TABLE_NAME 
    FROM {TARGET_DB}.INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = '{SCHEMA}'
    AND TABLE_NAME LIKE '%_INCR'
    ORDER BY TABLE_NAME
""")
tables = [r[0] for r in cursor.fetchall()]
print(f"   Tables found: {len(tables)}")
for t in tables:
    print(f"     - {t}")

cursor.execute(f"""
    SELECT PROCEDURE_NAME, ARGUMENT_SIGNATURE
    FROM {TARGET_DB}.INFORMATION_SCHEMA.PROCEDURES 
    WHERE PROCEDURE_SCHEMA = '{SCHEMA}'
    AND PROCEDURE_NAME LIKE '%_INCR_P'
    ORDER BY PROCEDURE_NAME
""")
procs = cursor.fetchall()
print(f"   Procedures found: {len(procs)}")
for p in procs:
    print(f"     - {p[0]}{p[1]}")

cursor.close()
conn.close()

print("\n" + "=" * 70)
if tables_created == len(INCR_OBJECTS) and procs_created == len(INCR_OBJECTS):
    print("✅ DEPLOYMENT TO TEST COMPLETE - All 22 objects created")
else:
    print("⚠️ DEPLOYMENT INCOMPLETE - Check failed objects above")
print("=" * 70)

if tables_failed:
    print(f"\nFailed tables: {tables_failed}")
if procs_failed:
    print(f"Failed procedures: {procs_failed}")
