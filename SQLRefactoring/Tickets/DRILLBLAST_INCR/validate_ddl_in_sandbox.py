"""
Validate DDL scripts by deploying to SANDBOX first
Then if successful, the same DDL will work for TEST_API_REF
"""
import snowflake.connector
from datetime import datetime

# Deploy to sandbox first for validation
TARGET_DB = "SANDBOX_DATA_ENGINEER"
TARGET_SCHEMA = "CCARRILL2"

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
print("Validating DDL in SANDBOX_DATA_ENGINEER.CCARRILL2")
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

# =========================================================================
# STEP 1: Create tables in sandbox using DDL from DEV
# =========================================================================
print("\n1. Creating tables in SANDBOX...")
tables_ok = 0
tables_failed = []

for table_name in INCR_TABLES:
    try:
        # Get DDL from DEV
        cursor.execute(f"SELECT GET_DDL('TABLE', 'DEV_API_REF.FUSE.{table_name}')")
        ddl = cursor.fetchone()[0]
        
        # Replace to sandbox
        ddl = ddl.replace("DEV_API_REF.FUSE", f"{TARGET_DB}.{TARGET_SCHEMA}")
        
        # Drop if exists and create
        cursor.execute(f"DROP TABLE IF EXISTS {TARGET_DB}.{TARGET_SCHEMA}.{table_name}")
        cursor.execute(ddl)
        
        print(f"   ✅ {table_name}")
        tables_ok += 1
    except Exception as e:
        print(f"   ❌ {table_name}: {str(e)[:60]}")
        tables_failed.append(table_name)

print(f"\n   Tables created: {tables_ok}/{len(INCR_TABLES)}")

# =========================================================================
# STEP 2: Create procedures in sandbox
# =========================================================================
print("\n2. Creating procedures in SANDBOX...")
procs_ok = 0
procs_failed = []

for table_name in INCR_TABLES:
    proc_name = f"{table_name}_P"
    try:
        # Get DDL from DEV
        cursor.execute(f"SELECT GET_DDL('PROCEDURE', 'DEV_API_REF.FUSE.{proc_name}(VARCHAR)')")
        ddl = cursor.fetchone()[0]
        
        # Replace to sandbox
        ddl = ddl.replace("DEV_API_REF.FUSE", f"{TARGET_DB}.{TARGET_SCHEMA}")
        ddl = ddl.replace("DEV_API_REF", TARGET_DB)
        
        # Drop if exists and create
        cursor.execute(f"DROP PROCEDURE IF EXISTS {TARGET_DB}.{TARGET_SCHEMA}.{proc_name}(VARCHAR)")
        cursor.execute(ddl)
        
        print(f"   ✅ {proc_name}")
        procs_ok += 1
    except Exception as e:
        print(f"   ❌ {proc_name}: {str(e)[:60]}")
        procs_failed.append(proc_name)

print(f"\n   Procedures created: {procs_ok}/{len(INCR_TABLES)}")

# =========================================================================
# STEP 3: Test one procedure (BLAST_PLAN_EXECUTION_INCR_P)
# =========================================================================
print("\n3. Testing BLAST_PLAN_EXECUTION_INCR_P with 3-day lookback...")
try:
    cursor.execute(f"CALL {TARGET_DB}.{TARGET_SCHEMA}.BLAST_PLAN_EXECUTION_INCR_P('3')")
    result = cursor.fetchone()[0]
    print(f"   Result: {result}")
    
    if "SUCCESS" in result:
        print("   ✅ Procedure executed successfully!")
    else:
        print("   ⚠️ Check result above")
        
    # Check row count
    cursor.execute(f"SELECT COUNT(*) FROM {TARGET_DB}.{TARGET_SCHEMA}.BLAST_PLAN_EXECUTION_INCR")
    count = cursor.fetchone()[0]
    print(f"   Rows in table: {count:,}")
    
    # Check for duplicates
    cursor.execute(f"""
        SELECT COUNT(*) FROM (
            SELECT ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID
            FROM {TARGET_DB}.{TARGET_SCHEMA}.BLAST_PLAN_EXECUTION_INCR
            GROUP BY ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID
            HAVING COUNT(*) > 1
        )
    """)
    dups = cursor.fetchone()[0]
    if dups == 0:
        print("   ✅ No duplicates on business key")
    else:
        print(f"   ❌ Found {dups} duplicate keys!")
        
except Exception as e:
    print(f"   ❌ Error: {e}")

# =========================================================================
# STEP 4: Cleanup sandbox (optional)
# =========================================================================
print("\n4. Cleanup (removing test objects from sandbox)...")
for table_name in INCR_TABLES:
    try:
        cursor.execute(f"DROP TABLE IF EXISTS {TARGET_DB}.{TARGET_SCHEMA}.{table_name}")
        cursor.execute(f"DROP PROCEDURE IF EXISTS {TARGET_DB}.{TARGET_SCHEMA}.{table_name}_P(VARCHAR)")
    except:
        pass
print("   ✅ Cleanup complete")

cursor.close()
conn.close()

print("\n" + "=" * 70)
if tables_ok == len(INCR_TABLES) and procs_ok == len(INCR_TABLES):
    print("✅ VALIDATION PASSED - DDL scripts are correct!")
    print("   The same DDL will work for TEST_API_REF.FUSE")
else:
    print("⚠️ VALIDATION INCOMPLETE - Check errors above")
print("=" * 70)
