"""Final verification of DEV objects"""
import snowflake.connector

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='DEV_API_REF',
    schema='FUSE',
    role='SG-AZW-SFLK-ENG-GENERAL'
)
cursor = conn.cursor()

print("\n" + "="*80)
print(" FINAL VERIFICATION - DEV_API_REF.FUSE")
print("="*80)

# Recreate tables clean
print("\n📋 Recreating tables clean...")
cursor.execute("DROP TABLE IF EXISTS DEV_API_REF.FUSE.LH_EQUIPMENT_STATUS_EVENT_INCR")
cursor.execute("DROP TABLE IF EXISTS DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR")
cursor.execute("DROP TABLE IF EXISTS DEV_API_REF.FUSE.LH_BUCKET_INCR")

# Read and execute table DDLs
import os
base_path = r"C:\Users\ccarrill2\Documents\repos\FP\SQLRefactoring\Tickets\DRILLBLAST_INCR\DDL-Scripts\API_REF\FUSE"

table_files = [
    "TABLES/R__LH_EQUIPMENT_STATUS_EVENT_INCR.sql",
    "TABLES/R__LH_LOADING_CYCLE_INCR.sql",
    "TABLES/R__LH_BUCKET_INCR.sql"
]

for tfile in table_files:
    with open(os.path.join(base_path, tfile), 'r') as f:
        sql = f.read().replace("{{ envi }}", "DEV").replace("{{ RO_PROD }}", "PROD")
    cursor.execute(sql)
    print(f"  ✅ Created: {tfile.split('/')[-1]}")

# Read and execute procedure DDLs
proc_files = [
    "PROCEDURES/R__LH_EQUIPMENT_STATUS_EVENT_INCR_P.sql",
    "PROCEDURES/R__LH_LOADING_CYCLE_INCR_P.sql",
    "PROCEDURES/R__LH_BUCKET_INCR_P.sql"
]

for pfile in proc_files:
    with open(os.path.join(base_path, pfile), 'r') as f:
        sql = f.read().replace("{{ envi }}", "DEV").replace("{{ RO_PROD }}", "PROD")
    cursor.execute(sql)
    print(f"  ✅ Created: {pfile.split('/')[-1]}")

# Execute all procedures
print("\n📋 Executing procedures...")
procedures = [
    ("LH_EQUIPMENT_STATUS_EVENT_INCR_P", "LH_EQUIPMENT_STATUS_EVENT_INCR"),
    ("LH_LOADING_CYCLE_INCR_P", "LH_LOADING_CYCLE_INCR"),
    ("LH_BUCKET_INCR_P", "LH_BUCKET_INCR")
]

for proc, table in procedures:
    cursor.execute(f"CALL DEV_API_REF.FUSE.{proc}('3')")
    result = cursor.fetchone()[0]
    cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}")
    count = cursor.fetchone()[0]
    print(f"  ✅ {proc}: {result} | Total rows: {count:,}")

# Final object list
print("\n📋 Final Objects in DEV_API_REF.FUSE:")

cursor.execute("""
    SELECT 'TABLE' as type, TABLE_NAME as name, ROW_COUNT as info
    FROM DEV_API_REF.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'FUSE'
    AND TABLE_NAME LIKE 'LH_%_INCR'
    AND TABLE_NAME NOT LIKE '%_P'
    UNION ALL
    SELECT 'PROCEDURE', PROCEDURE_NAME, NULL
    FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES
    WHERE PROCEDURE_SCHEMA = 'FUSE'
    AND PROCEDURE_NAME LIKE 'LH_%_INCR_P'
    ORDER BY 1, 2
""")

for row in cursor.fetchall():
    if row[0] == 'TABLE':
        print(f"  📦 {row[0]}: {row[1]} ({row[2]:,} rows)")
    else:
        print(f"  ⚙️ {row[0]}: {row[1]}")

print("\n" + "="*80)
print(" ✅ DEV VERIFICATION COMPLETE")
print("="*80 + "\n")

cursor.close()
conn.close()
