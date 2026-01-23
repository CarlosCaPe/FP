"""Quick script to discover correct table names in Snowflake"""
import snowflake.connector

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='PROD_WG'
)
cursor = conn.cursor()

print("=" * 60)
print("DISCOVERING TABLE NAMES AND DATA AVAILABILITY")
print("=" * 60)

# Test each table directly
test_tables = [
    ("PROD_WG.DRILL_BLAST.DRILL_CYCLE", "DW_MODIFY_TS"),
    ("PROD_WG.DRILL_BLAST.DRILL_PLAN", "DW_MODIFY_TS"),
    ("PROD_WG.DRILL_BLAST.BLAST_PLAN", "DW_MODIFY_TS"),
    ("PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION", "DW_MODIFY_TS"),
    ("PROD_WG.DRILL_BLAST.DRILLBLAST_EQUIPMENT", "DW_MODIFY_TS"),
    ("PROD_WG.DRILL_BLAST.DRILLBLAST_OPERATOR", "DW_MODIFY_TS"),
    ("PROD_WG.DRILL_BLAST.DRILLBLAST_SHIFT", "DW_MODIFY_TS"),
    ("PROD_WG.DRILLBLAST.BL_DW_BLAST", "DW_MODIFY_TS"),
    ("PROD_WG.DRILLBLAST.BL_DW_BLASTPROPERTYVALUE", "DW_MODIFY_TS"),
    ("PROD_WG.DRILLBLAST.BL_DW_HOLE", "DW_MODIFY_TS"),
    ("PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE_V", "CYCLE_END_TS_LOCAL"),
    ("PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE", "CYCLE_END_TS_LOCAL"),
]

print("\nTesting each table:")
print("-" * 60)

working_tables = []
for table, ts_col in test_tables:
    try:
        # First test if table exists
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        total = cursor.fetchone()[0]
        
        # Then test with timestamp filter
        cursor.execute(f"SELECT COUNT(*) FROM {table} WHERE {ts_col} >= DATEADD(day, -30, CURRENT_TIMESTAMP())")
        recent = cursor.fetchone()[0]
        
        print(f"✅ {table}")
        print(f"   Total: {total:,} | Last 30 days: {recent:,}")
        working_tables.append((table, ts_col, total, recent))
        
    except Exception as e:
        err_msg = str(e).split('\n')[0][:60]
        print(f"❌ {table}")
        print(f"   Error: {err_msg}")

print("\n" + "=" * 60)
print("WORKING TABLES SUMMARY")
print("=" * 60)
for table, ts_col, total, recent in working_tables:
    print(f"  {table.split('.')[-1]}: {recent:,} rows (30d)")

conn.close()
