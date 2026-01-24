"""
Debug the 2 remaining broken procedures
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

print("Connecting...")
conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
cursor = conn.cursor()
print("Connected!\n")

# Check source table schemas
print("=" * 60)
print("CHECKING SOURCE TABLE: PROD_WG.DRILL_BLAST.DRILLBLAST_SHIFT")
print("=" * 60)
cursor.execute("SELECT COLUMN_NAME FROM PROD_WG.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DRILL_BLAST' AND TABLE_NAME = 'DRILLBLAST_SHIFT' ORDER BY ORDINAL_POSITION")
shift_cols = [r[0] for r in cursor.fetchall()]
print(f"Columns: {shift_cols}")

print("\n" + "=" * 60)
print("CHECKING TARGET TABLE: DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR")
print("=" * 60)
cursor.execute("SELECT COLUMN_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'FUSE' AND TABLE_NAME = 'DRILLBLAST_SHIFT_INCR' ORDER BY ORDINAL_POSITION")
target_cols = [r[0] for r in cursor.fetchall()]
print(f"Columns: {target_cols}")

print("\n" + "=" * 60)
print("CHECKING SOURCE TABLE: PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE")
print("=" * 60)
cursor.execute("SELECT COLUMN_NAME FROM PROD_WG.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'LOAD_HAUL' AND TABLE_NAME = 'LH_HAUL_CYCLE' ORDER BY ORDINAL_POSITION")
haul_cols = [r[0] for r in cursor.fetchall()]
print(f"Columns ({len(haul_cols)}): {haul_cols}")

print("\n" + "=" * 60)
print("CHECKING TARGET TABLE: DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR")
print("=" * 60)
cursor.execute("SELECT COLUMN_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'FUSE' AND TABLE_NAME = 'LH_HAUL_CYCLE_INCR' ORDER BY ORDINAL_POSITION")
target_haul_cols = [r[0] for r in cursor.fetchall()]
print(f"Columns ({len(target_haul_cols)}): {target_haul_cols}")

# Try running bare merge queries
print("\n" + "=" * 60)
print("TESTING BARE SHIFT MERGE")
print("=" * 60)
try:
    cursor.execute("""
    SELECT COUNT(*) FROM prod_wg.drill_blast.drillblast_shift
    WHERE dw_modify_ts >= DATEADD(day, -3, CURRENT_TIMESTAMP())
    """)
    print(f"Source rows in last 3 days: {cursor.fetchone()[0]}")
except Exception as e:
    print(f"Error: {e}")

print("\n" + "=" * 60)
print("TESTING BARE HAUL MERGE")
print("=" * 60)
try:
    cursor.execute("""
    SELECT COUNT(*) FROM prod_wg.load_haul.lh_haul_cycle
    WHERE dw_modify_ts >= DATEADD(day, -3, CURRENT_TIMESTAMP())
    """)
    print(f"Source rows in last 3 days: {cursor.fetchone()[0]}")
except Exception as e:
    print(f"Error: {e}")

# Get full error message
print("\n" + "=" * 60)
print("CALLING DRILLBLAST_SHIFT_INCR_P")
print("=" * 60)
try:
    cursor.execute("CALL DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P('3')")
    print(f"Result: {cursor.fetchone()}")
except Exception as e:
    print(f"Full error: {e}")

print("\n" + "=" * 60)
print("CALLING LH_HAUL_CYCLE_INCR_P")
print("=" * 60)
try:
    cursor.execute("CALL DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P('3')")
    print(f"Result: {cursor.fetchone()}")
except Exception as e:
    print(f"Full error: {e}")

cursor.close()
conn.close()
